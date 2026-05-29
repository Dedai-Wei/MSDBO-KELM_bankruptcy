warning off;
close all;
clear;
clc;

rootDir = fileparts(mfilename('fullpath'));
cd(rootDir);
addpath(rootDir);
addpath(fullfile(rootDir, 'path_kelm'));

datasetName = 'bankreshape';
sourceFile = fullfile(rootDir, [datasetName, '.xlsx']);
if ~exist(sourceFile, 'file')
    error('Dataset file not found: %s', sourceFile);
end

rawData = xlsread(sourceFile);
featureMatrix = rawData(:, 1:end-1)';
classLabels = rawData(:, end)';
nClasses = numel(unique(classLabels));
if nClasses ~= 2
    error('This script expects a binary classification dataset because MCC, sensitivity, and specificity are binary metrics.');
end

oneHotLabels = ind2vec(classLabels);
[normalizedFeatures, ~] = mapminmax(featureMatrix, 0, 1);

pop = 30;
maxIter = 100;
dim = 2;
lb = [1, 1];
ub = [20, 20];
nRuns = 30;
seedBase = 20260529;
fitnessKFolds = 5;
metricKFolds = 10;

if strcmpi(getenv('MSDBO_RERUN_MODE'), 'smoke')
    pop = 10;
    maxIter = 2;
    nRuns = 1;
end

algorithms = {'QHDBO', 'IDBO', 'DBO', 'WOA', 'GWO', 'HHO', 'EVO', 'PO', 'NRBO', 'CPO', 'SWO', 'MSDBO'};
nAlgorithms = numel(algorithms);
nTotal = nRuns * nAlgorithms;

timestamp = datestr(now, 'yyyymmdd_HHMMSS');
outDir = fullfile(rootDir, ['result_metrics_runtime_rankings_', timestamp]);
if ~exist(outDir, 'dir')
    mkdir(outDir);
end
progressLogFile = fullfile(outDir, 'progress_log.txt');
writeProgress(progressLogFile, 'Experiment started.');
writeProgress(progressLogFile, 'Result folder: %s', outDir);

datasetCol = cell(nTotal, 1);
algorithmCol = cell(nTotal, 1);
statusCol = cell(nTotal, 1);
errorCol = cell(nTotal, 1);
runCol = zeros(nTotal, 1);
seedCol = nan(nTotal, 1);
bestScoreCol = nan(nTotal, 1);
bestCCol = nan(nTotal, 1);
bestKernelCol = nan(nTotal, 1);
accCol = nan(nTotal, 1);
mccCol = nan(nTotal, 1);
sensitivityCol = nan(nTotal, 1);
specificityCol = nan(nTotal, 1);
optimizationRuntimeCol = nan(nTotal, 1);
evaluationRuntimeCol = nan(nTotal, 1);
totalRuntimeCol = nan(nTotal, 1);

rowIdx = 0;
fprintf('Dataset: %s\n', sourceFile);
fprintf('Settings: pop=%d, maxIter=%d, runs=%d, C/S bounds=[%g,%g]\n', pop, maxIter, nRuns, lb(1), ub(1));
fprintf('Outputs: %s\n', outDir);
fprintf('Progress log: %s\n', progressLogFile);
writeProgress(progressLogFile, 'Dataset: %s', sourceFile);
writeProgress(progressLogFile, 'Settings: pop=%d, maxIter=%d, runs=%d, fitnessKFolds=%d, metricKFolds=%d, seedBase=%d', ...
    pop, maxIter, nRuns, fitnessKFolds, metricKFolds, seedBase);
writeProgress(progressLogFile, 'Algorithms: %s', strjoin(algorithms, ', '));

