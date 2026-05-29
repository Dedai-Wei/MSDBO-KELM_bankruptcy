
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
% 初始化算法列表
algorithms = {'QHDBO', 'IDBO', 'DBO', 'WOA', 'GWO', 'HHO', 'EVO', 'PO', 'NRBO', 'CPO', 'SWO', 'MSDBO'};
% 初始化用于存储结果的变量
metricsResults = zeros(length(algorithms), 4); % 用于存储每个算法的性能指标
curveResults = cell(length(algorithms), 1); % 用于存储每个算法的迭代曲线

% 遍历所有算法
for i = 1:length(algorithms)
    algorithm = algorithms{i};
    disp([algorithm,'正在优化']);
    % 假设已实现一个函数 optimizeAlgorithm 来执行对应的算法优化
    % 这里只是一个示例，需要根据实际情况进行调整
    [Best_score, Best_pos, curve] = feval(algorithm,  pop, Max_time, lb, ub, dim, fobj);
    % 使用最优参数执行交叉验证并计算性能指标
    [ACC, MCC, Sensitivity, Specificity] = performCV(Pn, T, Best_pos(1), Best_pos(2), 'rbf');
    % 存储结果
    metricsResults(i, :) = [ACC, MCC, Sensitivity, Specificity];
    curveResults{i} = curve;
end

% 将性能指标保存到Excel
filename = 'OptimizationResults.xlsx';
xlswrite(filename, metricsResults, 'Sheet1', 'B2');
xlswrite(filename, {'ACC', 'MCC', 'Sensitivity', 'Specificity'}, 'Sheet1', 'B1');
xlswrite(filename, algorithms', 'Sheet1', 'A2');


