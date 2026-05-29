# MSDBO-KELM Bankruptcy Prediction Reproducibility Package

The repository is focused on the KELM bankruptcy prediction task only.This repository contains the code for our **neural network**-based manuscript currently under submission. It provides the main implementation, experiment scripts, and supporting files required to reproduce the reported results. It is prepared for manuscript revision and reviewer verification.


## 1. Scope of the Shared Code

The shared code is not a partial module release. It includes the complete implementation required for the bankruptcy prediction experiment:

| Component | Included? | Main files |
|---|---|---|
| MSDBO optimizer | Yes | `01_KELM_bankruptcy/code_and_data/MSDBO.m` |
| KELM model | Yes | `01_KELM_bankruptcy/code_and_data/path_kelm/kelmTrain.m`, `kelmPredict.m`, `kernel_matrix.m`, `kelm.m` |
| MSDBO-KELM integration | Yes | `01_KELM_bankruptcy/code_and_data/run_bankreshape_metrics_runtime_rankings.m`, `main_cv_30_compare_stats.m`, `path_kelm/funcv.m` |
| Comparison algorithms | Yes | `QHDBO.m`, `IDBO.m`, `DBO.m`, `WOA.m`, `GWO.m`, `HHO.m`, `EVO.m`, `PO.m`, `NRBO.m`, `CPO.m`, `SWO.m` |
| Dataset | Yes | `01_KELM_bankruptcy/code_and_data/bankreshape.xlsx` |
| Reported result tables | Yes | `01_KELM_bankruptcy/latest_results_20260529_081806/*.csv`, `*.xlsx` |
| Reported figures from original figure script | Yes | `01_KELM_bankruptcy/original_main_cv_outputs/*.jpg` |

The code scope is therefore the full bankruptcy prediction workflow:

```text
data loading -> preprocessing -> KELM parameter optimization -> KELM training/testing
-> four-metric evaluation -> runtime recording -> tables and figures
```

## 2. Repository Structure

```text
MSDBO-KELM bankruptcy prediction package
|
|-- 01_KELM_bankruptcy
|   |
|   |-- code_and_data
|   |   |-- run_bankreshape_metrics_runtime_rankings.m
|   |   |-- main_cv_30_compare_stats.m
|   |   |-- maincv_compare.m
|   |   |-- mainCv.m
|   |   |-- bankreshape.xlsx
|   |   |-- MSDBO.m
|   |   |-- QHDBO.m / IDBO.m / DBO.m / WOA.m / GWO.m / HHO.m
|   |   |-- EVO.m / PO.m / NRBO.m / CPO.m / SWO.m
|   |   `-- path_kelm
|   |       |-- funcv.m
|   |       |-- performCV.m
|   |       |-- kelmTrain.m
|   |       |-- kelmPredict.m
|   |       |-- kernel_matrix.m
|   |       `-- kelm.m
|   |
|   |-- latest_results_20260529_081806
|   |   |-- bankreshape_summary_four_metrics_runtime.csv
|   |   |-- bankreshape_raw_runs.csv
|   |   |-- bankreshape_raw_runs_with_seed.csv
|   |   |-- bankreshape_seed_schedule.csv
|   |   |-- bankreshape_metrics_runtime_rankings.xlsx
|   |   |-- bankreshape_ranking_ACC.csv
|   |   |-- bankreshape_ranking_MCC.csv
|   |   |-- bankreshape_ranking_Sensitivity.csv
|   |   |-- bankreshape_ranking_Specificity.csv
|   |   |-- bankreshape_ranking_Runtime.csv
|   |   `-- runtime_details
|   |
|   `-- original_main_cv_outputs
|       |-- PerformanceMetricsStatistics.xlsx
|       |-- AverageIterationCurves.jpg
|       |-- BoxplotMetric1.jpg
|       |-- BoxplotMetric2.jpg
|       |-- BoxplotMetric3.jpg
|       `-- BoxplotMetric4.jpg
|
`-- README.md
```

## 3. Software Environment and Dependencies

Recommended environment:

| Item | Requirement |
|---|---|
| Operating system | Windows 10/11 recommended |
| Main software | MATLAB |
| MATLAB toolboxes | Statistics and Machine Learning Toolbox; Deep Learning Toolbox or Neural Network Toolbox |
| Spreadsheet support | MATLAB support for `.xlsx` read/write |
| External language dependencies | None |

MATLAB functions used by the experiment include:

- `xlsread`, `writetable`, `save`
- `crossvalind`, `confusionmat`
- `ind2vec`, `mapminmax`
- standard MATLAB plotting and table functions

