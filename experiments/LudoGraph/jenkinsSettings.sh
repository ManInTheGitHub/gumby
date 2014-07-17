#!/bin/bash

# this is crappy solution SETS PATHS
export JAVA_HOME=/home/mbiczak/jdk1.7.0_17 # EDIT_ME
export PATH=$JAVA_HOME/bin:$PATH
export SCRIPTS="/home/mbiczak/Ludo_Yarn/scripts" # EDIT_ME
export TEMPLATE="$SCRIPTS/core-site.xml.template"
export YARN_TEMPLATE="$SCRIPTS/yarn-site.xml.template"


export HADOOP_HOME="/home/mbiczak/Ludo_Yarn/YARN/hadoop-2.4.1" # EDIT_ME
export HADOOP_YARN_HOME=$HADOOP_HOME
export HADOOP_TEMP_DIR="/local/hadoop.tmp.$USER" # HDFS local node DIR
export HADOOP_CONF="$HADOOP_HOME/etc/hadoop"
export HADOOP_CONF_CORE="$HADOOP_CONF/core-site.xml"
export HADOOP_CONF_YARN="$HADOOP_CONF/yarn-site.xml"
export HADOOP_MASTERS="$HADOOP_CONF/masters"
export HADOOP_SLAVES="$HADOOP_CONF/slaves"

