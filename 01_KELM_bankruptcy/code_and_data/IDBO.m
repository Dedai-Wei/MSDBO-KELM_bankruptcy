%微信公众号搜索：淘个代码，获取更多免费代码
%禁止倒卖转售，违者必究！！！！！
%唯一官方店铺：https://mbd.pub/o/author-amqYmHBs/work，其他途径都是骗子！

function [fMin , bestX, Convergence_curve1] = IDBO(pop, M,c,d,dim,fobj  )

%% 记录历史位置
Trajectories=zeros(pop,M);
position_history=zeros(pop,M,dim);
fitness_history=zeros(pop,M);

P_percent = 0.2;    % The population size of producers accounts for "P_percent" percent of the total population size
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pNum = round( pop *  P_percent );    % The population size of the producers
lb= c.*ones( 1,dim );    % Lower limit/bounds/     a vector
ub= d.*ones( 1,dim );    % Upper limit/bounds/     a vector
%Initialization

%% 改进点1：采用Fuch混沌映射生成种群粒子
x = repmat(lb,pop,1)+Fuch(pop,dim).* repmat((ub-lb),pop,1);  
fitness = arrayfun(@(i) fobj(x(i, :)), 1:pop);
[fitness, ~] = sort(fitness);
fitness1=fitness(1);
%%  改进点1：生成反向解
for i = 1:pop
    Pmin = min(x(i,:));
    Pmax = max(x(i,:));
    for j = 1:dim
        obj_x(i,j) = rand*(Pmin+Pmax)-x(i,j);
    end
end

%%  改进点1：合并两个初始化种群
cx = [x;obj_x];

for i = 1 : size(cx,1)
    cfit( i ) = fobj( cx( i, : ) ) ;
end

%  改进点1：排序
[sfit,idx] = sort(cfit);
x = cx(idx(1:pop),:); %只取出前一半解集
fit = sfit(1:pop);


