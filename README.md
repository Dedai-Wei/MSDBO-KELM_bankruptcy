# MSDBO-KELM Bankruptcy Prediction Reproducibility Package

# KELM Bankruptcy Prediction Code

This repository is dedicated exclusively to the KELM-based bankruptcy prediction task. It contains the code associated with our neural network-based manuscript currently under submission, including the main implementation, experimental scripts, and supporting files required to reproduce the reported results. The repository has been prepared for manuscript revision, reproducibility assessment, and reviewer verification.

**Authors:** Dedai Wei, Kaichen Ouyang*, Zimo Wang, Xinye Sha, Yiran Xie, Minyu Qiu, Zongfan Yi, Huiling Chen*, and Guoxi Liang*

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
| Operating system | Windows 11 Home China (64-bit); Windows 10/11 compatible |
| Main software | MATLAB R2025a |
| MATLAB toolboxes | Statistics and Machine Learning Toolbox; Deep Learning Toolbox or Neural Network Toolbox |
| Spreadsheet support | MATLAB support for `.xlsx` read/write |
| External language dependencies | None |
| Hardware platform | Lenovo 82L5 machine |
| CPU | AMD Ryzen 5 5600H with Radeon Graphics, 6 cores / 12 logical processors, 3.30 GHz |
| Memory | 14.88 GB physical RAM |
| GPU | AMD Radeon(TM) Graphics (2 GB) and NVIDIA GeForce GTX 1650 (4 GB); the provided scripts do not require GPU acceleration |
| Convergence criterion | Each optimizer is run for a fixed maximum of 100 iterations (`maxIter = 100`); no additional early-stopping criterion is used in the provided scripts |
| Computing environment | CPU-based MATLAB execution only; no Python, R, or other external runtime is required |
| Experimental settings | Population size = 30, number of runs = 30, fitness evaluation = 5-fold CV, final metric evaluation = 10-fold CV, `seedBase = 20260529` |

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
x = [C, γ]
```

where:

- `C` is the KELM regularization coefficient;
- `γ` is the RBF kernel parameter.

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

For each candidate parameter vector `x = [C, γ]`, `funcv.m` performs 5-fold cross-validation:

```matlab
K = 5;
cvIndices = crossvalind('Kfold', T(1,:), K);
```

For each fold:

1. The current fold is used as the test set.
2. The other folds are used as the training set.
3. KELM is trained with the candidate `C` and `γ`.
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



## 11. Short Reviewer-Facing Answers

### Q1. Does the shared code link include the complete implementation of MSDBO, KELM, and their integration?

Yes. The repository includes the MSDBO optimizer, the KELM training and prediction code, the fitness function linking MSDBO to KELM, the final cross-validation evaluation code, comparison algorithms, the dataset, and generated result files. It is not limited to partial modules.

### Q2. Is the provided code sufficient to reproduce the reported bankruptcy prediction results, including tables and figures?

Yes. The latest metric and runtime tables can be regenerated with `run_bankreshape_metrics_runtime_rankings.m`. The original performance-statistics table and figure workflow can be regenerated with `main_cv_30_compare_stats.m`. Already generated outputs are also included under `latest_results_20260529_081806` and `original_main_cv_outputs`.

### Q3. Does the repository include execution instructions, dependencies, and environment specifications?

Yes. This README lists the repository structure, main files, MATLAB execution commands, required toolboxes, preprocessing procedure, training/testing split, fitness function, four-metric evaluation formulas, random seed handling, runtime recording, and expected output files.
