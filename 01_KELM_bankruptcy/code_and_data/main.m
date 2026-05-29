warning off             % 关闭报警信息
close all               % 关闭开启的图窗
clear                   % 清空变量
clc                     % 清空命令行
addpath path_kelm
%%  导入数据
res = xlsread('bankreshape.xlsx');

%%  分析数据
num_class = length(unique(res(:, end)));  % 类别数（Excel最后一列放类别）
num_res = size(res, 1);                   % 样本数（每一行，是一个样本）
num_size = 0.7;                           % 训练集占数据集的比例
res = res(randperm(num_res), :);          % 打乱数据集（不打乱数据时，注释该行）
flag_conusion = 1;                        % 标志位为1，打开混淆矩阵（要求2018版本及以上）

%%  设置变量存储数据
P_train = []; P_test = [];
T_train = []; T_test = [];

%%  划分数据集
for i = 1 : num_class
    mid_res = res((res(:, end) == i), :);           % 循环取出不同类别的样本
    mid_size = size(mid_res, 1);                    % 得到不同类别样本个数
    mid_tiran = round(num_size * mid_size);         % 得到该类别的训练样本个数

    P_train = [P_train; mid_res(1: mid_tiran, 1: end - 1)];       % 训练集输入
    T_train = [T_train; mid_res(1: mid_tiran, end)];              % 训练集输出

    P_test  = [P_test; mid_res(mid_tiran + 1: end, 1: end - 1)];  % 测试集输入
    T_test  = [T_test; mid_res(mid_tiran + 1: end, end)];         % 测试集输出
end

%%  数据转置
P_train = P_train'; P_test = P_test';
T_train = T_train'; T_test = T_test';

%% 对训练集更改标签
T_train1=T_train;
T_train=ind2vec(T_train);

%% 对测试集更改标签
T_test1=T_test;
T_test=ind2vec(T_test);

N = size(P_test, 2);          % 测试集样本数
M = size(P_train, 2);         % 训练集样本数

%%  数据归一化
[p_train, ps_input] = mapminmax(P_train, 0, 1);
p_test = mapminmax('apply', P_test, ps_input);

%% 参数设置
pop=50; %种群数量
Max_time=500; %  设定最大迭代次数
dim = 2;% 维度为2，即优化两个参数，正则化系数 C 和核函数参数 S
lb = [1,1];%下边界
ub = [20,20];%上边界
fobj = @(x) fun(x,p_train,T_train,p_test,T_test);
[Best_score,Best_pos,curve]=MSDBO(pop,Max_time,lb,ub,dim,fobj); %开始优化

%% 获取最优正则化系数 C 和核函数参数 S
Regularization_coefficient = Best_pos(1);
Kernel_para = Best_pos(2);
Kernel_type = 'rbf';
%% 训练
[TrainOutT,OutputWeight] = kelmTrain(p_train,T_train,Regularization_coefficient,Kernel_type,Kernel_para);
%% 预测
InputWeight = OutputWeight;
predictValue2= kelmPredict(p_train,InputWeight,Kernel_type,Kernel_para,p_test);
predictValue1= kelmPredict(p_train,InputWeight,Kernel_type,Kernel_para,p_train);
%%  统计
[~, sim_train] = max(predictValue1,[],1);
[~, sim_test] = max(predictValue2,[],1);
%%  性能评价
[T_train1,index]=sort(T_train1);
T_sim1=sim_train(index);
[T_test1,index]=sort(T_test1);
T_sim2=sim_test(index);
%%  性能评价
error1 = sum((T_sim1 == T_train1)) / M * 100 ;
error2 = sum((T_sim2 == T_test1 )) / N * 100 ;

figure;
plot(1 : length(curve),curve, 'LineWidth', 1.5);
title('适应度曲线', 'FontSize', 13);
xlabel('迭代次数', 'FontSize', 10);
ylabel('适应度值', 'FontSize', 10);
%%  绘图
figure
plot(1: M, T_train1, 'r-*', 1: M, T_sim1, 'b-o', 'LineWidth', 1)
legend('真实值', 'WOA-KELM预测值')
xlabel('预测样本')
ylabel('预测结果')
string = {'训练集预测结果对比'; ['准确率=' num2str(error1) '%']};
title(string)
grid

figure
plot(1: N, T_test1, 'r-*', 1: N, T_sim2, 'b-o', 'LineWidth', 1)
legend('真实值', 'MSDBO-KELM预测值')
xlabel('预测样本')
ylabel('预测结果')
string = {'测试集预测结果对比'; ['准确率=' num2str(error2) '%']};
title(string)
grid

%%  混淆矩阵
figure
cm = confusionchart(T_train1, T_sim1);
cm.Title = 'Confusion Matrix for Train Data';
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';

figure
cm = confusionchart(T_test1, T_sim2);
cm.Title = 'Confusion Matrix for Test Data';
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';
%% 指标计算
% 计算性能评估指标
TP = sum((T_sim2 == 1) & (T_test1 == 1));
TN = sum((T_sim2 == 2) & (T_test1 == 2));
FP = sum((T_sim2 == 1) & (T_test1 == 2));
FN = sum((T_sim2 == 2) & (T_test1 == 1));

ACC = (TP + TN) / (TP + FP + FN + TN) * 100;
MCC = ((TP * TN) - (FP * FN)) / sqrt((TP + FP) * (TP + FN) * (TN + FP) * (TN + FN));
Sensitivity = TP / (TP + FN) * 100;
Specificity = TN / (FP + TN) * 100;

% 创建性能指标表
PerformanceMetrics = {'ACC', ACC; 'MCC', MCC; 'Sensitivity', Sensitivity; 'Specificity', Specificity};

% 显示性能指标
disp('性能指标:');
disp(PerformanceMetrics);
%% 
% Excel文件名和路径
filename = 'PerformanceMetrics.xlsx';

% 写入数据到Excel
xlswrite(filename, PerformanceMetrics);

