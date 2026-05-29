%% Energy Valley Optimizer (EVO) source code - version 1.1 
%% Paper: Azizi M., Aickelin U., Khorshidi H., Baghalzadeh M.
%% Energy valley optimizer: a novel metaheuristic algorithm for global and engineering optimization. 
%% Scientific Reports, 13, 226 (2023). https://doi.org/10.1038/s41598-022-27344-y
%% Clear Workspace & Command Window
function [bestf,Best_Pos,Conv_History1] = EVO(nParticles,T,VarMin,VarMax,VarNumber,CostFunction)

%% Problem Information
% CostFunction = @(x) Sphere(x);          % @ Cost Function
% VarNumber = 10;                         % Number of variables;
if length(VarMin)==1
VarMin =VarMin*ones(1,VarNumber);        % Lower bound of variable;
VarMax = VarMax *ones(1,VarNumber);         % Upper bound of variable;
end
%% General Parameters
MaxFes = 150000 ;     % Maximum number of function evaluations
% nParticles = 20 ;     % Maximum number of initial candidates
%% Counters
Iter=1;   % Iterations
FEs=0;    % Function Evaluations
%% Initialization
Particles=[]; NELs=[];
for i=1:nParticles
    Particles(i,:)=unifrnd(VarMin,VarMax,[1 VarNumber]);
    NELs(i,1)=CostFunction(Particles(i,:));
    FEs=FEs+1;
end
fitness = arrayfun(@(i) CostFunction(Particles(i, :)), 1:nParticles);
[fitness, ~] = sort(fitness);
fitness1=fitness(1);
% Sort Particles
[NELs, SortOrder]=sort(NELs);
Particles=Particles(SortOrder,:);
BS=Particles(1,:); 
BS_NEL=NELs(1);
WS_NEL=NELs(end);
%% Main Loop
while Iter<=T
   
    NewParticles=[];
    NewNELs=[];   
   for i=1:nParticles
       Dist=[];
       for j=1:nParticles
           Dist(j,1)=distance(Particles(i,:), Particles(j,:));
       end
       [ ~, a]=sort(Dist);
       CnPtIndex=randi(nParticles);
       if CnPtIndex<3
           CnPtIndex=CnPtIndex+2;
       end
       CnPtA=Particles(a(2:CnPtIndex),:);
       CnPtB=NELs(a(2:CnPtIndex),:);
       X_NG=mean(CnPtA);
       X_CP=mean(Particles);
       EB=mean(NELs);            
       SL=(NELs(i)-BS_NEL)/(WS_NEL-BS_NEL); SB=rand;
       if NELs(i)>EB   
           if SB>SL         
               AlphaIndex1=randi(VarNumber);
               AlphaIndex2=randi([1 VarNumber], AlphaIndex1 , 1);
               NewParticle(1,:)=Particles(i,:);
               NewParticle(1,AlphaIndex2)=BS(AlphaIndex2);               
               GamaIndex1=randi(VarNumber);
               GamaIndex2=randi([1 VarNumber], GamaIndex1 , 1);
               NewParticle(2,:)=Particles(i,:);
               NewParticle(2,GamaIndex2)=X_NG(GamaIndex2);           
               NewParticle = max(NewParticle,VarMin);
               NewParticle = min(NewParticle,VarMax);  
               NewNEL(1,1)=CostFunction(NewParticle(1,:));
               NewNEL(2,1)=CostFunction(NewParticle(2,:));               
               FEs=FEs+2;    
           else               
               Ir=unifrnd(0,1,1,2); Jr=unifrnd(0,1,1,VarNumber);
               NewParticle(1,:)=Particles(i,:)+(Jr.*(Ir(1)*BS-Ir(2)*X_CP)/SL);
               Ir=unifrnd(0,1,1,2); Jr=unifrnd(0,1,1,VarNumber);
               NewParticle(2,:)=Particles(i,:)+(Jr.*(Ir(1)*BS-Ir(2)*X_NG));  
               NewParticle = max(NewParticle,VarMin);
               NewParticle = min(NewParticle,VarMax);
               NewNEL(1,1)=CostFunction(NewParticle(1,:));
               NewNEL(2,1)=CostFunction(NewParticle(2,:)); 
               FEs=FEs+2;   
           end    
       else 
           NewParticle(1,:)=Particles(i,:)+randn*SL*unifrnd(VarMin,VarMax,[1 VarNumber]);         
           NewParticle = max(NewParticle,VarMin);
           NewParticle = min(NewParticle,VarMax);
           NewNEL(1,1)=CostFunction(NewParticle(1,:));   
           FEs=FEs+1;
       end
   NewParticles=[NewParticles ; NewParticle];    
   NewNELs=[NewNELs ; NewNEL];
   end
   NewParticles=[NewParticles ; Particles];    
   NewNELs=[NewNELs ; NELs]; 
   
   % Sort Particles
   [NewNELs, SortOrder]=sort(NewNELs);
   NewParticles=NewParticles(SortOrder,:);
   BS=NewParticles(1,:); 
   BS_NEL=NewNELs(1); 
   WS_NEL=NewNELs(end);
   Particles=NewParticles(1:nParticles,:);
   NELs=NewNELs(1:nParticles,:);
   % Store Best Cost Ever Found
   BestCosts(Iter)=BS_NEL;
    Iter=Iter+1;
end
Eval_Number=FEs;
Conv_History=BestCosts';
Best_Pos=BS;bestf=Conv_History(end);
Conv_History1=[fitness1,Conv_History'];
end
%% Objective Function

%% Calculate the Euclidean Distance
function o = distance(a,b)
for i=1:size(a,1)
    o(1,i)=sqrt((a(i)-b(i))^2);
end
end
