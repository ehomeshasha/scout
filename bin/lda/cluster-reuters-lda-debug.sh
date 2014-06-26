#!/bin/bash

HADOOP=hadoop
WORK_DIR=${SCOUT_HOME}/dataset
SCOUT=${SCOUT_HOME}/bin/scout

#set new log location
FORMAT_DATE=`date +%Y.%m.%d-%H:%M:%S`
LOGFILE="console-$1-$2-${FORMAT_DATE}.log"
DATE_DIR=`date +%Y%m%d`

mkdir -p ${HADOOP_HOME}/zzy/${DATE_DIR}
sed -i "s;\(log4j\.appender\.R\.File=\).*;\1${HADOOP_HOME}/zzy/${DATE_DIR}/${LOGFILE};" ${HADOOP_HOME}/conf/log4j.properties



cd $MAHOUT_HOME
#mvn clean install -Dmaven.test.skip=true
cp -f examples/target/mahout-examples-0.9-job.jar $SCOUT_HOME/lib/mahout/

cd $SCOUT_HOME

if [[ "x$2" != "xdebug" && "x$2" != "xsmall" ]];then

#seqdirectory
SOURCE_DIR=reuters-sgm
DATASET_DIR=reuters-out
SEQ_DIR=reuters-out-seqdir
#seq2sparse
SEQ2SPARSE_DIR=reuters-out-seqdir-sparse-lda
DF_COUNT_DIR=${SEQ2SPARSE_DIR}/df-count
DICTIONARY_FILE=${SEQ2SPARSE_DIR}/dictionary.file-0
FREQUENCY_FILE=${SEQ2SPARSE_DIR}/frequency.file-0
TFVECTORS_DIR=${SEQ2SPARSE_DIR}/tf-vectors
TFIDFVECTORS_DIR=${SEQ2SPARSE_DIR}/tfidf-vectors
TOKENIZED_DOCUMENTS_DIR=${SEQ2SPARSE_DIR}/tokenized-documents
WORDCOUNT_DIR=${SEQ2SPARSE_DIR}/wordcount
#rowid
ROWID_MATRIX_DIR=reuters-out-matrix
#cvb
DICTIONARY_FILES=${SEQ2SPARSE_DIR}/dictionary.file-*
LDA_DIR=reuters-lda
LDA_TOPICS_DIR=reuters-lda-topics
LDA_MODEL_DIR=reuters-lda-model


elif [ "x$2" = "xdebug" ];then

#seqdirectory
SOURCE_DIR=reuters-sgm-debug
DATASET_DIR=reuters-out-debug
SEQ_DIR=reuters-out-seqdir-debug
#seq2sparse
SEQ2SPARSE_DIR=reuters-out-seqdir-sparse-lda-debug
DF_COUNT_DIR=${SEQ2SPARSE_DIR}/df-count
DICTIONARY_FILE=${SEQ2SPARSE_DIR}/dictionary.file-0
FREQUENCY_FILE=${SEQ2SPARSE_DIR}/frequency.file-0
TFVECTORS_DIR=${SEQ2SPARSE_DIR}/tf-vectors
TFIDFVECTORS_DIR=${SEQ2SPARSE_DIR}/tfidf-vectors
TOKENIZED_DOCUMENTS_DIR=${SEQ2SPARSE_DIR}/tokenized-documents
WORDCOUNT_DIR=${SEQ2SPARSE_DIR}/wordcount
#rowid
ROWID_MATRIX_DIR=reuters-out-matrix-debug
#cvb
DICTIONARY_FILES=${SEQ2SPARSE_DIR}/dictionary.file-*
LDA_DIR=reuters-lda-debug
LDA_TOPICS_DIR=reuters-lda-topics-debug
LDA_MODEL_DIR=reuters-lda-model-debug

elif [ "x$2" = "xsmall" ];then

#seqdirectory
SOURCE_DIR=reuters-sgm-small
DATASET_DIR=reuters-out-small
SEQ_DIR=reuters-out-seqdir-small
#seq2sparse
SEQ2SPARSE_DIR=reuters-out-seqdir-sparse-lda-small
DF_COUNT_DIR=${SEQ2SPARSE_DIR}/df-count
DICTIONARY_FILE=${SEQ2SPARSE_DIR}/dictionary.file-0
FREQUENCY_FILE=${SEQ2SPARSE_DIR}/frequency.file-0
TFVECTORS_DIR=${SEQ2SPARSE_DIR}/tf-vectors
TFIDFVECTORS_DIR=${SEQ2SPARSE_DIR}/tfidf-vectors
TOKENIZED_DOCUMENTS_DIR=${SEQ2SPARSE_DIR}/tokenized-documents
WORDCOUNT_DIR=${SEQ2SPARSE_DIR}/wordcount
#rowid
ROWID_MATRIX_DIR=reuters-out-matrix-small
#cvb
DICTIONARY_FILES=${SEQ2SPARSE_DIR}/dictionary.file-*
LDA_DIR=reuters-lda-small
LDA_TOPICS_DIR=reuters-lda-topics-small
LDA_MODEL_DIR=reuters-lda-model-small
fi



