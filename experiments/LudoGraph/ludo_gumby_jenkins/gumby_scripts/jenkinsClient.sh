#! /bin/bash

# create settings
. ./jenkinsSettings.sh

# LUDO execution envs
export LUDOGRAPH_LOGLEVEL=INFO
export LUDOGRAPH_LOGLEVEL_HADOOP=INFO

$HADOOP_HOME/bin/hadoop $@