for algIndex = 1:nAlgorithms
    algorithm = algorithms{algIndex};
    fprintf('\n[%02d/%02d] %s\n', algIndex, nAlgorithms, algorithm);
    writeProgress(progressLogFile, 'Algorithm %02d/%02d started: %s', algIndex, nAlgorithms, algorithm);

    for runIdx = 1:nRuns
        rowIdx = rowIdx + 1;
        datasetCol{rowIdx} = datasetName;
        algorithmCol{rowIdx} = algorithm;
        runCol(rowIdx) = runIdx;
        statusCol{rowIdx} = 'ok';
        errorCol{rowIdx} = '';

        seedValue = seedBase + runIdx;
        seedCol(rowIdx) = seedValue;
        rng(seedValue, 'twister');
        fitnessFoldId = crossvalind('Kfold', classLabels, fitnessKFolds);
        metricFoldId = crossvalind('Kfold', classLabels, metricKFolds);
        fitnessFunction = @(params) kelmAccuracyFitness(params, normalizedFeatures, oneHotLabels, fitnessFoldId);

        runTimer = tic;
        try
            optimizationTimer = tic;
            [bestScore, bestPosition, ~] = feval(algorithm, pop, maxIter, lb, ub, dim, fitnessFunction);
            optimizationRuntime = toc(optimizationTimer);

            evaluationTimer = tic;
            [accValue, mccValue, sensitivityValue, specificityValue] = evaluateKelmMetrics( ...
                normalizedFeatures, oneHotLabels, bestPosition(1), bestPosition(2), 'rbf', metricFoldId);
            evaluationRuntime = toc(evaluationTimer);
            totalRuntime = toc(runTimer);

            bestScoreCol(rowIdx) = bestScore;
            bestCCol(rowIdx) = bestPosition(1);
            bestKernelCol(rowIdx) = bestPosition(2);
            accCol(rowIdx) = accValue;
            mccCol(rowIdx) = mccValue;
            sensitivityCol(rowIdx) = sensitivityValue;
            specificityCol(rowIdx) = specificityValue;
            optimizationRuntimeCol(rowIdx) = optimizationRuntime;
            evaluationRuntimeCol(rowIdx) = evaluationRuntime;
            totalRuntimeCol(rowIdx) = totalRuntime;

            fprintf('  run %02d/%02d seed=%d: ACC=%.4f, MCC=%.4f, time=%.2fs\n', runIdx, nRuns, seedValue, accValue, mccValue, totalRuntime);
            writeProgress(progressLogFile, 'Algorithm %02d/%02d %s run %02d/%02d seed=%d OK: ACC=%.4f, MCC=%.4f, Sensitivity=%.4f, Specificity=%.4f, optTime=%.2fs, evalTime=%.2fs, totalTime=%.2fs', ...
                algIndex, nAlgorithms, algorithm, runIdx, nRuns, seedValue, accValue, mccValue, sensitivityValue, specificityValue, ...
                optimizationRuntime, evaluationRuntime, totalRuntime);
        catch ME
            statusCol{rowIdx} = 'fail';
            errorCol{rowIdx} = ME.message;
            totalRuntimeCol(rowIdx) = toc(runTimer);
            fprintf('  run %02d/%02d seed=%d failed: %s\n', runIdx, nRuns, seedValue, ME.message);
            writeProgress(progressLogFile, 'Algorithm %02d/%02d %s run %02d/%02d seed=%d FAILED after %.2fs: %s', ...
                algIndex, nAlgorithms, algorithm, runIdx, nRuns, seedValue, totalRuntimeCol(rowIdx), ME.message);
        end
    end

    checkpointFile = fullfile(outDir, [datasetName, '_checkpoint.mat']);
    save(checkpointFile, 'datasetName', 'sourceFile', 'algorithms', 'pop', 'maxIter', 'dim', 'lb', 'ub', ...
        'nRuns', 'seedBase', 'fitnessKFolds', 'metricKFolds', 'datasetCol', 'algorithmCol', 'statusCol', ...
        'errorCol', 'runCol', 'seedCol', 'bestScoreCol', 'bestCCol', 'bestKernelCol', 'accCol', 'mccCol', ...
        'sensitivityCol', 'specificityCol', 'optimizationRuntimeCol', 'evaluationRuntimeCol', 'totalRuntimeCol', 'rowIdx');
    writeProgress(progressLogFile, 'Algorithm %02d/%02d finished: %s. Checkpoint saved: %s', algIndex, nAlgorithms, algorithm, checkpointFile);
