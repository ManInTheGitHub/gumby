#! /bin/bash

# create settings
. ./jenkinsSettings.sh

$HADOOP_HOME/bin/yarn application -status $1