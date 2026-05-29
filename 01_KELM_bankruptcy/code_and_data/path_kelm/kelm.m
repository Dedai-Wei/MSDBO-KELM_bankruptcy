function [R2,mae2,mbe,error2,mape,TestOutT,T_test]=kelm(Pn_train,Tn_train,Pn_test,T_test,outputps,N)
%% 获取最优正则化系数 C 和核函数参数 S
Regularization_coefficient = rand*20;
Kernel_para = rand*20;
Kernel_type = 'rbf';
%% 训练
[TrainOutT,OutputWeight] = kelmTrain(Pn_train,Tn_train,Regularization_coefficient,Kernel_type,Kernel_para);

%% 训练集预测
InputWeight = OutputWeight;
[TestOutT] = kelmPredict(Pn_train,InputWeight,Kernel_type,Kernel_para,Pn_test);
%% 测试集正确率
TestOutT = mapminmax('reverse',TestOutT,outputps);
errorTest = TestOutT - T_test;
MSEErrorTest = mse(errorTest);

N1=length(T_test);
R2 = (N1*sum(TestOutT.*T_test)-sum(TestOutT)*sum(T_test))^2/((N1*sum((TestOutT).^2)-(sum(TestOutT))^2)*(N1*sum((T_test).^2)-(sum(T_test))^2)); 


%%  相关指标计算
%  R2
R2 = 1 - norm(T_test -  TestOutT)^2 / norm(T_test -  mean(T_test ))^2;
disp(['测试集数据的R2为：', num2str(R2)])

%  MAE
mae2 = sum(abs(TestOutT - T_test )) ./ N ;
disp(['测试集数据的MAE为：', num2str(mae2)])
%  MBE
mbe = sum(TestOutT - T_test ) ./ N ;
disp(['测试集数据的MBE为：', num2str(mbe)])
%rmse
error2 = sqrt(sum((TestOutT - T_test ).^2) ./ N);
disp(['测试集数据的RMSE为：', num2str(error2)])
%mape
mape=mean(abs(TestOutT - T_test )./T_test);
disp(['测试集数据的MAPE为：', num2str(mape)])