pFit = fit;
pX = x;
XX=pX;
[ fMin, bestI ] = min( fit );      % fMin denotes the global optimum fitness value
bestX = x( bestI, : );             % bestX denotes the global optimum position corresponding to fMin
% Start updating the solutions.
for t = 1 : M
    %% 记录历史位置
    for i=1:pop
        position_history(i,t,:)=pX(i,:);
        Trajectories(:,t)=pX(:,1);
        fitness_history(i,t)=pFit(1,i);
    end


    [fmax,B]=max(fit);
    worse= x(B,:);
    r2=rand(1);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1 : pNum
        if(r2<0.9)
            r1=rand(1);
            a=rand(1,1);
            if (a>0.1)
                a=1;
            else
                a=-1;
            end
            x( i , : ) =  pX(  i , :)+0.3*abs(pX(i , : )-worse)+a*0.1*(XX( i , :)); % Equation (1)
        else

            aaa= randperm(180,1);
            if ( aaa==0 ||aaa==90 ||aaa==180 )
                x(  i , : ) = pX(  i , :);
            end
            theta= aaa*pi/180;

            x(  i , : ) = pX(i,:)+tan(theta).*abs(pX(i , : )-XX( i , :));    % Equation (2)

        end

        x(  i , : ) = Bounds( x(i , : ), lb, ub );
        fit(  i  ) = fobj( x(i , : ) );
    end
    [ fMMin, bestII ] = min( fit );      % fMin denotes the current optimum fitness value
    bestXX = x( bestII, : );             % bestXX denotes the current optimum position

    R=1-t/M;                           %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Xnew1 = bestXX.*(1-R);
    Xnew2 =bestXX.*(1+R);                    %%% Equation (3)
    Xnew1= Bounds( Xnew1, lb, ub );
    Xnew2 = Bounds( Xnew2, lb, ub );
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Xnew11 = bestX.*(1-R);
    Xnew22 =bestX.*(1+R);                     %%% Equation (5)
    Xnew11= Bounds( Xnew11, lb, ub );
    Xnew22 = Bounds( Xnew22, lb, ub );
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
   %% 改进点2：自适应步长和透镜成像反向策略
    ps = -exp(1-t/M)^10;
    a0 = cos(pi/3*(1+t/M));
    if ps<0.5
        for i = ( pNum + 1 ) :12                  % Equation (4)
            x( i, : )= a0*bestXX+((rand(1,dim)).*(pX( i , : )-Xnew1)+(rand(1,dim)).*(pX( i , : )-Xnew2));
            x(i, : ) = Bounds( x(i, : ), Xnew1, Xnew2 );
            fit(i ) = fobj(  x(i,:) ) ;
        end
    else
        for i = ( pNum + 1 ) :12                 
            %%LOBL strategy
            k=(1+(t/M)^0.5)^10;
            x( i, : ) = (ub+lb)/2+(ub+lb)/(2*k)-pX(i,:)/k;
            x(i, : ) = Bounds( x(i, : ), Xnew1, Xnew2 );
            fit(i ) = fobj(  x(i,:) ) ;
        end
    end

    for i = 13: 19                  % Equation (6)


        x( i, : )=pX( i , : )+((randn(1)).*(pX( i , : )-Xnew11)+((rand(1,dim)).*(pX( i , : )-Xnew22)));
        x(i, : ) = Bounds( x(i, : ),lb, ub);
        fit(i ) = fobj(  x(i,:) ) ;

    end

    for j = 20 : pop                 % Equation (7)
        x( j,: )=bestX+randn(1,dim).*((abs(( pX(j,:  )-bestXX)))+(abs(( pX(j,:  )-bestX))))./2;
        x(j, : ) = Bounds( x(j, : ), lb, ub );
        fit(j ) = fobj(  x(j,:) ) ;
    end
    % Update the individual's best fitness vlaue and the global best fitness value
    for i = 1 : pop
        if ( fit( i ) < pFit( i ) )
            pFit( i ) = fit( i );
            pX( i, : ) = x( i, : );
        end

        if( pFit( i ) < fMin )
            % fMin= pFit( i );
            fMin= pFit( i );
            bestX = pX( i, : );
            %  a(i)=fMin;

        end
    end
    
    
    %% 改进点3：随机差分变异
    for i = 1: pop              
        id = randperm(pop);
        newx( i, : )=rand*(bestX-pX( i , : ))+rand*(pX(id(1))-pX( i , : ));
        newx(i, : ) = Bounds( newx(i, : ),lb, ub);
        newfit(i ) = fobj(  newx(i,:) ) ;
    end
    
    XX=pX;
    for i = 1 : pop
        if ( newfit( i ) < pFit( i ) )
            pFit( i ) = newfit( i );
            pX( i, : ) = newx( i, : );
        end

        if( pFit( i ) < fMin )
            % fMin= pFit( i );
            fMin= pFit( i );
            bestX = pX( i, : );
            %  a(i)=fMin;

        end
    end




    Convergence_curve(t)=fMin;
    



end
Convergence_curve1=[fitness1,Convergence_curve];
end
% Application of simple limits/bounds

function s = Bounds( s, Lb, Ub)
% Apply the lower bound vector
temp = s;
I = temp < Lb;
temp(I) = Lb(I);

% Apply the upper bound vector
J = temp > Ub;
temp(J) = Ub(J);
% Update this new move
s = temp;
end
function S = Boundss( SS, LLb, UUb)
% Apply the lower bound vector
temp = SS;
I = temp < LLb;
temp(I) = LLb(I);

% Apply the upper bound vector
J = temp > UUb;
temp(J) = UUb(J);
% Update this new move
S = temp;
end
%微信公众号搜索：淘个代码，获取更多免费代码
%禁止倒卖转售，违者必究！！！！！
%唯一官方店铺：https://mbd.pub/o/author-amqYmHBs/work，其他途径都是骗子！
