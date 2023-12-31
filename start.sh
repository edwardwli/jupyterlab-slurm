#!/usr/bin/env sh

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

# Put your username here if you don't want to specify it one the command line.
user=
host=greatlakes.arc-ts.umich.edu

start_script=start-jupyterlab.sh
slurm_script=jupyterlab.slurm

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
control_socket=~/.ssh/control_${location}

if [ ! -S "${control_socket}" ]
then
  big_message "ESTABLISHING CONNECTION" >&2
  ssh -fMN -S "${control_socket}" "${location}"
fi

big_message "STARTING SERVER" >&2
job=$(ssh -S "${control_socket}" "${location}" sbatch --parsable < "${slurm_script}")

big_message "GETTING SERVER INFORMATION" >&2
start_log=$(ssh -S "${control_socket}" "${location}" "sh -s" < "${start_script}" "${job}")
node=$(echo "${start_log}" | grep -F "node =" | sed -n 's/node = \(.*\)/\1/p')
port=$(echo "${start_log}" | grep -F "port =" | sed -n 's/port = \(.*\)/\1/p')
log=$(echo "${start_log}" | grep -F "log =" | sed -n 's/log = \(.*\)/\1/p')

big_message "JOBID = ${job}\n\nGO TO http://localhost:${port}\n\nENTER Ctrl-c TO STOP" >&2

big_message "PORT FORWARDING" >&2
ssh -S "${control_socket}" -L "${port}:${node}:${port}" "${location}" tail -f "${log}"

big_message "STOPPING SERVER"
ssh -S "${control_socket}" "${location}" scancel "${job}"

if [ -n "${master}" ]
then
  big_message "SEVERING CONNECTION"
  ssh -S "${control_socket}" -O exit "${location}"
fi
