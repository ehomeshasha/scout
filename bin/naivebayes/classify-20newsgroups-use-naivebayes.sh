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
#SOURCE_DIR=20newsgroups-sgm
DATASET_DIR=20news-bydate
SEQ_DIR=20newsgroups-out-seqdir
#seq2sparse
SEQ2SPARSE_DIR=20newsgroups-out-vectors
DF_COUNT_DIR=${SEQ2SPARSE_DIR}/df-count
DICTIONARY_FILE=${SEQ2SPARSE_DIR}/dictionary.file-0
FREQUENCY_FILE=${SEQ2SPARSE_DIR}/frequency.file-0
TFVECTORS_DIR=${SEQ2SPARSE_DIR}/tf-vectors
TFIDFVECTORS_DIR=${SEQ2SPARSE_DIR}/tfidf-vectors
TOKENIZED_DOCUMENTS_DIR=${SEQ2SPARSE_DIR}/tokenized-documents
WORDCOUNT_DIR=${SEQ2SPARSE_DIR}/wordcount
#split
TRAIN_DIR=20newsgroups-train-vectors
TEST_DIR=20newsgroups-test-vectors
#trainnb
MODEL_DIR=20newsgroups-model
LABEL_INDEX_FILE=20newsgroups-labelindex/labelindex
#testnb-train
TRAIN_TESTING_DIR=20newsgroups-train-testing
#testnb-test
TEST_TESTING_DIR=20newsgroups-test-testing

elif [ "x$2" = "xdebug" ];then

#seqdirectory
#SOURCE_DIR=20newsgroups-sgm
DATASET_DIR=20news-bydate-debug
SEQ_DIR=20newsgroups-out-seqdir-debug
#seq2sparse
SEQ2SPARSE_DIR=20newsgroups-out-vectors-debug
DF_COUNT_DIR=${SEQ2SPARSE_DIR}/df-count
DICTIONARY_FILE=${SEQ2SPARSE_DIR}/dictionary.file-0
FREQUENCY_FILE=${SEQ2SPARSE_DIR}/frequency.file-0
TFVECTORS_DIR=${SEQ2SPARSE_DIR}/tf-vectors
TFIDFVECTORS_DIR=${SEQ2SPARSE_DIR}/tfidf-vectors
TOKENIZED_DOCUMENTS_DIR=${SEQ2SPARSE_DIR}/tokenized-documents
WORDCOUNT_DIR=${SEQ2SPARSE_DIR}/wordcount
#split
TRAIN_DIR=20newsgroups-train-vectors-debug
TEST_DIR=20newsgroups-test-vectors-debug
#trainnb
MODEL_DIR=20newsgroups-model-debug
LABEL_INDEX_FILE=20newsgroups-labelindex/labelindex-debug
#testnb-train
TRAIN_TESTING_DIR=20newsgroups-train-testing-debug
#testnb-test
TEST_TESTING_DIR=20newsgroups-test-testing-debug

elif [ "x$2" = "xsmall" ];then

#seqdirectory
#SOURCE_DIR=20newsgroups-sgm
DATASET_DIR=20news-bydate-small
SEQ_DIR=20newsgroups-out-seqdir-small
#seq2sparse
SEQ2SPARSE_DIR=20newsgroups-out-vectors-small
DF_COUNT_DIR=${SEQ2SPARSE_DIR}/df-count
DICTIONARY_FILE=${SEQ2SPARSE_DIR}/dictionary.file-0
FREQUENCY_FILE=${SEQ2SPARSE_DIR}/frequency.file-0
TFVECTORS_DIR=${SEQ2SPARSE_DIR}/tf-vectors
TFIDFVECTORS_DIR=${SEQ2SPARSE_DIR}/tfidf-vectors
TOKENIZED_DOCUMENTS_DIR=${SEQ2SPARSE_DIR}/tokenized-documents
WORDCOUNT_DIR=${SEQ2SPARSE_DIR}/wordcount
#split
TRAIN_DIR=20newsgroups-train-vectors-small
TEST_DIR=20newsgroups-test-vectors-small
#trainnb
MODEL_DIR=20newsgroups-model-small
LABEL_INDEX_FILE=20newsgroups-labelindex/labelindex-small
#testnb-train
TRAIN_TESTING_DIR=20newsgroups-train-testing-small
#testnb-test
TEST_TESTING_DIR=20newsgroups-test-testing-small
fi



set -x
if [ "x$1" = "xupload2dfs" ];then

$HADOOP dfs -rmr ${WORK_DIR}/${DATASET_DIR}
$HADOOP dfs -put ${WORK_DIR}/${DATASET_DIR} ${WORK_DIR}/${DATASET_DIR}

elif [ "x$1" = "xseqdirectory" ];then

########################
#  debug seqdirectory  #
########################

hadoop fs -rmr ${WORK_DIR}/${SEQ_DIR}

$SCOUT seqdirectory -i ${WORK_DIR}/${DATASET_DIR} -o ${WORK_DIR}/${SEQ_DIR} -ow

elif [ "x$1" = "xseq2sparse" ];then

######################
#  debug seq2sparse  #
######################

hadoop fs -rmr ${WORK_DIR}/${SEQ2SPARSE_DIR}

$SCOUT seq2sparse \
    -i ${WORK_DIR}/${SEQ_DIR}/ \
    -o ${WORK_DIR}/${SEQ2SPARSE_DIR} -lnorm -nv  -wt tfidf

elif [ "x$1" = "xsplit" ];then

#################
#  debug split  #
#################

hadoop fs -rmr ${WORK_DIR}/${TRAIN_DIR}
hadoop fs -rmr ${WORK_DIR}/${TEST_DIR}

$SCOUT split \
    -i ${WORK_DIR}/${TFIDFVECTORS_DIR} \
    --trainingOutput ${WORK_DIR}/${TRAIN_DIR} \
    --testOutput ${WORK_DIR}/${TEST_DIR}  \
    --randomSelectionPct 40 --overwrite --sequenceFiles -xm sequential
    
elif [ "x$1" = "xtrainnb" ];then

###################
#  debug trainnb  #
###################

hadoop fs -rmr ${WORK_DIR}/${MODEL_DIR}
hadoop fs -rmr ${WORK_DIR}/${LABEL_INDEX_FILE}

$SCOUT trainnb \
    -i ${WORK_DIR}/${TRAIN_DIR} -el \
    -o ${WORK_DIR}/${MODEL_DIR} \
    -li ${WORK_DIR}/${LABEL_INDEX_FILE} \
    -ow

elif [ "x$1" = "xtestnb-train" ];then

########################
#  debug testnb-train  #
########################

hadoop fs -rmr ${WORK_DIR}/${TRAIN_TESTING_DIR}

$SCOUT testnb \
    -i ${WORK_DIR}/${TRAIN_DIR} \
    -m ${WORK_DIR}/${MODEL_DIR} \
    -l ${WORK_DIR}/${LABEL_INDEX_FILE} \
    -ow -o ${WORK_DIR}/${TRAIN_TESTING_DIR}


elif [ "x$1" = "xtestnb-test" ];then

#######################
#  debug testnb-test  #
#######################

hadoop fs -rmr ${WORK_DIR}/${TEST_TESTING_DIR}

$SCOUT testnb \
    -i ${WORK_DIR}/${TEST_DIR} \
    -m ${WORK_DIR}/${MODEL_DIR} \
    -l ${WORK_DIR}/${LABEL_INDEX_FILE} \
    -ow -o ${WORK_DIR}/${TEST_TESTING_DIR}



fi
