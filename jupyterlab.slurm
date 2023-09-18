#!/bin/bash

#SBATCH --job-name=jupyterlab
#SBATCH --mail-type=NONE
#SBATCH --nodes=1
#SBATCH --mem=20GB
#SBATCH --partition=spgpu
#SBATCH --gpus=a40:1
#SBATCH --output=/home/%u/slurmlogs/%x.log

env=ml
port=8890

micromamba run --name "${env}" jupyter lab --no-browser --ip 0.0.0.0 --port "${port}"