The package was organized on Windows. All paths in this README are written as relative paths so that the package can be uploaded to GitHub and run after cloning.

## 4. Main Reproduction Workflows

### 4.1 Reproduce the latest four-metric and runtime tables

Run:

```matlab
cd('01_KELM_bankruptcy/code_and_data')
run_bankreshape_metrics_runtime_rankings
```

This script generates a new folder named:

```text
result_metrics_runtime_rankings_yyyymmdd_HHMMSS
```

Main outputs:

| Output | Meaning |
|---|---|
| `bankreshape_summary_four_metrics_runtime.csv` | Mean, standard deviation, and rank of ACC, MCC, Sensitivity, Specificity, and runtime |
| `bankreshape_raw_runs.csv` | Per-run raw results for 12 algorithms x 30 runs |
| `bankreshape_metrics_runtime_rankings.xlsx` | Excel workbook containing summary, ranking sheets, runtime sheets, and raw runs |
| `bankreshape_ranking_ACC.csv` | ACC ranking |
| `bankreshape_ranking_MCC.csv` | MCC ranking |
| `bankreshape_ranking_Sensitivity.csv` | Sensitivity ranking |
| `bankreshape_ranking_Specificity.csv` | Specificity ranking |
| `bankreshape_ranking_Runtime.csv` | Runtime ranking |
| `runtime_details/*` | Single-run and average runtime details |

### 4.2 Reproduce the original table and figure generation workflow

Run:

```matlab
cd('01_KELM_bankruptcy/code_and_data')
main_cv_30_compare_stats
```

This script follows the original table/figure workflow and generates:

```text
code_and_data/result/PerformanceMetricsStatistics.xlsx
code_and_data/result/AverageIterationCurves.jpg
code_and_data/result/BoxplotMetric1.jpg
code_and_data/result/BoxplotMetric2.jpg
code_and_data/result/BoxplotMetric3.jpg
code_and_data/result/BoxplotMetric4.jpg
```

The already generated original outputs are also included in:

```text
01_KELM_bankruptcy/original_main_cv_outputs
```

Figure mapping:

| File | Meaning |
|---|---|
| `AverageIterationCurves.jpg` | Average convergence curves |
| `BoxplotMetric1.jpg` | ACC boxplot |
| `BoxplotMetric2.jpg` | MCC boxplot |
| `BoxplotMetric3.jpg` | Sensitivity boxplot |
| `BoxplotMetric4.jpg` | Specificity boxplot |

## 5. Dataset and Preprocessing

The dataset file is:

```text
01_KELM_bankruptcy/code_and_data/bankreshape.xlsx
```

The original preprocessing in `main_cv_30_compare_stats.m` is:

```matlab
res = xlsread('bankreshape.xlsx');
P = res(:, 1:end-1)';
T = res(:, end)';
T = ind2vec(T);
[Pn, ps_input] = mapminmax(P, 0, 1);
```

Meaning:

- all columns except the last one are input features;
- the last column is the class label;
- `P` is transposed to `features x samples`;
- `T` is transposed to `1 x samples`;
- `ind2vec` converts class labels into one-hot vectors;
- `mapminmax(P, 0, 1)` normalizes input features to `[0, 1]`.

To remain consistent with the original figure/table code, normalization is performed before cross-validation splitting. No additional feature selection, resampling, or data augmentation is applied.

## 6. MSDBO-KELM Integration

The optimizer searches two KELM hyperparameters:

```text
x = [C, S]
```

where:

- `C` is the KELM regularization coefficient;
- `S` is the RBF kernel parameter.

The search settings are:

| Item | Value |
|---|---|
| Dimension | 2 |
| Lower bound | `[1, 1]` |
| Upper bound | `[20, 20]` |
| Population size | 30 |
| Maximum iterations | 100 |
| Runs per algorithm | 30 |

Original integration in `main_cv_30_compare_stats.m`:

```matlab
fobj = @(x) funcv(x, Pn, T);
[Best_score, Best_pos, curve] = feval(algorithm, pop, Max_time, lb, ub, dim, fobj);
[ACC, MCC, Sensitivity, Specificity] = performCV(Pn, T, Best_pos(1), Best_pos(2), 'rbf');
```

Thus, the optimization algorithm supplies candidate `[C, S]` values, `funcv.m` evaluates their KELM validation accuracy, and the best `[C, S]` is finally evaluated by 10-fold cross-validation.

## 7. Fitness Function Details

The original fitness function is:

```text
01_KELM_bankruptcy/code_and_data/path_kelm/funcv.m
```

