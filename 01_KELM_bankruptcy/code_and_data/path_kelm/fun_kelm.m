%%  ”¶∂»∫Ø ˝
function  fitness = fun(x,Pn_train,Tn_train,Pn_test,Tn_test)
Regularization_coefficient = x(1);
Kernel_para = x(2);
Kernel_type = 'rbf';
%% —µ¡∑
[TrainOutT,OutputWeight] = kelmTrain(Pn_train,Tn_train,Regularization_coefficient,Kernel_type,Kernel_para);
error = TrainOutT - Tn_train;
fitness = mse(error);
%% ≤‚ ‘ºØ‘§≤‚
% InputWeight = OutputWeight;
% [TestOutT] = kelmPredict(Pn_train,InputWeight,Kernel_type,Kernel_para,Pn_test);
% 
% error = TestOutT - Tn_test;
% fitness = mse(error);

end