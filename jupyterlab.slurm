#!/bin/bash

#SBATCH --gpus=a40:4
#SBATCH --job-name=jupyterlab
#SBATCH --mail-type=NONE
#SBATCH --mem=64GB
#SBATCH --nodes=1
#SBATCH --output=/home/%u/slurmlogs/%x.log
#SBATCH --partition=spgpu
#SBATCH --time=12:00:00

env=ml
port=8890

micromamba run --name "${env}" jupyter lab --no-browser --ip 0.0.0.0 --port "${port}"
