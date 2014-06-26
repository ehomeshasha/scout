#!/bin/bash

WORK_DIR=${SCOUT_HOME}/dataset
SCOUT=${SCOUT_HOME}/bin/scout

OPEN_COMMAND=cat

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

num_dumps_setting="-n 10"

if [ "x$1" = "xseqdirectory" ];then
###############################
#  debug seqdirectory dumper  #
###############################
set -x
rm -rf ${WORK_DIR}/${SEQ_DIR}
mkdir -p ${WORK_DIR}/${SEQ_DIR}
$SCOUT seqdumper -i ${WORK_DIR}/${SEQ_DIR} -o ${WORK_DIR}/${SEQ_DIR}/part-m-00000 ${num_dumps_setting}
$OPEN_COMMAND ${WORK_DIR}/${SEQ_DIR}/part-m-00000

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
$SCOUT seqdumper -i ${WORK_DIR}/${TOKENIZED_DOCUMENTS_DIR} -o ${WORK_DIR}/${TOKENIZED_DOCUMENTS_DIR}/part-m-00000 ${num_dumps_setting}
echo -e "\n\n${WORK_DIR}/${TOKENIZED_DOCUMENTS_DIR}/part-m-00000 content:"
$OPEN_COMMAND ${WORK_DIR}/${TOKENIZED_DOCUMENTS_DIR}/part-m-00000 && eval ${press_cmd}
fi
if [[ "x$dumpdatatype" = "xall" || "x$dumpdatatype" = "xword-count" ]];then
#dump word-count
$SCOUT seqdumper -i ${WORK_DIR}/${WORDCOUNT_DIR} -o ${WORK_DIR}/${WORDCOUNT_DIR}/part-r-00000 ${num_dumps_setting}
echo -e "\n\n${WORK_DIR}/${WORDCOUNT_DIR}/part-r-00000 content:"
$OPEN_COMMAND ${WORK_DIR}/${WORDCOUNT_DIR}/part-r-00000 && eval ${press_cmd}
fi
if [[ "x$dumpdatatype" = "xall" || "x$dumpdatatype" = "xdictionary-file" ]]; then
#dump dictionary-file
$SCOUT seqdumper -i ${WORK_DIR}/${DICTIONARY_FILE} -o ${WORK_DIR}/${DICTIONARY_FILE} ${num_dumps_setting}
echo -e "\n\n${WORK_DIR}/${DICTIONARY_FILE} content:"
$OPEN_COMMAND ${WORK_DIR}/${DICTIONARY_FILE} && eval ${press_cmd}
fi
if [[ "x$dumpdatatype" = "xall" || "x$dumpdatatype" = "xtf-vectors" ]]; then
#dump tf-vectors
$SCOUT seqdumper -i ${WORK_DIR}/${TFVECTORS_DIR} -o ${WORK_DIR}/${TFVECTORS_DIR}/part-r-00000 ${num_dumps_setting}
echo -e "\n\n${WORK_DIR}/${TFVECTORS_DIR}/part-r-00000 content:"
$OPEN_COMMAND ${WORK_DIR}/${TFVECTORS_DIR}/part-r-00000 && eval ${press_cmd}
fi
if [[ "x$dumpdatatype" = "xall" || "x$dumpdatatype" = "xdf-vectors" ]]; then
#dump df-vectors
$SCOUT seqdumper -i ${WORK_DIR}/${DF_COUNT_DIR} -o ${WORK_DIR}/${DF_COUNT_DIR}/part-r-00000 ${num_dumps_setting}
echo -e "\n\n${WORK_DIR}/${DF_COUNT_DIR}/part-r-00000 content:"
$OPEN_COMMAND ${WORK_DIR}/${DF_COUNT_DIR}/part-r-00000 && eval ${press_cmd}
fi
if [[ "x$dumpdatatype" = "xall" || "x$dumpdatatype" = "xfrequency-file" ]]; then
#dump frequency-file
$SCOUT seqdumper -i ${WORK_DIR}/${FREQUENCY_FILE} -o ${WORK_DIR}/${FREQUENCY_FILE} ${num_dumps_setting}
echo -e "\n\n${WORK_DIR}/${FREQUENCY_FILE} content:"
$OPEN_COMMAND ${WORK_DIR}/${FREQUENCY_FILE} && eval ${press_cmd}
fi
if [[ "x$dumpdatatype" = "xall" || "x$dumpdatatype" = "xtfidf-vectors" ]]; then
#dump tfidf-vectors
$SCOUT seqdumper -i ${WORK_DIR}/${TFIDFVECTORS_DIR} -o ${WORK_DIR}/${TFIDFVECTORS_DIR}/part-r-00000 ${num_dumps_setting}
echo -e "\n\n${WORK_DIR}/${TFIDFVECTORS_DIR}/part-r-00000 content:"
$OPEN_COMMAND ${WORK_DIR}/${TFIDFVECTORS_DIR}/part-r-00000
fi

elif [ "x$1" = "xsplit" ];then 
rm -rf ${WORK_DIR}/${TRAIN_DIR}
rm -rf ${WORK_DIR}/${TEST_DIR}
mkdir -p ${WORK_DIR}/${TRAIN_DIR}
mkdir -p ${WORK_DIR}/${TEST_DIR}

$SCOUT seqdumper -i ${WORK_DIR}/${TRAIN_DIR} -o ${WORK_DIR}/${TRAIN_DIR}/part-r-00000 ${num_dumps_setting}
$SCOUT seqdumper -i ${WORK_DIR}/${TEST_DIR} -o ${WORK_DIR}/${TEST_DIR}/part-r-00000 ${num_dumps_setting}

echo -e "\n\n${WORK_DIR}/${TRAIN_DIR}/part-r-00000 content:"
$OPEN_COMMAND ${WORK_DIR}/${TRAIN_DIR}/part-r-00000

echo -e "\n\n${WORK_DIR}/${TEST_DIR}/part-r-00000 content:"
$OPEN_COMMAND ${WORK_DIR}/${TEST_DIR}/part-r-00000

elif [ "x$1" = "xtrainnb" ];then

rm -rf ${WORK_DIR}/${LABEL_INDEX_FILE}
rm -rf ${WORK_DIR}/${MODEL_DIR}
#mkdir -p ${WORK_DIR}/${LABEL_INDEX_FILE}
mkdir -p ${WORK_DIR}/${MODEL_DIR}

$SCOUT seqdumper -i ${WORK_DIR}/${LABEL_INDEX_FILE} -o ${WORK_DIR}/${LABEL_INDEX_FILE}
$SCOUT seqdumper -i ${WORK_DIR}/${MODEL_DIR} -o ${WORK_DIR}/${MODEL_DIR}/naiveBayesModel.bin ${num_dumps_setting}

echo -e "\n\n${WORK_DIR}/${LABEL_INDEX_FILE} content:"
$OPEN_COMMAND ${WORK_DIR}/${LABEL_INDEX_FILE}

echo -e "\n\n${WORK_DIR}/${MODEL_DIR}/naiveBayesModel.bin content:"
$OPEN_COMMAND ${WORK_DIR}/${MODEL_DIR}/naiveBayesModel.bin




fi
