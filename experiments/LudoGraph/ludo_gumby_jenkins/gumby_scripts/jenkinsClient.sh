#! /bin/bash

# create settings
. ./jenkinsSettings.sh

# LUDO execution envs
export LUDOGRAPH_LOGLEVEL=DEBUG
export LUDOGRAPH_LOGLEVEL_HADOOP=INFO
export LUDOGRAPH_LOGLEVEL_NETTY=INFO

$HADOOP_HOME/bin/hadoop $@
