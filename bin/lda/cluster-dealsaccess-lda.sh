#!/bin/bash

source ${SCOUT_HOME}/bin/mysql.conf

HADOOP=hadoop
WORK_DIR=${SCOUT_HOME}/dataset
SCOUT=${SCOUT_HOME}/bin/scout

#DIRECTORY SETTINGS
#seqdirectory
DATASET_DIR=dealsaccess-source
SEQ_DIR=dealsaccess-out-seqdir
#seq2sparse
SEQ2SPARSE_DIR=dealsaccess-out-seqdir-sparse-lda
DF_COUNT_DIR=${SEQ2SPARSE_DIR}/df-count
DICTIONARY_FILE=${SEQ2SPARSE_DIR}/dictionary.file-0
FREQUENCY_FILE=${SEQ2SPARSE_DIR}/frequency.file-0
TFVECTORS_DIR=${SEQ2SPARSE_DIR}/tf-vectors
TFIDFVECTORS_DIR=${SEQ2SPARSE_DIR}/tfidf-vectors
TOKENIZED_DOCUMENTS_DIR=${SEQ2SPARSE_DIR}/tokenized-documents
WORDCOUNT_DIR=${SEQ2SPARSE_DIR}/wordcount
#rowid
ROWID_MATRIX_DIR=dealsaccess-out-matrix
#cvb
DICTIONARY_FILES=${SEQ2SPARSE_DIR}/dictionary.file-*
LDA_DIR=dealsaccess-lda
LDA_TOPICS_DIR=dealsaccess-lda-topics
LDA_MODEL_DIR=dealsaccess-lda-model

#import data from mysql to hdfs
${SCOUT_HOME}/bin/sqoop_mysql_dumper.sh

#seqdirectory
hadoop dfs -rmr ${WORK_DIR}/${SEQ_DIR}
$SCOUT seqdirectory -i ${WORK_DIR}/${DATASET_DIR} -o ${WORK_DIR}/${SEQ_DIR} -c UTF-8 -chunk 64 -ow -xm sequential --fileFilterClass ca.dealsaccess.scout.analyzer.DealsAnalyzerFilter

#seq2sparse
hadoop dfs -rmr ${WORK_DIR}/${SEQ2SPARSE_DIR}
$SCOUT seq2sparse -i ${WORK_DIR}/${SEQ_DIR} -o ${WORK_DIR}/${SEQ2SPARSE_DIR} -ow --maxDFPercent 85 --namedVector

#rowid
hadoop dfs -rmr ${WORK_DIR}/${ROWID_MATRIX_DIR}
$SCOUT rowid -i ${WORK_DIR}/${TFIDFVECTORS_DIR} -o ${WORK_DIR}/${ROWID_MATRIX_DIR}

#cvb
hadoop dfs -rmr ${WORK_DIR}/${LDA_DIR}
hadoop dfs -rmr ${WORK_DIR}/${LDA_TOPICS_DIR}
hadoop dfs -rmr ${WORK_DIR}/${LDA_MODEL_DIR}

$SCOUT cvb -i ${WORK_DIR}/${ROWID_MATRIX_DIR}/matrix -o ${WORK_DIR}/${LDA_DIR} -k 20 -ow -x 20 -dict ${WORK_DIR}/${DICTIONARY_FILES} -dt ${WORK_DIR}/${LDA_TOPICS_DIR} -mt ${WORK_DIR}/${LDA_MODEL_DIR}

#export data from hdfs to mysql
$SCOUT labeldeals -i ${WORK_DIR}/${LDA_TOPICS_DIR} --docIndex ${WORK_DIR}/${ROWID_MATRIX_DIR}/docIndex --jdbcurl ${jdbcurl} --username ${username} --password ${password} -n 5