end

rawTable = table(datasetCol, algorithmCol, runCol, seedCol, statusCol, errorCol, bestScoreCol, bestCCol, bestKernelCol, ...
    accCol, mccCol, sensitivityCol, specificityCol, optimizationRuntimeCol, evaluationRuntimeCol, totalRuntimeCol, ...
    'VariableNames', {'Dataset', 'Algorithm', 'Run', 'Seed', 'Status', 'ErrorMessage', 'BestScore', 'BestC', 'BestKernelParameter', ...
    'ACC', 'MCC', 'Sensitivity', 'Specificity', 'OptimizationRuntimeSeconds', 'EvaluationRuntimeSeconds', 'TotalRuntimeSeconds'});

summaryAlgorithm = algorithms(:);
runsOk = zeros(nAlgorithms, 1);
accMean = nan(nAlgorithms, 1);
accStd = nan(nAlgorithms, 1);
mccMean = nan(nAlgorithms, 1);
mccStd = nan(nAlgorithms, 1);
sensitivityMean = nan(nAlgorithms, 1);
sensitivityStd = nan(nAlgorithms, 1);
specificityMean = nan(nAlgorithms, 1);
specificityStd = nan(nAlgorithms, 1);
optRuntimeMean = nan(nAlgorithms, 1);
optRuntimeStd = nan(nAlgorithms, 1);
totalRuntimeMean = nan(nAlgorithms, 1);
totalRuntimeStd = nan(nAlgorithms, 1);
totalRuntimeSum = nan(nAlgorithms, 1);
bestCMean = nan(nAlgorithms, 1);
bestKernelMean = nan(nAlgorithms, 1);

for algIndex = 1:nAlgorithms
    okMask = strcmp(algorithmCol, algorithms{algIndex}) & strcmp(statusCol, 'ok');
    runsOk(algIndex) = sum(okMask);
    accMean(algIndex) = mean(accCol(okMask), 'omitnan');
    accStd(algIndex) = std(accCol(okMask), 0, 'omitnan');
    mccMean(algIndex) = mean(mccCol(okMask), 'omitnan');
    mccStd(algIndex) = std(mccCol(okMask), 0, 'omitnan');
    sensitivityMean(algIndex) = mean(sensitivityCol(okMask), 'omitnan');
    sensitivityStd(algIndex) = std(sensitivityCol(okMask), 0, 'omitnan');
    specificityMean(algIndex) = mean(specificityCol(okMask), 'omitnan');
    specificityStd(algIndex) = std(specificityCol(okMask), 0, 'omitnan');
    optRuntimeMean(algIndex) = mean(optimizationRuntimeCol(okMask), 'omitnan');
    optRuntimeStd(algIndex) = std(optimizationRuntimeCol(okMask), 0, 'omitnan');
    totalRuntimeMean(algIndex) = mean(totalRuntimeCol(okMask), 'omitnan');
    totalRuntimeStd(algIndex) = std(totalRuntimeCol(okMask), 0, 'omitnan');
    totalRuntimeValues = totalRuntimeCol(okMask);
    totalRuntimeSum(algIndex) = sum(totalRuntimeValues(~isnan(totalRuntimeValues)));
    bestCMean(algIndex) = mean(bestCCol(okMask), 'omitnan');
    bestKernelMean(algIndex) = mean(bestKernelCol(okMask), 'omitnan');
end

accRank = rankDescending(accMean);
mccRank = rankDescending(mccMean);
sensitivityRank = rankDescending(sensitivityMean);
specificityRank = rankDescending(specificityMean);
runtimeRank = rankAscending(totalRuntimeMean);