For each candidate parameter vector `x = [C, S]`, `funcv.m` performs 5-fold cross-validation:

```matlab
K = 5;
cvIndices = crossvalind('Kfold', T(1,:), K);
```

For each fold:

1. The current fold is used as the test set.
2. The other folds are used as the training set.
3. KELM is trained with the candidate `C` and `S`.
4. The trained KELM predicts the test fold.
5. The fold accuracy is calculated.
6. The five fold accuracies are averaged.

The fitness value is:

```matlab
avgAccTestCV = mean(acc_test_cv);
fitness = 1 - avgAccTestCV;
```

Therefore:

- the optimizer minimizes `fitness`;
- lower fitness means higher 5-fold average validation accuracy;
- `BestScore` is the minimum fitness found by the optimizer;
- `Best_pos(1)` is the selected `C`;
- `Best_pos(2)` is the selected kernel parameter `S`.

The seed-controlled script `run_bankreshape_metrics_runtime_rankings.m` uses the same fitness definition but fixes the fold IDs inside each run:

```matlab
fitnessFoldId = crossvalind('Kfold', classLabels, fitnessKFolds);
fitnessFunction = @(params) kelmAccuracyFitness(params, normalizedFeatures, oneHotLabels, fitnessFoldId);
```

This keeps the definition as `1 - 5-fold average accuracy` while improving traceability and fair paired comparison across algorithms.

## 8. Training/Test Split Details

The fold-level split follows the original `funcv.m` logic:

```matlab
testIdx = (cvIndices == i);
trainIdx = ~testIdx;

p_train_cv = P(:, trainIdx);
T_train_cv = T(:, trainIdx);
p_test_cv = P(:, testIdx);
T_test_cv = T(:, testIdx);
```

For every fold, KELM is retrained on the training folds and evaluated on the held-out test fold. The model from one fold is not reused in another fold.

KELM training:

```matlab
[~, InputWeight] = kelmTrain(p_train_cv, T_train_cv, Regularization_coefficient, Kernel_type, Kernel_para);
```

KELM prediction:

```matlab
predictValue_test_cv = kelmPredict(p_train_cv, InputWeight, Kernel_type, Kernel_para, p_test_cv);
```

Predicted labels are obtained by the maximum response:

```matlab
[~, sim_test_cv] = max(predictValue_test_cv, [], 1);
[~, T_test1_cv] = max(T_test_cv, [], 1);
```

## 9. Final Four-Metric Evaluation

After the optimizer finds the best `[C, S]`, final metrics are computed by 10-fold cross-validation:

```matlab
[ACC, MCC, Sensitivity, Specificity] = performCV(Pn, T, Best_pos(1), Best_pos(2), 'rbf');
```

In the seed-controlled script, this is implemented by:

```matlab
metricFoldId = crossvalind('Kfold', classLabels, metricKFolds);
[accValue, mccValue, sensitivityValue, specificityValue] = evaluateKelmMetrics(...);
```

where `metricKFolds = 10`.

For each fold, a confusion matrix is built and four metrics are calculated:

```matlab
ACC = (TP + TN) / (TP + FP + FN + TN);
MCC = (TP * TN - FP * FN) / sqrt((TP + FP) * (TP + FN) * (TN + FP) * (TN + FN));
Sensitivity = TP / (TP + FN);
Specificity = TN / (TN + FP);
```

The confusion-matrix terms are defined as follows:

| Term | Meaning |
|---|---|
| TP | True Positive |
| TN | True Negative |
| FP | False Positive |
| FN | False Negative |

In the MATLAB implementation, the four values are obtained from the fold-level confusion matrix:

```matlab
confusionMatrix = confusionmat(trueLabels, predictedLabels, 'Order', 1:nClasses);

TP = confusionMatrix(1, 1);
TN = confusionMatrix(2, 2);
FP = confusionMatrix(1, 2);
FN = confusionMatrix(2, 1);
```

The 10 fold-level metric values are averaged:

- ACC is reported as a percentage;
- Sensitivity is reported as a percentage;
- Specificity is reported as a percentage;
- MCC is reported as a coefficient.

The four-metric results are stored in the following files:

| File | Content |
|---|---|
| `01_KELM_bankruptcy/latest_results_20260529_081806/bankreshape_summary_four_metrics_runtime.csv` | Mean, standard deviation, and ranking of ACC, MCC, Sensitivity, and Specificity |
| `01_KELM_bankruptcy/latest_results_20260529_081806/bankreshape_raw_runs_with_seed.csv` | Per-run ACC, MCC, Sensitivity, and Specificity with Algorithm, Run, and Seed |
| `01_KELM_bankruptcy/latest_results_20260529_081806/bankreshape_metrics_runtime_rankings.xlsx` | Excel workbook containing the Summary and Raw_Runs sheets |
| `01_KELM_bankruptcy/original_main_cv_outputs/PerformanceMetricsStatistics.xlsx` | Original four-metric statistics generated by `main_cv_30_compare_stats.m` |

