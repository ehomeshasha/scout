#!/bin/bash

WORK_DIR=${SCOUT_HOME}/dataset
SCOUT=${SCOUT_HOME}/bin/scout

OPEN_COMMAND=tail

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

OPEN_COMMAND=echo
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



if [ "x$1" = "xseqdirectory" ];then
###############################
#  debug seqdirectory dumper  #
###############################
#set -x
rm -rf ${WORK_DIR}/${SEQ_DIR}
mkdir -p ${WORK_DIR}/${SEQ_DIR}
$SCOUT seqdumper -i ${WORK_DIR}/${SEQ_DIR} -o ${WORK_DIR}/${SEQ_DIR}/chunk-0-dumper
$OPEN_COMMAND ${WORK_DIR}/${SEQ_DIR}/chunk-0-dumper

elif [ "x$1" = "xseq2sparse" ];then

#############################
#  debug seq2sparse dumper  #
#############################

rm -rf ${WORK_DIR}/${SEQ2SPARSE_DIR}
mkdir -p ${WORK_DIR}/${SEQ2SPARSE_DIR}
mkdir -p ${WORK_DIR}/${DF_COUNT_DIR}
mkdir -p ${WORK_DIR}/${TFVECTORS_DIR}
mkdir -p ${WORK_DIR}/${TFIDFVECTORS_DIR}
mkdir -p ${WORK_DIR}/${TOKENIZED_DOCUMENTS_DIR}
mkdir -p ${WORK_DIR}/${WORDCOUNT_DIR}

dumpdata=( all tokenized-documents word-count dictionary-file tf-vectors df-vectors frequency-file tfidf-vectors)
if [ -n "$3" ]; then
  choice=$3
else
  echo "Please select a number to choose the corresponding dump data"
  echo "0. all"
  echo "1. tokenized-documents"
  echo "2. word-count"
  echo "3. dictionary-file"
  echo "4. tf-vectors"
  echo "5. df-vectors"
  echo "6. frequency-file"
  echo "7. tfidf-vectors"
  read -p "Enter your choice : " choice
fi
echo "ok. You chose $choice and we'll dump ${dumpdata[$choice]}."
dumpdatatype=${dumpdata[$choice]}

press_cmd=""
if [ "x$dumpdatatype" = "xall" ];then
	press_cmd="read -p \"Press enter to dump next data\""
fi

if [[ "x$dumpdatatype" = "xall" || "x$dumpdatatype" = "xtokenized-documents" ]];then
#dump tokenized-documents
$SCOUT seqdumper -i ${WORK_DIR}/${TOKENIZED_DOCUMENTS_DIR} -o ${WORK_DIR}/${TOKENIZED_DOCUMENTS_DIR}/part-m-00000
echo -e "\n\n${WORK_DIR}/${TOKENIZED_DOCUMENTS_DIR}/part-m-00000 content:"
$OPEN_COMMAND ${WORK_DIR}/${TOKENIZED_DOCUMENTS_DIR}/part-m-00000 && eval ${press_cmd}
fi
if [[ "x$dumpdatatype" = "xall" || "x$dumpdatatype" = "xword-count" ]];then
#dump word-count
$SCOUT seqdumper -i ${WORK_DIR}/${WORDCOUNT_DIR} -o ${WORK_DIR}/${WORDCOUNT_DIR}/part-r-00000
echo -e "\n\n${WORK_DIR}/${WORDCOUNT_DIR}/part-r-00000 content:"
$OPEN_COMMAND ${WORK_DIR}/${WORDCOUNT_DIR}/part-r-00000 && eval ${press_cmd}
fi
if [[ "x$dumpdatatype" = "xall" || "x$dumpdatatype" = "xdictionary-file" ]]; then
#dump dictionary-file
$SCOUT seqdumper -i ${WORK_DIR}/${DICTIONARY_FILE} -o ${WORK_DIR}/${DICTIONARY_FILE}
echo -e "\n\n${WORK_DIR}/${DICTIONARY_FILE} content:"
$OPEN_COMMAND ${WORK_DIR}/${DICTIONARY_FILE} && eval ${press_cmd}
fi
if [[ "x$dumpdatatype" = "xall" || "x$dumpdatatype" = "xtf-vectors" ]]; then
#dump tf-vectors
$SCOUT seqdumper -i ${WORK_DIR}/${TFVECTORS_DIR} -o ${WORK_DIR}/${TFVECTORS_DIR}/part-r-00000
echo -e "\n\n${WORK_DIR}/${TFVECTORS_DIR}/part-r-00000 content:"
$OPEN_COMMAND ${WORK_DIR}/${TFVECTORS_DIR}/part-r-00000 && eval ${press_cmd}
fi
if [[ "x$dumpdatatype" = "xall" || "x$dumpdatatype" = "xdf-vectors" ]]; then
#dump df-vectors
$SCOUT seqdumper -i ${WORK_DIR}/${DF_COUNT_DIR} -o ${WORK_DIR}/${DF_COUNT_DIR}/part-r-00000
echo -e "\n\n${WORK_DIR}/${DF_COUNT_DIR}/part-r-00000 content:"
$OPEN_COMMAND ${WORK_DIR}/${DF_COUNT_DIR}/part-r-00000 && eval ${press_cmd}
fi
if [[ "x$dumpdatatype" = "xall" || "x$dumpdatatype" = "xfrequency-file" ]]; then
#dump frequency-file
$SCOUT seqdumper -i ${WORK_DIR}/${FREQUENCY_FILE} -o ${WORK_DIR}/${FREQUENCY_FILE}
echo -e "\n\n${WORK_DIR}/${FREQUENCY_FILE} content:"
$OPEN_COMMAND ${WORK_DIR}/${FREQUENCY_FILE} && eval ${press_cmd}
fi
if [[ "x$dumpdatatype" = "xall" || "x$dumpdatatype" = "xtfidf-vectors" ]]; then
#dump tfidf-vectors
$SCOUT seqdumper -i ${WORK_DIR}/${TFIDFVECTORS_DIR} -o ${WORK_DIR}/${TFIDFVECTORS_DIR}/part-r-00000
echo -e "\n\n${WORK_DIR}/${TFIDFVECTORS_DIR}/part-r-00000 content:"
$OPEN_COMMAND ${WORK_DIR}/${TFIDFVECTORS_DIR}/part-r-00000
fi

