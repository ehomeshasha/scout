#!/bin/bash
HADOOP=hadoop
WORK_DIR=${SCOUT_HOME}/dataset
SCOUT=${SCOUT_HOME}/bin/scout

OPEN_COMMAND=cat

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

if [ "x$1" = "xseqdirectory" ];then

#seqdirectory dumper
rm -rf ${WORK_DIR}/${SEQ_DIR}
mkdir -p ${WORK_DIR}/${SEQ_DIR}
$SCOUT seqdumper -i ${WORK_DIR}/${SEQ_DIR} -o ${WORK_DIR}/${SEQ_DIR}/chunk-0-dumper -n 10
#$OPEN_COMMAND ${WORK_DIR}/${SEQ_DIR}/chunk-0-dumper


fi