## 10. Random Seed and Runtime Recording

The seed-controlled script uses:

```matlab
seedBase = 20260529;
seedValue = seedBase + runIdx;
seedCol(rowIdx) = seedValue;
rng(seedValue, 'twister');
```

Thus:

```text
Seed = 20260529 + Run
```

Examples:

| Run | Seed |
|---:|---:|
| 1 | 20260530 |
| 2 | 20260531 |
| 30 | 20260559 |

Runtime is recorded as:

| Field | Meaning |
|---|---|
| `OptimizationRuntimeSeconds` | Time used by the optimizer to search for `[C, S]` |
| `EvaluationRuntimeSeconds` | Time used to evaluate final KELM metrics with the best `[C, S]` |
| `TotalRuntimeSeconds` | Total time for one algorithm-run |

The runtime results are stored in the following files:

| File | Content |
|---|---|
| `01_KELM_bankruptcy/latest_results_20260529_081806/bankreshape_summary_four_metrics_runtime.csv` | Algorithm-level runtime mean, standard deviation, total runtime, and runtime rank |
| `01_KELM_bankruptcy/latest_results_20260529_081806/runtime_details/bankreshape_all_single_run_times_with_seed.csv` | Per-run runtime with Algorithm, Run, Seed, Status, optimization time, evaluation time, and total time |
| `01_KELM_bankruptcy/latest_results_20260529_081806/runtime_details/bankreshape_average_runtime_by_algorithm.csv` | Average runtime statistics for each algorithm |
| `01_KELM_bankruptcy/latest_results_20260529_081806/bankreshape_ranking_Runtime.csv` | Runtime ranking sorted by average total runtime |
| `01_KELM_bankruptcy/latest_results_20260529_081806/bankreshape_metrics_runtime_rankings.xlsx` | Excel sheets `Rank_Runtime`, `Runtime_Raw`, and `Runtime_Average` |

The latest included raw result file with reconstructed seed is:

```text
01_KELM_bankruptcy/latest_results_20260529_081806/bankreshape_raw_runs_with_seed.csv
```

## 11. Included Latest Results

Latest included result directory:

```text
01_KELM_bankruptcy/latest_results_20260529_081806
```

Main result file:

```text
bankreshape_summary_four_metrics_runtime.csv
```

Four-metric summary:

| Algorithm | ACC Mean ± Std | ACC Rank | MCC Mean ± Std | MCC Rank | Sensitivity Mean ± Std | Sens Rank | Specificity Mean ± Std | Spec Rank |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| QHDBO | 74.1175 ± 2.1002 | 12 | 0.4894 ± 0.0426 | 12 | 71.8756 ± 2.1436 | 12 | 77.6564 ± 2.3061 | 12 |
| IDBO | 76.8365 ± 3.1664 | 2 | 0.5439 ± 0.0634 | 2 | 74.9362 ± 3.3186 | 2 | 80.0771 ± 3.1476 | 2 |
| DBO | 75.8318 ± 2.1502 | 8 | 0.5238 ± 0.0426 | 8 | 73.8757 ± 2.3284 | 8 | 79.1307 ± 2.1205 | 8 |
| WOA | 75.9263 ± 1.8214 | 4 | 0.5257 ± 0.0364 | 4 | 74.0012 ± 2.1454 | 5 | 79.2131 ± 1.7748 | 4 |
| GWO | 75.9135 ± 2.0947 | 5 | 0.5255 ± 0.0418 | 5 | 74.0019 ± 2.3371 | 4 | 79.1974 ± 2.0820 | 5 |
| HHO | 75.5681 ± 1.9716 | 9 | 0.5184 ± 0.0396 | 9 | 73.7113 ± 2.3133 | 9 | 78.7668 ± 1.9087 | 9 |
| EVO | 75.8985 ± 2.1122 | 6 | 0.5252 ± 0.0420 | 6 | 73.9726 ± 2.3591 | 6 | 79.1896 ± 2.0614 | 7 |
| PO | 75.8979 ± 1.9741 | 7 | 0.5251 ± 0.0396 | 7 | 73.9414 ± 2.2340 | 7 | 79.1970 ± 2.0105 | 6 |
| NRBO | 75.9807 ± 1.7376 | 3 | 0.5267 ± 0.0349 | 3 | 74.0610 ± 2.0759 | 3 | 79.2513 ± 1.7037 | 3 |
| CPO | 74.9821 ± 1.7819 | 10 | 0.5073 ± 0.0346 | 10 | 72.9049 ± 2.1291 | 10 | 78.4936 ± 1.6075 | 11 |
| SWO | 74.9159 ± 1.9097 | 11 | 0.5061 ± 0.0379 | 11 | 72.7705 ± 2.2206 | 11 | 78.5124 ± 1.8716 | 10 |
| MSDBO | 82.2468 ± 1.5252 | 1 | 0.6534 ± 0.0311 | 1 | 80.4759 ± 2.0525 | 1 | 85.5325 ± 1.8809 | 1 |

