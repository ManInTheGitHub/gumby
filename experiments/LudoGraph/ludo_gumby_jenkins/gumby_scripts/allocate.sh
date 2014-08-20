#!/bin/bash

set -e

# check for number of nodes
if [ $# -eq 0 ] 
  then
    echo "1 - Number of computational nodes required."
    echo "2 - run_job script required."
    echo "3 - clean-up script required."
    exit
fi

# load proper module
module load prun

# clean up previous run left overs (if any)
qdel -u $USER || true

# request nodes
jobId=`preserve -np $1 -t 72:20:00 | awk 'NR==1 {print $3}' |  rev | cut -c 2- | rev`
echo "JobId: $jobId"
sleep 5

# get hosts array
nodesNr=`preserve -llist | grep $jobId | awk '{print NF}'`
let "nodesNr -= 8"
index=9
for (( i=0; i<$nodesNr; i++ ))
do   
  hosts[$i]=`preserve -llist | grep $jobId | awk -v col=$index '{print $col}'`
  let "index += 1"
done

# check if sufficient amount of nodes is available
if [ "${hosts[0]}" == "-" ]
  then
    echo "INSUFFICIENT AMOUNT OF NODES, WILL EXIT"
    qdel -f $jobId
    exit
fi

# create addresses of nodes
adrPrefix="10.141."
site=${HOSTNAME:2} # cluster site
for (( i=0; i<$nodesNr; i++ ))
do
  if [ "${hosts[$i]:5:1}" = "0" ]
    then
      adrs[$i]=$adrPrefix$site"."${hosts[$i]:6}
    else
      adrs[$i]=$adrPrefix$site"."${hosts[$i]:5}
  fi
done

export RESERVED_HOSTS=${adrs[*]}
echo Allocated nodes: ${RESERVED_HOSTS[*]}

echo "Running JOB"
cd gumby/experiments/LudoGraph/ludo_gumby_jenkins/gumby_scripts/
. ./$2

echo "STOPPING cluster"
. ./$3
