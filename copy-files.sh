#!/usr/bin/env sh

user=
host=greatlakes.arc-ts.umich.edu

usage() {
  echo "Usage: $0 <uniqname>"
}

if [ "$#" -ne 1 ] && [ -z "${user}" ]
then
  usage >&2
  exit 1
fi

if [ "$#" -eq 1 ]
then
  user=$1
fi

location=${user}@${host}

scp start-jupyterlab.sh jupyterlab.slurm "${location}:~/jupyterlab-slurm"