Runtime summary:

| Algorithm | Optimization Runtime Mean ± Std (s) | Total Runtime Mean ± Std (s) | Total Runtime Sum (s) | Runtime Rank |
|---|---:|---:|---:|---:|
| QHDBO | 13.9953 ± 1.0512 | 14.0122 ± 1.0544 | 420.3650 | 5 |
| IDBO | 26.6945 ± 0.4122 | 26.7063 ± 0.4122 | 801.1889 | 10 |
| DBO | 15.0020 ± 2.3066 | 15.0146 ± 2.3069 | 450.4366 | 8 |
| WOA | 14.7164 ± 1.0291 | 14.7291 ± 1.0304 | 441.8740 | 7 |
| GWO | 14.1861 ± 0.8845 | 14.1996 ± 0.8846 | 425.9874 | 6 |
| HHO | 33.5935 ± 1.4649 | 33.6057 ± 1.4653 | 1008.1701 | 11 |
| EVO | 20.8136 ± 6.7060 | 20.8259 ± 6.7063 | 624.7783 | 9 |
| PO | 390.7535 ± 14.5433 | 390.7662 ± 14.5446 | 11722.9862 | 12 |
| NRBO | 13.2236 ± 0.1401 | 13.2367 ± 0.1410 | 397.1002 | 4 |
| CPO | 0.6846 ± 0.0425 | 0.6968 ± 0.0425 | 20.9034 | 2 |
| SWO | 0.6689 ± 0.0338 | 0.6806 ± 0.0338 | 20.4168 | 1 |
| MSDBO | 12.5012 ± 0.4235 | 12.5128 ± 0.4237 | 375.3854 | 3 |

## 12. Result Interpretation

MSDBO ranks first on all four classification metrics:

- ACC Mean = 82.2468;
- MCC Mean = 0.6534;
- Sensitivity Mean = 80.4759;
- Specificity Mean = 85.5325.

Its mean total runtime is 12.5128 seconds, ranking third among the compared algorithms. Although SWO and CPO are faster, their classification metrics are substantially lower. Therefore, MSDBO provides the best overall classification performance while keeping runtime acceptable.

Compared with IDBO, the second-ranked method by classification performance:

| Metric | MSDBO | IDBO | Difference |
|---|---:|---:|---:|
| ACC Mean | 82.2468 | 76.8365 | +5.4102 |
| MCC Mean | 0.6534 | 0.5439 | +0.1095 |
| Sensitivity Mean | 80.4759 | 74.9362 | +5.5397 |
| Specificity Mean | 85.5325 | 80.0771 | +5.4555 |
| Total Runtime Mean(s) | 12.5128 | 26.7063 | -14.1934 |

## 13. Short Reviewer-Facing Answers

### Q1. Does the shared code link include the complete implementation of MSDBO, KELM, and their integration?

Yes. The repository includes the MSDBO optimizer, the KELM training and prediction code, the fitness function linking MSDBO to KELM, the final cross-validation evaluation code, comparison algorithms, the dataset, and generated result files. It is not limited to partial modules.

### Q2. Is the provided code sufficient to reproduce the reported bankruptcy prediction results, including tables and figures?

Yes. The latest metric and runtime tables can be regenerated with `run_bankreshape_metrics_runtime_rankings.m`. The original performance-statistics table and figure workflow can be regenerated with `main_cv_30_compare_stats.m`. Already generated outputs are also included under `latest_results_20260529_081806` and `original_main_cv_outputs`.

### Q3. Does the repository include execution instructions, dependencies, and environment specifications?

Yes. This README lists the repository structure, main files, MATLAB execution commands, required toolboxes, preprocessing procedure, training/testing split, fitness function, four-metric evaluation formulas, random seed handling, runtime recording, and expected output files.
