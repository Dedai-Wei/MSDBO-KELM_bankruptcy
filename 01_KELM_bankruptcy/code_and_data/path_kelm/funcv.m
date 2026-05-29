function fitness = funcv(x, P, T)
    K = 5; % 5折交叉验证
    cvIndices = crossvalind('Kfold', T(1,:), K); % 假设T的行表示不同样本，适用于整个数据集
    acc_test_cv = zeros(1, K); % 初始化保存每一折的测试精度的数组
    
    Regularization_coefficient = x(1);
    Kernel_para = x(2);
    Kernel_type = 'rbf';

    for i = 1:K
        testIdx = (cvIndices == i); % 获取本轮的测试集索引
        trainIdx = ~testIdx; % 获取本轮的训练集索引
        
        % 从整个数据集中提取本轮的训练集和测试集
        p_train_cv = P(:, trainIdx);
        T_train_cv = T(:, trainIdx);
        p_test_cv = P(:, testIdx);
        T_test_cv = T(:, testIdx);

        % 使用提取出的训练集训练模型
        [~, InputWeight] = kelmTrain(p_train_cv, T_train_cv, Regularization_coefficient, Kernel_type, Kernel_para);
        
        % 使用模型预测测试集
        predictValue_test_cv = kelmPredict(p_train_cv, InputWeight, Kernel_type, Kernel_para, p_test_cv);
        
        % 计算本轮测试精度
        [~, sim_test_cv] = max(predictValue_test_cv, [], 1);
        [~, T_test1_cv] = max(T_test_cv, [], 1);
        acc_test_cv(i) = sum(T_test1_cv == sim_test_cv) / length(T_test1_cv);
    end

    % 计算5折交叉验证的平均测试精度
    avgAccTestCV = mean(acc_test_cv);

    % 适应度值为1减去平均测试精度
    fitness = 1 - avgAccTestCV;
end
