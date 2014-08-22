#!/bin/bash

echo "###DEBUG jenkinsSettings.sh MIGHT require editing (YARN dist path, JAVA etc.)"

# this is crappy solution SETS PATHS
export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")
# export PATH=$JAVA_HOME/bin:$PATH
export TEMPLATE="core-site.xml.template"
export YARN_TEMPLATE="yarn-site.xml.template"


export HADOOP_HOME=${WORKSPACE}/yarn_dist/hadoop-dist/target/hadoop-3.0.0-SNAPSHOT
export HADOOP_YARN_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME
export HADOOP_TEMP_DIR="/local/hadoop.tmp.owvisser" # HDFS local node DIR TODO dirty hack
export HADOOP_CONF="$HADOOP_HOME/etc/hadoop"
export HADOOP_CONF_CORE="$HADOOP_CONF/core-site.xml"
export HADOOP_CONF_YARN="$HADOOP_CONF/yarn-site.xml"
export HADOOP_MASTERS="$HADOOP_CONF/masters"
export HADOOP_SLAVES="$HADOOP_CONF/slaves"