summaryTable = table(summaryAlgorithm, runsOk, accMean, accStd, accRank, mccMean, mccStd, mccRank, ...
    sensitivityMean, sensitivityStd, sensitivityRank, specificityMean, specificityStd, specificityRank, ...
    optRuntimeMean, optRuntimeStd, totalRuntimeMean, totalRuntimeStd, totalRuntimeSum, runtimeRank, bestCMean, bestKernelMean, ...
    'VariableNames', {'Algorithm', 'RunsOK', 'ACC_Mean', 'ACC_Std', 'ACC_Rank', 'MCC_Mean', 'MCC_Std', 'MCC_Rank', ...
    'Sensitivity_Mean', 'Sensitivity_Std', 'Sensitivity_Rank', 'Specificity_Mean', 'Specificity_Std', 'Specificity_Rank', ...
    'OptimizationRuntime_MeanSeconds', 'OptimizationRuntime_StdSeconds', 'TotalRuntime_MeanSeconds', ...
    'TotalRuntime_StdSeconds', 'TotalRuntime_SumSeconds', 'Runtime_Rank', 'BestC_Mean', 'BestKernelParameter_Mean'});

accRanking = makeRankingTable(summaryAlgorithm, accMean, accStd, totalRuntimeMean, 'ACC', true);
mccRanking = makeRankingTable(summaryAlgorithm, mccMean, mccStd, totalRuntimeMean, 'MCC', true);
sensitivityRanking = makeRankingTable(summaryAlgorithm, sensitivityMean, sensitivityStd, totalRuntimeMean, 'Sensitivity', true);
specificityRanking = makeRankingTable(summaryAlgorithm, specificityMean, specificityStd, totalRuntimeMean, 'Specificity', true);
runtimeRanking = makeRankingTable(summaryAlgorithm, totalRuntimeMean, totalRuntimeStd, optRuntimeMean, 'TotalRuntimeSeconds', false);

runtimeDir = fullfile(outDir, 'runtime_details');
if ~exist(runtimeDir, 'dir')
    mkdir(runtimeDir);
end

runtimeRawTable = table(algorithmCol, runCol, seedCol, statusCol, optimizationRuntimeCol, evaluationRuntimeCol, totalRuntimeCol, ...
    'VariableNames', {'Algorithm', 'Run', 'Seed', 'Status', 'OptimizationRuntimeSeconds', 'EvaluationRuntimeSeconds', 'TotalRuntimeSeconds'});
runtimeAverageTable = table(summaryAlgorithm, runsOk, optRuntimeMean, optRuntimeStd, totalRuntimeMean, totalRuntimeStd, totalRuntimeSum, runtimeRank, ...
    'VariableNames', {'Algorithm', 'RunsOK', 'OptimizationRuntime_MeanSeconds', 'OptimizationRuntime_StdSeconds', ...
    'TotalRuntime_MeanSeconds', 'TotalRuntime_StdSeconds', 'TotalRuntime_SumSeconds', 'Runtime_Rank'});

writetable(runtimeRawTable, fullfile(runtimeDir, [datasetName, '_all_single_run_times.csv']));
writetable(runtimeAverageTable, fullfile(runtimeDir, [datasetName, '_average_runtime_by_algorithm.csv']));
for algIndex = 1:nAlgorithms
    algorithmMask = strcmp(algorithmCol, algorithms{algIndex});
    algorithmRuntimeTable = runtimeRawTable(algorithmMask, :);
    writetable(algorithmRuntimeTable, fullfile(runtimeDir, [datasetName, '_', algorithms{algIndex}, '_single_run_times.csv']));
end

writetable(rawTable, fullfile(outDir, [datasetName, '_raw_runs.csv']));
writetable(summaryTable, fullfile(outDir, [datasetName, '_summary_four_metrics_runtime.csv']));
writetable(accRanking, fullfile(outDir, [datasetName, '_ranking_ACC.csv']));
writetable(mccRanking, fullfile(outDir, [datasetName, '_ranking_MCC.csv']));
writetable(sensitivityRanking, fullfile(outDir, [datasetName, '_ranking_Sensitivity.csv']));
writetable(specificityRanking, fullfile(outDir, [datasetName, '_ranking_Specificity.csv']));
writetable(runtimeRanking, fullfile(outDir, [datasetName, '_ranking_Runtime.csv']));

