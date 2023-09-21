#!/bin/bash
#
#SBATCH --gres=gpu:3
#SBATCH --job-name=jupyterlab
#SBATCH --mail-type=NONE
#SBATCH --mem=64GB
#SBATCH --nodes=1
#SBATCH --output=/home/%u/slurmlogs/%x.log
#SBATCH --partition=spgpu
#SBATCH --time=12:00:00

env=ml
port=8890

eval "$(micromamba shell hook --shell bash)"

micromamba activate ml
python -Xfrozen_modules=off -m jupyterlab_server --no-browser --ip 0.0.0.0 --port "${port}"
