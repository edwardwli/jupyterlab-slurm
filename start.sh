#!/usr/bin/env sh

user=edwarli
host=greatlakes.arc-ts.umich.edu

start_script=start-jupyterlab.sh
slurm_script=jupyterlab.slurm

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

if [ "$#" -eq 1 ]
then
  user=$1
fi

location=${user}@${host}

big_message "ESTABLISHING CONNECTION" >&2
ssh -fMN -S "${control_socket}" "${location}"

big_message "GETTING SERVER INFORMATION" >&2
job=$(ssh -S "${control_socket}" "${location}" sbatch < "${slurm_script}" | grep -F "Submitted batch job" | sed -n 's/Submitted batch job \([[:digit:]]*\)/\1/p')
start_log=$(ssh -S "${control_socket}" "${location}" "sh -s" < "${start_script}" "${job}")
node=$(echo "${start_log}" | grep -F "node =" | sed -n 's/node = \(.*\)/\1/p')
port=$(echo "${start_log}" | grep -F "port =" | sed -n 's/port = \(.*\)/\1/p')

big_message "JOBID = ${job}\nGO TO http://localhost:${port}\nENTER Ctrl-c TO STOP" >&2
ssh -S "${control_socket}" -N -L "${port}:${node}:${port}" "${location}"

big_message "STOPPING SERVER"
ssh -S "${control_socket}" "${location}" scancel "${job}"

big_message "SEVERING CONNECTION"
ssh -S "${control_socket}" -O exit "${location}"