xlsxFile = fullfile(outDir, [datasetName, '_metrics_runtime_rankings.xlsx']);
writetable(summaryTable, xlsxFile, 'Sheet', 'Summary');
writetable(accRanking, xlsxFile, 'Sheet', 'Rank_ACC');
writetable(mccRanking, xlsxFile, 'Sheet', 'Rank_MCC');
writetable(sensitivityRanking, xlsxFile, 'Sheet', 'Rank_Sensitivity');
writetable(specificityRanking, xlsxFile, 'Sheet', 'Rank_Specificity');
writetable(runtimeRanking, xlsxFile, 'Sheet', 'Rank_Runtime');
writetable(runtimeRawTable, xlsxFile, 'Sheet', 'Runtime_Raw');
writetable(runtimeAverageTable, xlsxFile, 'Sheet', 'Runtime_Average');
writetable(rawTable, xlsxFile, 'Sheet', 'Raw_Runs');

matFile = fullfile(outDir, [datasetName, '_metrics_runtime_rankings.mat']);
save(matFile, 'rawTable', 'summaryTable', 'accRanking', 'mccRanking', 'sensitivityRanking', ...
    'specificityRanking', 'runtimeRanking', 'runtimeRawTable', 'runtimeAverageTable', 'datasetName', 'sourceFile', 'algorithms', 'pop', 'maxIter', ...
    'dim', 'lb', 'ub', 'nRuns', 'seedBase', 'seedCol', 'fitnessKFolds', 'metricKFolds');

fprintf('\nFinished. Key outputs:\n');
fprintf('  %s\n', fullfile(outDir, [datasetName, '_summary_four_metrics_runtime.csv']));
fprintf('  %s\n', fullfile(outDir, [datasetName, '_metrics_runtime_rankings.xlsx']));
fprintf('  %s\n', fullfile(outDir, [datasetName, '_ranking_Runtime.csv']));
fprintf('  %s\n', runtimeDir);
writeProgress(progressLogFile, 'Final summary CSV: %s', fullfile(outDir, [datasetName, '_summary_four_metrics_runtime.csv']));
writeProgress(progressLogFile, 'Final Excel workbook: %s', fullfile(outDir, [datasetName, '_metrics_runtime_rankings.xlsx']));
writeProgress(progressLogFile, 'Runtime ranking CSV: %s', fullfile(outDir, [datasetName, '_ranking_Runtime.csv']));
writeProgress(progressLogFile, 'Runtime detail folder: %s', runtimeDir);
writeProgress(progressLogFile, 'All single-run runtime CSV: %s', fullfile(runtimeDir, [datasetName, '_all_single_run_times.csv']));
writeProgress(progressLogFile, 'Average runtime CSV: %s', fullfile(runtimeDir, [datasetName, '_average_runtime_by_algorithm.csv']));
writeProgress(progressLogFile, 'Experiment finished.');

function fitness = kelmAccuracyFitness(params, features, labels, foldId)
    nFolds = max(foldId);
    accValues = zeros(nFolds, 1);
    regularizationCoefficient = params(1);
    kernelParameter = params(2);
    kernelType = 'rbf';

    for foldIndex = 1:nFolds
        testMask = (foldId == foldIndex);
        trainMask = ~testMask;
        trainFeatures = features(:, trainMask);
        trainLabels = labels(:, trainMask);
        testFeatures = features(:, testMask);
        testLabels = labels(:, testMask);

        [~, inputWeight] = kelmTrain(trainFeatures, trainLabels, regularizationCoefficient, kernelType, kernelParameter);
        predictionScores = kelmPredict(trainFeatures, inputWeight, kernelType, kernelParameter, testFeatures);
        [~, predictedLabels] = max(predictionScores, [], 1);
        [~, trueLabels] = max(testLabels, [], 1);
        accValues(foldIndex) = mean(predictedLabels == trueLabels);
    end

    fitness = 1 - mean(accValues);
end