set -x
if [ "x$1" = "xupload2dfs" ];then

$HADOOP dfs -rmr ${WORK_DIR}/${SOURCE_DIR}
$HADOOP dfs -rmr ${WORK_DIR}/${DATASET_DIR}
$HADOOP dfs -put ${WORK_DIR}/${SOURCE_DIR} ${WORK_DIR}/${SOURCE_DIR}
$HADOOP dfs -put ${WORK_DIR}/${DATASET_DIR} ${WORK_DIR}/${DATASET_DIR}

elif [ "x$1" = "xseqdirectory" ];then

########################
#  debug seqdirectory  #
########################

hadoop fs -rmr ${WORK_DIR}/${SEQ_DIR}

$SCOUT seqdirectory -i ${WORK_DIR}/${DATASET_DIR} -o ${WORK_DIR}/${SEQ_DIR} -c UTF-8 -chunk 64 -xm sequential

elif [ "x$1" = "xseq2sparse" ];then

######################
#  debug seq2sparse  #
######################

hadoop fs -rmr ${WORK_DIR}/${SEQ2SPARSE_DIR}

$SCOUT seq2sparse \
    -i ${WORK_DIR}/${SEQ_DIR}/ \
    -o ${WORK_DIR}/${SEQ2SPARSE_DIR} -ow --maxDFPercent 85 --namedVector \

elif [ "x$1" = "xrowid" ];then

#################
#  debug rowid  #
#################

hadoop fs -rmr ${WORK_DIR}/${ROWID_MATRIX_DIR}

$SCOUT rowid \
    -i ${WORK_DIR}/${TFIDFVECTORS_DIR} \
    -o ${WORK_DIR}/${ROWID_MATRIX_DIR} \
    
elif [ "x$1" = "xcvb" ];then

#rm -rf ${WORK_DIR}/reuters-lda ${WORK_DIR}/reuters-lda-topics ${WORK_DIR}/reuters-lda-model \

hadoop fs -rmr ${WORK_DIR}/${LDA_DIR}
hadoop fs -rmr ${WORK_DIR}/${LDA_TOPICS_DIR}
hadoop fs -rmr ${WORK_DIR}/${LDA_MODEL_DIR}

#/home/hadoop-user/scout_workspace/scout/bin/scout cvb -i /home/hadoop-user/scout_workspace/scout/dataset/reuters-out-matrix-debug/matrix -o /home/hadoop-user/#scout_workspace/scout/dataset/reuters-lda-debug -k 20 -ow -x 20 -dict /home/hadoop-user/scout_workspace/scout/dataset/reuters-out-seqdir-sparse-lda-debug/dictionary.file-0 #-dt /home/hadoop-user/scout_workspace/scout/dataset/reuters-lda-topics-debug -mt /home/hadoop-user/scout_workspace/scout/dataset/reuters-lda-model-debug
$SCOUT cvb \
    -i ${WORK_DIR}/${ROWID_MATRIX_DIR}/matrix \
    -o ${WORK_DIR}/${LDA_DIR} -k 20 -ow -x 20 \
    -dict ${WORK_DIR}/${DICTIONARY_FILES} \
    -dt ${WORK_DIR}/${LDA_TOPICS_DIR} \
    -mt ${WORK_DIR}/${LDA_MODEL_DIR} \

elif [ "x$1" = "xvectordump" ];then

rm -rf ${WORK_DIR}/${LDA_DIR}
mkdir -p ${WORK_DIR}/${LDA_DIR}

$SCOUT vectordump \
    -i ${WORK_DIR}/${LDA_TOPICS_DIR}/part-m-00000 \
    -o ${WORK_DIR}/${LDA_DIR}/vectordump \
    -vs 10 -p true \
    -d ${WORK_DIR}/${DICTIONARY_FILES} \
    -dt sequencefile -sort ${WORK_DIR}/${LDA_TOPICS_DIR}/part-m-00000 \

fi
