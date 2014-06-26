#!/bin/bash

WORK_DIR=${SCOUT_HOME}/dataset
$SCOUT=${SCOUT_HOME}/bin/scout

########################
#  debug seqdirectory  #
########################
set -x
hadoop fs -rmr /home/hadoop-user/scout_workspace/scout/dataset/reuters-out-seqdir-debug
hadoop fs -mkdir /home/hadoop-user/scout_workspace/scout/dataset/reuters-out-seqdir-debug

cd $MAHOUT_HOME
#mvn clean install -Dmaven.test.skip=true
cp -f examples/target/mahout-examples-0.9-job.jar $SCOUT_HOME/lib/mahout/



scout seqdirectory -i ${WORK_DIR}/reuters-out -o ${WORK_DIR}/reuters-out-seqdir-debug -c UTF-8 -chunk 64 -xm sequential