function [accValue, mccValue, sensitivityValue, specificityValue] = evaluateKelmMetrics(features, labels, regularizationCoefficient, kernelParameter, kernelType, foldId)
    nFolds = max(foldId);
    metricValues = zeros(nFolds, 4);
    nClasses = size(labels, 1);

    for foldIndex = 1:nFolds
        testMask = (foldId == foldIndex);
        trainMask = ~testMask;
        trainFeatures = features(:, trainMask);
        trainLabels = labels(:, trainMask);
        testFeatures = features(:, testMask);
        testLabels = labels(:, testMask);

        [~, inputWeight] = kelmTrain(trainFeatures, trainLabels, regularizationCoefficient, kernelType, kernelParameter);
        predictionScores = kelmPredict(trainFeatures, inputWeight, kernelType, kernelParameter, testFeatures);
        [~, predictedLabels] = max(predictionScores, [], 1);
        [~, trueLabels] = max(testLabels, [], 1);
        confusionMatrix = confusionmat(trueLabels, predictedLabels, 'Order', 1:nClasses);
        metricValues(foldIndex, :) = binaryMetrics(confusionMatrix);
    end

    averageMetrics = mean(metricValues, 1);
    accValue = averageMetrics(1) * 100;
    mccValue = averageMetrics(2);
    sensitivityValue = averageMetrics(3) * 100;
    specificityValue = averageMetrics(4) * 100;
end

function metricValues = binaryMetrics(confusionMatrix)
    truePositive = confusionMatrix(1, 1);
    trueNegative = confusionMatrix(2, 2);
    falsePositive = confusionMatrix(1, 2);
    falseNegative = confusionMatrix(2, 1);

    totalCount = truePositive + trueNegative + falsePositive + falseNegative;
    accValue = safeDivide(truePositive + trueNegative, totalCount);
    mccDenominator = sqrt((truePositive + falsePositive) * (truePositive + falseNegative) * ...
        (trueNegative + falsePositive) * (trueNegative + falseNegative));
    mccValue = safeDivide(truePositive * trueNegative - falsePositive * falseNegative, mccDenominator);
    sensitivityValue = safeDivide(truePositive, truePositive + falseNegative);
    specificityValue = safeDivide(trueNegative, trueNegative + falsePositive);
    metricValues = [accValue, mccValue, sensitivityValue, specificityValue];
end

function result = safeDivide(numerator, denominator)
    if denominator == 0
        result = 0;
    else
        result = numerator / denominator;
    end
end

function ranks = rankDescending(values)
    ranks = nan(size(values));
    sortableValues = values;
    sortableValues(isnan(sortableValues)) = -Inf;
    [~, order] = sort(sortableValues, 'descend');
    for rankIndex = 1:numel(order)
        if ~isnan(values(order(rankIndex)))
            ranks(order(rankIndex)) = rankIndex;
        end
    end
end

function ranks = rankAscending(values)
    ranks = nan(size(values));
    sortableValues = values;
    sortableValues(isnan(sortableValues)) = Inf;
    [~, order] = sort(sortableValues, 'ascend');
    for rankIndex = 1:numel(order)
        if ~isnan(values(order(rankIndex)))
            ranks(order(rankIndex)) = rankIndex;
        end
    end
end

function rankingTable = makeRankingTable(algorithmNames, means, stdValues, runtimeMeans, metricName, higherIsBetter)
    if higherIsBetter
        sortableValues = means;
        sortableValues(isnan(sortableValues)) = -Inf;
        [~, order] = sort(sortableValues, 'descend');
    else
        sortableValues = means;
        sortableValues(isnan(sortableValues)) = Inf;
        [~, order] = sort(sortableValues, 'ascend');
    end
    rankValues = (1:numel(order))';
    rankingTable = table(rankValues, algorithmNames(order), means(order), stdValues(order), runtimeMeans(order), ...
        'VariableNames', {'Rank', 'Algorithm', [metricName, '_Mean'], [metricName, '_Std'], 'ReferenceRuntimeSeconds'});
end

function writeProgress(logFile, message, varargin)
    fid = fopen(logFile, 'a');
    if fid < 0
        warning('Cannot open progress log file: %s', logFile);
        return;
    end
    cleaner = onCleanup(@() fclose(fid));
    timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
    fprintf(fid, '[%s] %s\n', timestamp, sprintf(message, varargin{:}));
end
