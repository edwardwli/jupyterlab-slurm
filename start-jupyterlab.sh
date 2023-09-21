#!/usr/bin/env sh

usage() {
  echo "Usage: $0 slurm_script"
}

get_info() {
  scontrol show job "${job}"
}

get_node() {
  sed -n 's/.* NodeList=\([[:alnum:]]*\)$/\1/p'
}

get_log() {
  sed -n 's/.* StdOut=\(.*\)/\1/p'
}

if [ "$#" -ne 1 ]
then
  usage >&2
  exit 1
fi

job=$1

while [ -z "$(get_info | get_node)" ]
do
  sleep 1
done

info=$(get_info)

node=$(echo "${info}" | get_node)
echo "node = ${node}"

log=$(echo "${info}" | get_log)
echo "log = ${log}"

while ! [ -f "${log}" ] || ! grep -Fq "127.0.0.1" "${log}"
do
  sleep 1
done

port=$(sed -n 's/.*127.0.0.1:\([[:digit:]]*\).*/\1/p' "${log}")
echo "port = ${port}"
