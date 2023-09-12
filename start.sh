#!/usr/bin/env sh

user=
host=greatlakes.arc-ts.umich.edu

# shellcheck disable=SC2016
start_script='jupyterlab-slurm/start-jupyterlab.sh'
# shellcheck disable=SC2016
slurm_script='jupyterlab-slurm/jupyterlab.slurm'

control_socket=~/.ssh/control_%r@%h:%p

usage() {
  echo "Usage: $0 <uniqname>"
}

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

if [ "$#" -ne 1 ] && [ -z "${user}" ]
then
  usage >&2
  exit 1
fi

user=$1
location=${user}@${host}

big_message "ESTABLISHING_CONNECTION" >&2
ssh -fMN -S "${control_socket}" "${location}"

big_message "GETTING SERVER INFORMATION" >&2
start_log=$(ssh -S "${control_socket}" "${location}" "${start_script}" "${slurm_script}")
job=$(echo "${start_log}" | grep -F "job =" | sed -n 's/job = \(.*\)/\1/p')
node=$(echo "${start_log}" | grep -F "node =" | sed -n 's/node = \(.*\)/\1/p')
port=$(echo "${start_log}" | grep -F "port =" | sed -n 's/port = \(.*\)/\1/p')

big_message "JOBID = ${job}\nGO TO http://localhost:${port}\ENTER Ctrl-c TO STOP" >&2
ssh -N -S "${control_socket}" -L "${port}:${node}:${port}" "${location}"

big_message "STOPPING SERVER"
ssh -S "${control_socket}" "${location}" scancel "${job}"

big_message "SEVERING CONNECTION"
ssh -S "${control_socket}" -O exit "${location}"
