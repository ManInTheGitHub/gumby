#! /bin/bash

# create settings
. ./jenkinsSettings.sh

$HADOOP_HOME/bin/hadoop $@