elif [ "x$1" = "xrowid" ];then

rm -rf ${WORK_DIR}/${ROWID_MATRIX_DIR}
mkdir -p ${WORK_DIR}/${ROWID_MATRIX_DIR}

$SCOUT seqdumper -i ${WORK_DIR}/${ROWID_MATRIX_DIR}/docIndex -o ${WORK_DIR}/${ROWID_MATRIX_DIR}/docIndex
$SCOUT seqdumper -i ${WORK_DIR}/${ROWID_MATRIX_DIR}/matrix -o ${WORK_DIR}/${ROWID_MATRIX_DIR}/matrix

echo -e "\n\n${WORK_DIR}/${ROWID_MATRIX_DIR}/docIndex content:"
$OPEN_COMMAND ${WORK_DIR}/${ROWID_MATRIX_DIR}/docIndex

echo -e "\n\n${WORK_DIR}/${ROWID_MATRIX_DIR}/matrix content:"
$OPEN_COMMAND ${WORK_DIR}/${ROWID_MATRIX_DIR}/matrix

elif [ "x$1" = "xcvb" ];then

dumpdata=( lda-model lda-topics lda)
if [ -n "$3" ]; then
  choice=$3
else
  echo "Please select a number to choose the corresponding dump data"
  echo "1. lda-model"
  echo "2. lda-topics"
  echo "3. lda"
  read -p "Enter your choice : " choice
fi
echo "ok. You chose $choice and we'll dump ${dumpdata[$choice-1]} data."
dumpdatatype=${dumpdata[$choice-1]}


if [ "x$dumpdatatype" = "xlda-model" ];then
#dump lda-model
echo "Please select a number to choose the corresponding model folder(1~20)"
read -p "Enter your number : " number
if [[ "${number}" -lt 1 || "${number}" -gt 20 ]];then
echo "number of model folder must be 1-20"
exit
fi
MODEL_FOLDER=${LDA_MODEL_DIR}/model-${number}

echo "ok. You'll dump data from ${WORK_DIR}/${MODEL_FOLDER}"

rm -rf ${WORK_DIR}/${MODEL_FOLDER}
mkdir -p ${WORK_DIR}/${MODEL_FOLDER}
$SCOUT seqdumper -i ${WORK_DIR}/${MODEL_FOLDER} -o ${WORK_DIR}/${MODEL_FOLDER}/part-r-00000
$OPEN_COMMAND ${WORK_DIR}/${MODEL_FOLDER}/part-r-00000

elif [ "x$dumpdatatype" = "xlda-topics" ];then

rm -rf ${WORK_DIR}/${LDA_TOPICS_DIR}
mkdir -p ${WORK_DIR}/${LDA_TOPICS_DIR}
$SCOUT seqdumper -i ${WORK_DIR}/${LDA_TOPICS_DIR} -o ${WORK_DIR}/${LDA_TOPICS_DIR}/part-m-00000
$OPEN_COMMAND ${WORK_DIR}/${LDA_TOPICS_DIR}/part-m-00000

elif [ "x$dumpdatatype" = "xlda" ];then

rm -rf ${WORK_DIR}/${LDA_DIR}/part-m-00000
mkdir -p ${WORK_DIR}/${LDA_DIR}
$SCOUT seqdumper -i ${WORK_DIR}/${LDA_DIR} -o ${WORK_DIR}/${LDA_DIR}/part-m-00000
#$OPEN_COMMAND ${WORK_DIR}/${LDA_DIR}/part-m-00000


fi






fi
