#!/bin/bash
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=1
#SBATCH --time=0-00:01
#SBATCH --job-name=test_job
#SBATCH --output=%x-%j.out

echo 'Starting job...'
echo "Running with params: $NUMBER_GPU $CONFIG"
sleep 120
echo 'Job ended.'
