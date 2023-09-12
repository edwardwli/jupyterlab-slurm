# jupyterlab-slurm

## Setup
- Install `jupyterlab` and other packages you need with `conda` on greatlakes
- Modify `jupyterlab.slurm` for your configuration (e.g. `sbatch` options, environment name, etc.)
- Run `./copy-files.sh <uniqname>` to copy files to `~/jupyterlab-slurm` on greatlakes
- Optionally, add your uniqname to the top of `start.sh`

## Usage
- Run `./start.sh [uniqname]` and authenticate
- Go to the URL shown
- Enter `Ctrl-c` when done to clean up
