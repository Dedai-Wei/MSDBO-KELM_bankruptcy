@echo off
setlocal
cd /d "%~dp0"
echo Running bankreshape 12-algorithm KELM metrics/runtime rerun...
echo Logs: run_bankreshape_metrics_runtime_rankings.stdout.log and run_bankreshape_metrics_runtime_rankings.stderr.log
echo Result folder pattern: result_metrics_runtime_rankings_YYYYMMDD_HHMMSS
echo Live progress file: progress_log.txt inside the newest result folder
matlab -batch "run('run_bankreshape_metrics_runtime_rankings.m')" 1> "run_bankreshape_metrics_runtime_rankings.stdout.log" 2> "run_bankreshape_metrics_runtime_rankings.stderr.log"
if errorlevel 1 (
    echo MATLAB run failed. Please check run_bankreshape_metrics_runtime_rankings.stderr.log
    exit /b %errorlevel%
)
echo Finished. Please check the newest result_metrics_runtime_rankings_* folder.
endlocal
