#!/bin/bash

if [ "$1" != "test" ]; then
#save system print out
date=$(date +%F)
LOGDIR=/var/www/html/classify_log;
JOBNAME=`basename $0`"_"${date};
JOBLOG=$JOBNAME.log;
if [ ! -e $LOGDIR/$JOBLOG ]; then
	echo "not exsist, create log file"
	touch $LOGDIR/$JOBLOG
fi
exec 1>> $LOGDIR/$JOBLOG 2>&1;
fi




#cd /home/hadoop-user/workspace/mahout-distribution-0.8
cd /var/www/html/mahout-distribution-0.8
WORK_DIR=./dealsaccess

#echo -e "\nclassify-dealsaccess.sh: Creating sequence files from CSV, if category can be pre-defined then Update MySQL\n"
#mahout seqCSV -i ./input/amazondeals.csv -o ./dealsaccess/seq -ow


echo -e "\nclassify-dealsaccess.sh: Creating sequence files from MySQL\n"
mahout seqMySQL \
-o ${WORK_DIR}/seq-MySQL \
-ow \
-lp

if [ ! -e ~/dealsaccessSequenceFilesFromMySQL.lock ]; then

	echo -e "\nclassify-dealsaccess.sh: Merge sequence files\n"
	mahout mergeseq \
	-i ${WORK_DIR}/seq \
	-a ${WORK_DIR}/seq-MySQL \
	-o ${WORK_DIR}/seq/part-m-00000 \
	-ow

	echo -e "\nclassify-dealsaccess.sh: Converting sequence files to TFIDF vectors\n"
	mahout seq2sparse \
	-i ${WORK_DIR}/seq/part-m-00000 \
	-o ${WORK_DIR}/vectors \
	-a PorterStemmerAnalyzer \
        -wt tfidf \
	-lnorm \
	-nv
	#mahout seq2sparse -i ./dealsaccess/seq/part-m-00000 -o ./dealsaccess/vectors -wt tfidf -lnorm -nv


	echo -e "\nclassify-dealsaccess.sh: Split Train Data for Training NaiveBayes Model and Split Test Data for Classification\n"
	mahout splitTrainTest \
	-i ${WORK_DIR}/vectors/tfidf-vectors \
	--trainingOutput ${WORK_DIR}/train-vectors \
	--testOutput ${WORK_DIR}/test-vectors  \
	-ow

	echo -e "\nclassify-dealsaccess.sh: Training Naive Bayes model\n"
	mahout trainnb \
	-i ${WORK_DIR}/train-vectors -el \
	-o ${WORK_DIR}/model \
	-li ${WORK_DIR}/labelindex \
	-ow

	echo -e "\nclassify-dealsaccess.sh: Generate Document Percentage\n"
	mahout dpct \
	-i ${WORK_DIR}/vectors/tfidf-vectors \
	-o ${WORK_DIR}/dpct \
	-ow

	echo -e "\nclassify-dealsaccess.sh: Classify Data, Update MySQL\n"
	mahout nbapp \
	-i ${WORK_DIR}/test-vectors \
	-m ${WORK_DIR}/model \
	-l ${WORK_DIR}/labelindex \
	-dpct ${WORK_DIR}/dpct \
	-o ${WORK_DIR}/results \
	-ow
	#mahout nbapp 	-i ./dealsaccess/test-vectors -m ./dealsaccess/model -l ./dealsaccess/labelindex -dpct ./dealsaccess/dpct -o ./dealsaccess/results -ow -d

	echo -e "\nclassify-dealsaccess.sh: Create Solr Xml files then add them to Solr\n"
	mahout solrxml
fi

#dump command
#mahout seqdumper -i ./dealsaccess/test-vectors -o ../local/dealsaccess/test-vectors
