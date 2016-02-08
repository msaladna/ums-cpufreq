#!/bin/sh

BINNAME=$(basename $0)
declare -x PIDCONTROL="/tmp/ums-worker.pid"
shopt -s execfail

function resetCPU {
    MODE=${1:-ondemand}
    for i in /sys/devices/system/cpu/cpu[0-9]* ; do
        echo $MODE > ${i}/cpufreq/scaling_governor
    done
    if [[ $MODE = "ondemand" ]] ; then
        kill -14 $(cat $PIDCONTROL) 2> /dev/null
        exit
    fi
    echo "$$" >> $PIDCONTROL
}

trap resetCPU EXIT
export -f resetCPU
renice -20 $$ > /dev/null
TMPFILE=/tmp/status.$$
ARGS=(`which $BINNAME`)
ARGS+=("$@")
i=0
n=${#ARGS[*]}
OLDIFS=$IFS
IFS=""
while [[ $i -lt $n ]] ; do
    ARGS[$i]=`printf "%q" ${ARGS[$i]}`
    let i++
done
IFS=$OLDIFS
(exec sh  3<< SCRIPT 4<&0 <&3
    resetCPU performance
    exec ${ARGS[@]}
    exit 0
    exec 3>&- <&4
SCRIPT
)
exec 4>&-
[[ -f $TMPFILE ]] && SYSEXIT=$(cat $TMPFILE) && rm $TMPFILE || SYSEXIT=0
exit ${SYSEXIT:-0}
