%%适应度函数
function  fitness = fun(x,p_train,T_train,p_test,T_test)
Regularization_coefficient = x(1);
Kernel_para = x(2);
Kernel_type = 'rbf';
%% 训练
[~,InputWeight] = kelmTrain(p_train,T_train,Regularization_coefficient,Kernel_type,Kernel_para);
predictValue2= kelmPredict(p_train,InputWeight,Kernel_type,Kernel_para,p_test);
predictValue1= kelmPredict(p_train,InputWeight,Kernel_type,Kernel_para,p_train);
%%  统计误差
[~, sim_train] = max(predictValue1,[],1);
[~, T_train1] = max(T_train,[],1);
acc_train=sum(T_train1 == sim_train)/length(T_train1);

[~, sim_test] = max(predictValue2,[],1);
[~, T_test1] = max(T_test,[],1);
acc_test=sum(T_test1 == sim_test)/length(T_test1);

fitness=1-acc_test;

end