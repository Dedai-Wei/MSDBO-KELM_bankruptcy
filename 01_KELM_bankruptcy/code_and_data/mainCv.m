warning off             % 关闭报警信息
close all               % 关闭开启的图窗
clear                   % 清空变量
clc                     % 清空命令行
addpath path_kelm
%%  导入数据
res = xlsread('bankreshape.xlsx');

% 数据预处理
% 将数据集的特征和标签分开
P = res(:, 1:end-1)'; % 特征
T = res(:, end)';     % 标签

% 转换标签为one-hot编码（适用于KELM的标签格式）
T = ind2vec(T);

% 全部数据归一化
[Pn, ps_input] = mapminmax(P, 0, 1);
%% 参数设置
pop=30; %种群数量
Max_time=10; %  设定最大迭代次数
dim = 2;% 维度为2，即优化两个参数，正则化系数 C 和核函数参数 S
lb = [1,1];%下边界
ub = [20,20];%上边界
fobj = @(x) funcv(x, Pn, T);
[Best_score,Best_pos,curve]=PO(pop,Max_time,lb,ub,dim,fobj); %开始优化

%% 获取最优正则化系数 C 和核函数参数 S
Regularization_coefficient = Best_pos(1);
Kernel_para = Best_pos(2);
Kernel_type = 'rbf';
%% 

% 使用最优参数执行交叉验证并计算性能指标
[ACC, MCC, Sensitivity, Specificity] = performCV(Pn, T, Regularization_coefficient, Kernel_para, Kernel_type);

% 显示性能指标
fprintf('Average ACC: %.2f%%\n', ACC);
fprintf('Average MCC: %.2f\n', MCC);
fprintf('Average Sensitivity: %.2f%%\n', Sensitivity);
fprintf('Average Specificity: %.2f%%\n', Specificity);

% 保存性能指标到Excel
PerformanceMetrics = {'ACC', ACC; 'MCC', MCC; 'Sensitivity', Sensitivity; 'Specificity', Specificity};
filename = 'PerformanceMetrics.xlsx';
xlswrite(filename, PerformanceMetrics);
%% 


