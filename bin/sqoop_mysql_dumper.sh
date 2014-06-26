#!/bin/bash

source ${SCOUT_HOME}/bin/mysql.conf

HDFS_DIR=/home/hadoop-user/scout_workspace/scout/dataset/dealsaccess-source

hadoop dfs -rmr ${HDFS_DIR}



set -x



#import dw_groups
sqoop import --connect ${jdbcurl} \
	--username ${username} --password ${password} \
	--query "SELECT id,subject FROM dw_groups WHERE \$CONDITIONS" \
	--as-textfile \
	--delete-target-dir \
	--direct --direct-split-size 67108864 \
	--num-mappers 1 \
	--target-dir ${HDFS_DIR}/dw_groups \
	--fields-terminated-by "\t"

