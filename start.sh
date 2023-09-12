#!/usr/bin/env sh

user=edwarli
host=greatlakes.arc-ts.umich.edu
location=${user}@${host}

# shellcheck disable=SC2016
start_script='${HOME}/src/scripts/slurm/start-jupyterlab.sh'
# shellcheck disable=SC2016
slurm_script='${HOME}/src/scripts/slurm/jupyterlab.slurm'

control_socket=~/.ssh/control_%r@%h:%p

big_message() {
  # shellcheck disable=2312
  printf "*%.0s" $(seq 1 80)
  echo
  echo
  echo "$1"
  echo
  # shellcheck disable=2312
  printf "*%.0s" $(seq 1 80)
  echo
}

big_message "ESTABLISHING_CONNECTION" >&2
ssh -fMN -S "${control_socket}" "${location}"

big_message "GETTING SERVER INFORMATION" >&2
start_log=$(ssh -S "${control_socket}" "${location}" "${start_script}" "${slurm_script}")
job=$(echo "${start_log}" | grep -F "job =" | sed -n 's/job = \(.*\)/\1/p')
node=$(echo "${start_log}" | grep -F "node =" | sed -n 's/node = \(.*\)/\1/p')
port=$(echo "${start_log}" | grep -F "port =" | sed -n 's/port = \(.*\)/\1/p')

big_message "JOBID = ${job}\nGO TO http://localhost:${port}\nKEEP THIS PROCESS RUNNING" >&2
ssh -N -S "${control_socket}" -L "${port}:${node}:${port}" "${location}"

big_message "STOPPING SERVER"
ssh -S "${control_socket}" "${location}" scancel "${job}"

big_message "SEVERING CONNECTION"
ssh -S "${control_socket}" -O exit "${location}"
