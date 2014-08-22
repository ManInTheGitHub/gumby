#!/bin/bash

# Configures Yarn distribution and starts Yarn ALSO submits job and waits for its termination (or timeout)

set -e

# read reserved hosts array
hosts=($RESERVED_HOSTS)
hostsLn=${#hosts[@]}

# create settings
. ./jenkinsSettings.sh

# clean masters and slaves (Hadoop required files)
cat /dev/null > $HADOOP_CONF/masters
cat /dev/null > $HADOOP_CONF/slaves

# create masters and slaves (Hadoop required files)
for (( i=0; i<$hostsLn; i++ ))
do
  if [ $i -eq 0 ] # MASTER
    then
      echo "${hosts[$i]}" >$HADOOP_MASTERS
      continue
  fi
  # SLAVES
  echo "${hosts[$i]}" >>$HADOOP_SLAVES  
done

export Master=`cat $HADOOP_MASTERS`

# overwrite hadoop confs (not clean solution but I like the idea of "one conf to rule them all")
cp $TEMPLATE $HADOOP_CONF_CORE
# fill TEMPLATE dynamic "vars" (Master.Adr and Hadoop.TMP)
_HOSTNAME=$(echo "${Master}"|sed -e 's/\(\/\|\\\|&\)/\\&/g')
_HADOOP_TEMP_DIR=$(echo "${HADOOP_TEMP_DIR}"|sed -e 's/\(\/\|\\\|&\)/\\&/g')
sed -i "s/%%MASTER%%/$_HOSTNAME/g" $HADOOP_CONF_CORE
sed -i "s/%%HADOOP_TEMP_DIR%%/$_HADOOP_TEMP_DIR/g" $HADOOP_CONF_CORE

cp $HADOOP_CONF_CORE $HADOOP_CONF/mapred-site.xml
cp $HADOOP_CONF_CORE $HADOOP_CONF/hdfs-site.xml

cp $YARN_TEMPLATE $HADOOP_CONF_YARN
sed -i "s/%%MASTER%%/$_HOSTNAME/g" $HADOOP_CONF_YARN

# Connect to Master -> WARNING can use headNode HADOOP_HOME/bin/start-all // to samo dla stop (plus qdel -u $USER) i client
ssh $USER@$Master 'bash -s' < ./initYarn.sh $HADOOP_HOME $HADOOP_CONF

echo "@@@ Wait for 5s to allow all nodes to fully start (sometimes there is a little delay)."
sleep 5

echo "Start JOB"
echo "Currently supports ONLY: BFS, Components, Communities, Stats AND WebGraph, Citation, WikiTalk, amazon_302"

case "$Dataset" in
    ("Amazon_302")
        # for now fetching from mbiczak's home -> future @Large?
        dataset_file="/home/mbiczak/Ludo_Yarn/datasets/directed/amazon.302_FCF_TTTT"
        NODES="15"
        echo "USING 15 workers"
        case "$Algorithm" in
            ("BFS") 
                echo "Using bfs_amazon_302.xml"
                conf="../jenkins_conf/bfs/bfs_amazon_302.xml"
             ;;
            ("Communities") 
                echo "Using community_amazon_302.xml"
                conf="../jenkins_conf/communities/community_amazon_302.xml"
            ;;
            ("Components")
                echo "Using components_amazon_302.xml"
                conf="../jenkins_conf/components/components_amazon_302.xml"
            ;;
            ("Statistics") 
                echo "Using stats_amazon_302.xml"
                conf="../jenkins_conf/stats/stats_amazon_302.xml"
            ;;
            (*) 
                echo "Unknown Algorithm: $Algorithm crashing!"
                exit 1
            ;;
        esac
    ;;
    ("Citation")
        # for now fetching from mbiczak's home -> future @Large?
        dataset_file="/home/mbiczak/Ludo_Yarn/datasets/directed/Citation_FCF_TTTT"
        NODES="10"
        echo "USING 10 workers"
        case "$Algorithm" in
            ("BFS")
                echo "Using bfs_citation.xml"
                conf="../jenkins_conf/bfs/bfs_citation.xml"
            ;;
            ("Communities")
                echo "Using community_citation.xml"
                conf="../jenkins_conf/communities/community_citation.xml"
            ;;
            ("Components")
                echo "Using components_citation.xml"
                conf="../jenkins_conf/components/components_citation.xml"
            ;;
            ("Statistics")
                echo "Using stats_citation.xml"
                conf="../jenkins_conf/stats/stats_citation.xml"
            ;;
            (*)
                echo "Unknown Algorithm: $Algorithm crashing!"
                exit 1
            ;;
        esac
    ;;
    ("Webgraph")
        # for now fetching from mbiczak's home -> future @Large?
        dataset_file="/home/mbiczak/Ludo_Yarn/datasets/directed/WebGraph_FCF_TTTT"
        NODES="10"
        echo "USING 10 workers"
        case "$Algorithm" in
            ("BFS")
                echo "Using bfs_webgraph.xml"
                conf="../jenkins_conf/bfs/bfs_webgraph.xml"
            ;;
            ("Communities")
                echo "Using community_webgraph.xml"
                conf="../jenkins_conf/communities/community_webgraph.xml"
            ;;
            ("Components")
                echo "Using components_webgraph.xml"
                conf="../jenkins_conf/components/components_webgraph.xml"
            ;;
            ("Statistics")
                echo "Using stats_webgraph.xml"
                conf="../jenkins_conf/stats/stats_webgraph.xml"
            ;;
            (*)
                echo "Unknown Algorithm: $Algorithm crashing!"
                exit 1
            ;;
        esac
    ;;
    ("WikiTalk")
        # for now fetching from mbiczak's home -> future @Large?
        dataset_file="/home/mbiczak/Ludo_Yarn/datasets/directed/WikiTalk_FCF_TTTT"
        NODES="10"
        echo "USING 10 workers"
        case "$Algorithm" in
            ("BFS")
                echo "Using bfs_wikitalk.xml"
                conf="../jenkins_conf/bfs/bfs_wikitalk.xml"
            ;;
            ("Communities")
                echo "Using community_wikitalk.xml"
                conf="../jenkins_conf/communities/community_wikitalk.xml"
            ;;
            ("Components")
                echo "Using components_wikitalk.xml"
                conf="../jenkins_conf/components/components_wikitalk.xml"
            ;;
            ("Statistics")
                echo "Using stats_wikitalk.xml"
                conf="../jenkins_conf/stats/stats_wikitalk.xml"
            ;;
            (*)
                echo "Unknown Algorithm: $Algorithm crashing!"
                exit 1
            ;;
        esac
    ;;
    (*) 
        echo "Unknown Dataset: $Dataset crashing!"
        exit 1 
    ;;
esac

# upload data
./jenkinsClient.sh dfs -copyFromLocal $dataset_file / 

# run client
./jenkinsClient.sh jar $WORKSPACE/ludograph-dist/src/LudoGraph-dist/target/LudoGraph-dist-1.0-SNAPSHOT-all-jar.jar org.tudelft.ludograph.mock.debug.pregel.Pregel_XML_DEBUG_DRIVER_v2 $WORKSPACE/ludograph-dist/src/LudoGraph-dist/target/LudoGraph-dist-1.0-SNAPSHOT-all-jar.jar $NODES 10000 10000 das4 $conf $Master

# ---- "BLOCKING CLIENT" ----
#get jobID
#./jenkinsListJobs.sh

line=`./jenkinsListJobs.sh 2>/dev/null | sed -n -e '3{p;q}'`
jobID=( $line )
echo "jobID: $jobID"
isTerminated = false
timeout=600 # 10min timeout per job
T_S="$(date +%s)"

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

# Determine job OUTCOME.
outcome=`./jenkinsAppStatus.sh $jobID 2>/dev/null | sed -n -e '11{p;q}' | awk '{print $3}'`
echo "JOB result: $outcome"

