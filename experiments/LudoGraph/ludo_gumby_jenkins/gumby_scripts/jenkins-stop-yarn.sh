#!/bin/bash

# create settings
. ./jenkinsSettings.sh

#Connect to Master and stop
Master=`cat $HADOOP_MASTERS`
ssh $USER@$Master 'bash -s' < ./stopYarn.sh $HADOOP_HOME

# wait just in case
sleep 5

qdel -f $jobId || true

echo "THE END"
