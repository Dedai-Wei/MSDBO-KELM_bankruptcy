function [fMin,bestX,Convergence_curve1]=QHDBO(pop,M,c,d,dim,fobj)
    % The population size of producers accounts for "P_percent" percent of the total population size
    P_percent = 0.2;
    % The population size of the producers
    pNum=round(pop*P_percent);
    lb=c.*ones(1,dim);    % Lower limit/bounds/     a vector
    ub=d.*ones(1,dim);    % Upper limit/bounds/     a vector
    % --------------------------------------------------------
    %Initialization
    x=GoodPointSet(pop,dim,ub,lb);
    for i=1:pop
        % x(i,:)=lb+(ub-lb).*rand(1,dim);
        fit(i)=fobj(x(i,:));                 
    end
    % --------------------------------------------------------
    pFit=fit;
    pX=x; 
    XX=pX;    
    % fMin denotes the global optimum fitness value
    [fMin,bestI]=min(fit);      
    fitness1=fMin;
    % bestX denotes the global optimum position corresponding to fMin
    bestX=x(bestI,:); 
    % Start updating the solutions.
    for t=1:M
        [fmax,B]=max(fit);
        worse=x(B,:);   
        r2=rand(1);
        for i=1:pNum    
            if(r2<0.9)
                a=rand(1,1);
                if(a>0.1)
                    a=1;
                else
                    a=-1;
                end
                x(i,:)=pX(i,:)+0.3*abs(pX(i,:)-worse)+a*0.1*(XX(i,:)); % Equation (1)
            else
                aaa= randperm(180,1);
                if(aaa==0||aaa==90||aaa==180)
                    x(i,:)=pX(i,:);   
                end
                theta=aaa*pi/180;   
                x(i,:)=pX(i,:)+tan(theta).*abs(pX(i,:)-XX(i,:));    % Equation (2)
            end
            x(i,:)=Bounds(x(i,:),lb,ub);    
            fit(i)=fobj(x(i,:));
        end 
        [fMMin,bestII]=min(fit);      % fMin denotes the current optimum fitness value
        bestXX=x(bestII,:);             % bestXX denotes the current optimum position 
        % ------------------------------------------
        % R=1-t/M;      
        R=(cos(pi*(t/M))+1)*0.5;
        % ------------------------------------------
        Xnew1=bestXX.*(1-R); 
        Xnew2=bestXX.*(1+R);                    % Equation (3)
        Xnew1=Bounds(Xnew1,lb,ub);
        Xnew2=Bounds(Xnew2,lb,ub);

        Xnew11=bestX.*(1-R); 
        Xnew22=bestX.*(1+R);                     % Equation (5)
        Xnew11=Bounds(Xnew11,lb,ub);
        Xnew22=Bounds(Xnew22,lb,ub);
        % ---------------------------------------------------------------------------------
%         for i=(pNum+1):12                  % Equation (4)
%             x(i,:)=bestXX+((rand(1,dim)).*(pX(i,:)-Xnew1)+(rand(1,dim)).*(pX(i,:)-Xnew2));
%             x(i,:)=Bounds(x(i,:),Xnew1,Xnew2);
%             fit(i)=fobj(x(i,:)) ;
%         end
%         for i=13:19                  % Equation (6)
%             x(i,:)=pX(i,:)+((randn(1)).*(pX(i,:)-Xnew11)+((rand(1,dim)).*(pX(i,:)-Xnew22)));
%             x(i,:)=Bounds(x(i,:),lb,ub);
%             fit(i)=fobj(x(i,:));
%         end
        for i=(pNum+1):19
            if rand<0.2+t/M*0.6
                Ridus=(ub-lb)./2.*R;
                if i==18
                    x(i,:)=pX(i,:)+Ridus*rand*(sin(rand*pi))^(i-1-pNum)*cos(rand*2*pi);
                elseif i==19
                    x(i,:)=pX(i,:)+Ridus*rand*(sin(rand*pi))^(i-1-pNum-1)*sin(rand*2*pi);
                else
                    x(i,:)=pX(i,:)+Ridus*rand*(sin(rand*pi))^(i-1-pNum)*cos(rand*pi);
                end
            else
                x(i,:)=pX(i,:)+((randn(1)).*(pX(i,:)-Xnew11)+((rand(1,dim)).*(pX(i,:)-Xnew22)));
                x(i,:)=Bounds(x(i,:),lb,ub);
                fit(i)=fobj(x(i,:));
            end
        end
        % ---------------------------------------------------------------------------------
        for j=20:pop                 % Equation (7)
            x(j,:)=bestX+randn(1,dim).*((abs((pX(j,:)-bestXX)))+(abs(( pX(j,:)-bestX))))./2;
            x(j,:)=Bounds(x(j,:),lb,ub);
            fit(j)=fobj(x(j,:));
        end
        % ---------------------------------------------------------------------------------
        for j=1:dim
            alpha(j)=bestX(j)/norm(bestX);
            if rand < 0.5
                P=ones(1,dim);
            else
                P=(-1).*ones(1,dim);
            end
            beta(j)=P(j)*sqrt(1-(bestX(j)/norm(bestX))^2);
        end
        X_tema=alpha.*norm(bestX);
        X_temb=beta.*norm(bestX);
        Z_R=[alpha;beta];
        R_theta=[cos(2*pi*rand),-sin(2*pi*rand);sin(2*pi*rand),cos(2*pi*rand)];
        Z_R2=R_theta*Z_R;
        X_rtema=Z_R2(1,:).*norm(bestX);
        X_rtemb=Z_R2(2,:).*norm(bestX);
        x_b1=bestX+trnd(t).*X_tema;
        x_b2=bestX+trnd(t).*X_temb;
        x_b3=bestX+trnd(t).*X_rtema;
        x_b4=bestX+trnd(t).*X_rtemb;
        fitness(1)=fobj(x_b1);
        fitness(2)=fobj(x_b2);
        fitness(3)=fobj(x_b3);
        fitness(4)=fobj(x_b4);
        x_b=[x_b1;x_b2;x_b3;x_b4;bestX];
        F=[fitness(1),fitness(2),fitness(3),fitness(4),fMin];
        [fit_best,index]=max(F);
        fMin=fit_best;
        bestX=x_b(index,:);
        % ---------------------------------------------------------------------------------
        % Update the individual's best fitness vlaue and the global best fitness value
        XX=pX;
        for i=1:pop 
            if(fit(i)<pFit(i))
                pFit(i)=fit(i);
                pX(i,:)=x(i,:);
            end
            if(pFit(i)<fMin)
                fMin=pFit(i);
                bestX=pX(i,:);
                % a(i)=fMin;
            end
        end
        Convergence_curve(t)=fMin;
    end
    Convergence_curve1=[fitness1,Convergence_curve];
end

% Application of simple limits/bounds
function s=Bounds(s,Lb,Ub)
    % Apply the lower bound vector
    temp=s;
    I=temp<Lb;
    temp(I)=Lb(I);
    % Apply the upper bound vector 
    J=temp>Ub;
    temp(J)=Ub(J);
    % Update this new move 
    s=temp;
end
