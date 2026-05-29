function [ACC, MCC, Sensitivity, Specificity] = performCV(Pn, T, Regularization_coefficient, Kernel_para, Kernel_type)
    K = 10; % 10折交叉验证
    cvIndices = crossvalind('Kfold', T(1,:), K);
    metrics = zeros(K, 4); % 存储每折的[ACC, MCC, Sensitivity, Specificity]
    
    for i = 1:K
        testIdx = (cvIndices == i);
        trainIdx = ~testIdx;
        
        p_train_cv = Pn(:, trainIdx);
        T_train_cv = T(:, trainIdx);
        p_test_cv = Pn(:, testIdx);
        T_test_cv = T(:, testIdx);

        [~, InputWeight] = kelmTrain(p_train_cv, T_train_cv, Regularization_coefficient, Kernel_type, Kernel_para);
        predictValue_test_cv = kelmPredict(p_train_cv, InputWeight, Kernel_type, Kernel_para, p_test_cv);
        
        % 获取预测和真实标签
        [~, sim_test_cv] = max(predictValue_test_cv, [], 1);
        [~, T_test1_cv] = max(T_test_cv, [], 1);
        
        % 计算混淆矩阵
        [CM, ~] = confusionmat(T_test1_cv, sim_test_cv);
        TP = CM(1,1);
        TN = CM(2,2);
        FP = CM(1,2);
        FN = CM(2,1);
        
        % 计算性能指标
        ACC = (TP + TN) / (TP + FP + FN + TN);
        MCC = (TP * TN - FP * FN) / sqrt((TP + FP) * (TP + FN) * (TN + FP) * (TN + FN));
        Sensitivity = TP / (TP + FN);
        Specificity = TN / (TN + FP);
        
        metrics(i, :) = [ACC, MCC, Sensitivity, Specificity];
    end

    % 计算平均性能指标
    AVG_metrics = mean(metrics, 1);
    ACC = AVG_metrics(1) * 100;
    MCC = AVG_metrics(2);
    Sensitivity = AVG_metrics(3) * 100;
    Specificity = AVG_metrics(4) * 100;
end
