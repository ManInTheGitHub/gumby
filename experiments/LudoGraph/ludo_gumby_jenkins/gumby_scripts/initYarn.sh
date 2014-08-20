#! /bin/bash 

HADOOP_HOME=$1
CONF=$2
echo "$HADOOP_HOME"
echo "$CONF"

export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")

echo "@@@ FORMAT NameNode @@@"
$HADOOP_HOME/bin/hadoop --config $CONF namenode -format

echo "@@@ START YARN @@@"
$HADOOP_HOME/sbin/start-all.sh
#$HADOOP_HOME/bin/./start-dfs.sh
#$HADOOP_HOME/bin/./start-mapred.sh

# CRAP to much work to start manual every node -> switch to automated start-*.sh
#$HADOOP_HOME/sbin/hadoop-daemon.sh start namenode
#$HADOOP_HOME/sbin/hadoop-daemon.sh start datanode
#$HADOOP_HOME/sbin/yarn-daemon.sh start resourcemanager
#$HADOOP_HOME/sbin/yarn-daemon.sh start nodemanager
#$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver

#$HADOOP_HOME/sbin/start-dfs.sh
#$HADOOP_HOME/sbin/start-yarn.sh
echo "@@@ YARN STARTED @@@"
