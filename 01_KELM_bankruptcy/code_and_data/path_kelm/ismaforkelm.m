
function [Destination_fitness,bestPositions,Convergence_curve]=ismaforkelm(N,Max_iter,lb,ub,dim,fobj)

% 种群初始化
bestPositions=zeros(1,dim);
Destination_fitness=inf;%设置初始全最优适应度
AllFitness = inf*ones(N,1);%初始所有种群的适应度
weight = ones(N,dim);%每一个黏菌的权重
%种群初始化
lb = [1,1];%下边界
ub = [10,10];%上边界
Ub=ub(1);Lb=lb(1);
X=Goodnode_initialization(N,dim,Ub,Lb);
it=1;  %初始迭代次数
lb=ones(1,dim).*lb; % 下界
ub=ones(1,dim).*ub; % 上界
z=0.03; % 初始参数z

% 主循环
while  it <= Max_iter
    it
    for i=1:N
        % 检查是否在范围内
        Flag4ub=X(i,:)>ub;
        Flag4lb=X(i,:)<lb;
        X(i,:)=(X(i,:).*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;
        AllFitness(i) = fobj(X(i,:));
    end
    [X,AllFitness]=ODE(X,AllFitness,ub,lb,fobj);
    
    if AllFitness(1) < Destination_fitness
        bestPositions=X(1,:);
        Destination_fitness = AllFitness(1);
    end

    [SmellOrder,SmellIndex] = sort(AllFitness);  %%筛选出最优和最差的种群
    worstFitness = SmellOrder(N);
    bestFitness = SmellOrder(1);
%     bestPositions=X(SmellIndex(1),:);
%     Destination_fitness = AllFitness(SmellIndex(1));
    
    S=bestFitness-worstFitness+eps; %避免分母为0的操作
    %计算每一个黏菌的权重
    for i=1:N
        for j=1:dim
            if i<=(N/2)  %参考源码，式2.5
                weight(SmellIndex(i),j) = 1+rand()*log10((bestFitness-SmellOrder(i))/(S)+1);
            else
                weight(SmellIndex(i),j) = 1-rand()*log10((bestFitness-SmellOrder(i))/(S)+1);
            end
        end
    end
    
    %更新当前最优的种群和适应度
    if bestFitness < Destination_fitness
        bestPositions=X(SmellIndex(1),:);
        Destination_fitness = bestFitness;
    end
    
    a = atanh(-(it/Max_iter)+1);   %参考原式2.4
    b = 1-it/Max_iter;
    % 更新每一代种群的位置
    for i=1:N
        if rand<z     %Eq.(2.7)
            X(i,:) = (ub-lb)*rand+lb;
        else
            p =tanh(abs(AllFitness(i)-Destination_fitness));  %Eq.(2.2)
            vb = unifrnd(-a,a,1,dim);  %Eq.(2.3)
            vc = unifrnd(-b,b,1,dim);
            for j=1:dim
                r = rand();
                A = randi([1,N]);  % two positions randomly selected from population
                B = randi([1,N]);
                if r<p    %Eq.(2.1)
                    X(i,j) = bestPositions(j)+ vb(j)*(weight(i,j)*X(A,j)-X(B,j));
                else
                    X(i,j) = vc(j)*X(i,j);
                end
            end
        end
    end
    f_ave=mean(AllFitness);
    for g=1:N
        if fobj(X(i,:))<f_ave
            X(i,:)=X(i,:).*trnd(it);
            X(i,:) = Bounds(X(i,:), lb, ub);
        else
            rand_num=randperm(0.5*N,1);
            X(i,:)=(X(i,:)+X(rand_num,:))/2;
            X(i,:) = Bounds(X(i,:), lb, ub);
        end
    end
    
    Convergence_curve1(it)=Destination_fitness;
    it=it+1;
end


