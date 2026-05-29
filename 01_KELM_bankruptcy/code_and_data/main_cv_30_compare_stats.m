% 环境设置
warning off; close all; clear; clc;
if ~exist('result', 'dir')
    mkdir('result');
end

% 导入数据和预处理
res = xlsread('bankreshape.xlsx');
P = res(:, 1:end-1)'; % 特征
T = res(:, end)'; % 标签
T = ind2vec(T); % 转换标签为one-hot编码
[Pn, ps_input] = mapminmax(P, 0, 1); % 数据归一化

% 参数设置
pop = 30; % 种群数量
Max_time = 100; % 最大迭代次数
dim = 2; % 维度为2
lb = [1,1]; % 下边界
ub = [20,20]; % 上边界
fobj = @(x) funcv(x, Pn, T); % 适应度函数

% 算法列表和颜色设置
algorithms = {'QHDBO', 'IDBO', 'DBO', 'WOA', 'GWO', 'HHO', 'EVO', 'PO', 'NRBO', 'CPO', 'SWO', 'MSDBO'};
colors = [1.0, 0.0, 0.0; 0.0, 1.0, 0.0; 0.2, 0.5, 1.0; 1.0, 1.0, 0.0;
          0.5, 0.0, 1.0; 1.0, 0.5, 0.0; 0.0, 0.0, 0.8; 0.5, 0.0, 0.3;
          1.0, 0.84, 0.0; 0.0, 0.6, 0.7; 0.0, 0.8, 0.4; 0.0, 0.0, 0.0];
nRuns = 30;

% 初始化存储
metricsAllRuns = zeros(nRuns, length(algorithms), 4);
curvesAllRuns = zeros(nRuns, Max_time+1, length(algorithms));

% 循环算法
for algIndex = 1:length(algorithms)
    algorithm = algorithms{algIndex};
    disp(['Running ', algorithm]);

    % 循环运行
    for run = 1:nRuns
         [Best_score, Best_pos, curve] = feval(algorithm, pop, Max_time, lb, ub, dim, fobj);
        % 模拟示例数据
        %Best_pos = rand(1, 2); % 示例最佳位置
        %curve = cumsum(rand(1, Max_time+1)); % 示例迭代曲线

        [ACC, MCC, Sensitivity, Specificity] = performCV(Pn, T, Best_pos(1), Best_pos(2), 'rbf');
        metricsAllRuns(run, algIndex, :) = [ACC, MCC, Sensitivity, Specificity];
        curvesAllRuns(run, :, algIndex) = curve;
    end
end
%% 

% 计算平均曲线和统计数据
meanCurves = squeeze(mean(curvesAllRuns, 1));
meanMetrics = squeeze(mean(metricsAllRuns, 1));
stdMetrics = squeeze(std(metricsAllRuns, 0, 1));
maxMetrics = squeeze(max(metricsAllRuns, [], 1));
minMetrics = squeeze(min(metricsAllRuns, [], 1));
medianMetrics = squeeze(median(metricsAllRuns, 1));

% 保存统计数据到Excel
filename = fullfile('result', 'PerformanceMetricsStatistics.xlsx');
headers = {'Algorithm', 'ACC Mean', 'ACC STD', 'ACC Max', 'ACC Min', 'ACC Median', ...
           'MCC Mean', 'MCC STD', 'MCC Max', 'MCC Min', 'MCC Median', ...
           'Sensitivity Mean', 'Sensitivity STD', 'Sensitivity Max', 'Sensitivity Min', 'Sensitivity Median', ...
           'Specificity Mean', 'Specificity STD', 'Specificity Max', 'Specificity Min', 'Specificity Median'};
data = [algorithms', num2cell([meanMetrics, stdMetrics, maxMetrics, minMetrics, medianMetrics])];
xlswrite(filename, [headers; data]);
%% 

% 绘制平均迭代曲线
figure; hold on;
for algIndex = 1:length(algorithms)
    plot(meanCurves(:, algIndex), 'DisplayName', algorithms{algIndex}, 'Color', colors(algIndex, :), 'LineWidth', 2);
end
hold off; legend('show'); xlabel('Iteration'); ylabel('Fitness Value');
title('Average Iteration Curves');
saveas(gcf, fullfile('result', 'AverageIterationCurves.jpg'));
%% 
Metric={'ACC','MCC','Sensitivity','Specificity'};
% 绘制箱线图并为不同算法设置不同颜色
for i = 1:4 % 对每个性能指标进行操作
    figure;
    % 绘制箱线图，此时使用默认颜色
    boxData = squeeze(metricsAllRuns(:,:,i)); % 提取第i个指标的数据
    boxplot(boxData, 'Labels', algorithms);
    ylabel([Metric{i}]);
    title(['Boxplot of ', Metric{i}]);
    
    % 获取箱线图中所有箱体的句柄
    h = findobj(gca, 'Tag', 'Box');
    % Matlab绘制箱线图时，是从后往前绘制，所以颜色索引需要反向应用
    numAlgorithms = length(algorithms);
    for j = 1:numAlgorithms
        patch(get(h(numAlgorithms-j+1),'XData'),get(h(numAlgorithms-j+1),'YData'),colors(j,:),'FaceAlpha',.5);
    end
    
    % 保存箱线图
    saveas(gcf, fullfile('result', ['BoxplotMetric', num2str(i), '.jpg']));
end

