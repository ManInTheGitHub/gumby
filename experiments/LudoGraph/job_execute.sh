#!/bin/bash

# In order to make YARN related scripts work -> script setttings.sh has to be EDITED for Jenkins

# sanity check
if [ $# -ne 2 ]; then
    echo "REQ: config and datset (dataset HAS to match config defined dataset)"
    exit
fi

config=$1
echo "CONFIG: $config"
dataset=$2
echo "dataset $dataset"
timeout=600 # 10min timeout per job
echo "timeout: $timeout"

echo "@DEBUG For larger datasets increase timeout (current 10min) or use ARG :)"

. ./jenkinsSettings.sh

echo "STARTING YARN (11 nodes [10 workers])"
./jenkins-start-yarn.sh 11 # &>/dev/null

Master=`cat $HADOOP_MASTERS`
echo "RM.ip is: $Master"

echo "Uploading dataset: $dataset"
./jenkinsClient.sh dfs -copyFromLocal $dataset / &>/dev/null

echo "Running JOB: $config with 10 workers each 10GB including AM"
isTerminated=false
T_S="$(date +%s)"

# start job
./jenkinsClient.sh jar ../LudoGraph-dist-1.0-SNAPSHOT-all-jar.jar org.tudelft.ludograph.mock.debug.pregel.Pregel_XML_DEBUG_DRIVER_v2 ../LudoGraph-dist-1.0-SNAPSHOT-all-jar.jar 10 10000 10000 das4 $config $Master

#get jobID
line=`./jenkinsListJobs.sh 2>/dev/null | sed -n -e '3{p;q}'`
jobID=( $line )
echo "jobID: $jobID"

while [ "$isTerminated" = false ]
do
    sleep 1
    jobsActive=`./jenkinsListJobs.sh 2>/dev/null | wc -l`

    # check if job is still active
    if [ "$jobsActive" -eq "2" ]
    then
	isTerminated=true
    fi

    #check timeout
    timestamp="$(date +%s)"
    jobDuration="$(($timestamp-T_S))"
    if [ "$jobDuration" -gt "$timeout" ]
    then
	echo "JOB TIMEOUT !!! (terminating)"
	isTerminated=true
    fi
done

T_E="$(date +%s)"

echo "Job FINISHED"
T_F="$(($T_E-T_S))"
echo "Turn Around Time in seconds: ${T_F} INACCURATE WITH YARN TIME -> use YARN TIME"

# Determine job OUTCOME 
outcome=`./jenkinsAppStatus.sh $jobID 2>/dev/null | sed -n -e '11{p;q}' | awk '{print $3}'`
echo "JOB result: $outcome"

# TODO YARN TIME
#yarnTS=`./jenkinsAppStatus.sh $jobID | sed -n -e '7{p;q}' | awk '{print $3}'`
#yarnTE=`./jenkinsAppStatus.sh $jobID | sed -n -e '8{p;q}' | awk '{print $3}'`
#echo "YARN_TIME: $yarnTime"

echo "SHUTTING DOWN YARN"
./jenkins-stop-yarn.sh &>/dev/null

echo "JENKINS JOB EXECUTION -> THE END"
