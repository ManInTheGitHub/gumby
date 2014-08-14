#!/bin/bash

set -e

# check for number of nodes
if [ $# -eq 0 ] 
  then
    echo "Number of computational nodes required"
    exit
fi

# load proper module
module load prun

# request nodes
preserve -np $1 -t 72:20:00
sleep 5

# get hosts array
nodesNr=`preserve -llist | grep $USER | awk '{print NF}'`
let "nodesNr -= 8"
index=9
for (( i=0; i<$nodesNr; i++ ))
do   
  hosts[$i]=`preserve -llist | grep $USER | awk -v col=$index '{print $col}'`
  let "index += 1"
done

# check if sufficient amount of nodes is available
if [ "${hosts[0]}" == "-" ]
  then
    echo "INSUFFICIENT AMOUNT OF NODES, WILL EXIT"
    qdel -u $USER
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