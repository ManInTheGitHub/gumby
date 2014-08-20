#!/bin/bash 

HADOOP_HOME=$1
echo "$HADOOP_HOME"

echo "@@@ STOP HADOOP @@@"
$HADOOP_HOME/sbin/stop-all.sh
#$HADOOP_HOME/bin/./stop-dfs.sh
#$HADOOP_HOME/bin/./stop-mapred.sh 
#$HADOOP_HOME/sbin/hadoop-daemon.sh stop namenode
#$HADOOP_HOME/sbin/hadoop-daemon.sh stop datanode
#$HADOOP_HOME/sbin/yarn-daemon.sh stop resourcemanager
#$HADOOP_HOME/sbin/yarn-daemon.sh stop nodemanager
#$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh stop historyserver

#$HADOOP_HOME/sbin/stop-dfs.sh
#$HADOOP_HOME/sbin/stop-yarn.sh