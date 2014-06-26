#!/bin/bash


THIS="$0"
THIS_DIR=`dirname "$THIS"`
SCOUT_HOME=`cd "$THIS_DIR/.." ; pwd`

if [ "$1" = "--help" ] || [ "$1" = "--?" ]; then
  echo "This script clusters the Reuters data set using a variety of algorithms.  The data set is in ${SCOUT_HOME}/dataset."
  exit
fi

SCRIPT_PATH=${0%/*}

if [ "$0" != "$SCRIPT_PATH" ] && [ "$SCRIPT_PATH" != "" ]; then 
  cd $SCRIPT_PATH
fi

SCOUT="./scout"

if [ ! -e $SCOUT ]; then
  echo "Can't find scout driver in $SCOUT, cwd `pwd`, exiting.."
  exit 1
fi

algorithm=( kmeans fuzzykmeans lda streamingkmeans)
if [ -n "$1" ]; then
  choice=$1
else
  echo "Please select a number to choose the corresponding clustering algorithm"
  echo "1. ${algorithm[0]} clustering"
  echo "2. ${algorithm[1]} clustering"
  echo "3. ${algorithm[2]} clustering"
  echo "4. ${algorithm[3]} clustering"
  read -p "Enter your choice : " choice
fi

echo "ok. You chose $choice and we'll use ${algorithm[$choice-1]} Clustering"
clustertype=${algorithm[$choice-1]} 

WORK_DIR=${SCOUT_HOME}/dataset
echo "our work directory is ${WORK_DIR}"

if [ "$HADOOP_HOME" != "" ] && [ "$SCOUT_LOCAL" == "" ] ; then
  HADOOP="$HADOOP_HOME/bin/hadoop"
  if [ ! -e $HADOOP ]; then
    echo "Can't find hadoop in $HADOOP, exiting"
    exit 1
  fi
fi

mkdir -p ${WORK_DIR}

if [ ! -e ${WORK_DIR}/reuters-out-seqdir ]; then
  if [ ! -e ${WORK_DIR}/reuters-out ]; then
    if [ ! -e ${WORK_DIR}/reuters-sgm ]; then
      if [ ! -f ${WORK_DIR}/reuters21578.tar.gz ]; then
	  if [ -n "$2" ]; then
	      echo "Copying Reuters from local download"
	      cp $2 ${WORK_DIR}/reuters21578.tar.gz
	  else
              echo "Downloading Reuters-21578"
              curl http://kdd.ics.uci.edu/databases/reuters21578/reuters21578.tar.gz -o ${WORK_DIR}/reuters21578.tar.gz
	  fi
      fi
      #make sure it was actually downloaded
      if [ ! -f ${WORK_DIR}/reuters21578.tar.gz ]; then
	  echo "Failed to download reuters"
	  exit 1
      fi
      mkdir -p ${WORK_DIR}/reuters-sgm
      echo "Extracting..."
      tar xzf ${WORK_DIR}/reuters21578.tar.gz -C ${WORK_DIR}/reuters-sgm
    fi
  
    echo "Extracting Reuters"
    $SCOUT org.apache.lucene.benchmark.utils.ExtractReuters ${WORK_DIR}/reuters-sgm ${WORK_DIR}/reuters-out
    if [ "$HADOOP_HOME" != "" ] && [ "$SCOUT_LOCAL" == "" ] ; then
        echo "Copying Reuters data to Hadoop"
        set +e
        echo $HADOOP dfs -rmr ${WORK_DIR}/reuters-sgm
        set -x
        $HADOOP dfs -rmr ${WORK_DIR}/reuters-sgm
        $HADOOP dfs -rmr ${WORK_DIR}/reuters-out
        set -e
        $HADOOP dfs -put ${WORK_DIR}/reuters-sgm ${WORK_DIR}/reuters-sgm
        $HADOOP dfs -put ${WORK_DIR}/reuters-out ${WORK_DIR}/reuters-out
        set +x
    fi
  fi
  echo "Converting to Sequence Files from Directory"
  $SCOUT seqdirectory -i ${WORK_DIR}/reuters-out -o ${WORK_DIR}/reuters-out-seqdir -c UTF-8 -chunk 64 -xm sequential
fi

if [ "x$clustertype" == "xkmeans" ]; then
  $SCOUT seq2sparse \
    -i ${WORK_DIR}/reuters-out-seqdir/ \
    -o ${WORK_DIR}/reuters-out-seqdir-sparse-kmeans --maxDFPercent 85 --namedVector \
  && \
  $SCOUT kmeans \
    -i ${WORK_DIR}/reuters-out-seqdir-sparse-kmeans/tfidf-vectors/ \
    -c ${WORK_DIR}/reuters-kmeans-clusters \
    -o ${WORK_DIR}/reuters-kmeans \
    -dm org.apache.mahout.common.distance.CosineDistanceMeasure \
    -x 10 -k 20 -ow --clustering \
  && \
  $SCOUT clusterdump \
    -i ${WORK_DIR}/reuters-kmeans/clusters-*-final \
    -o ${WORK_DIR}/reuters-kmeans/clusterdump \
    -d ${WORK_DIR}/reuters-out-seqdir-sparse-kmeans/dictionary.file-0 \
    -dt sequencefile -b 100 -n 20 --evaluate -dm org.apache.mahout.common.distance.CosineDistanceMeasure -sp 0 \
    --pointsDir ${WORK_DIR}/reuters-kmeans/clusteredPoints \
    && \
  cat ${WORK_DIR}/reuters-kmeans/clusterdump
elif [ "x$clustertype" == "xfuzzykmeans" ]; then
  $SCOUT seq2sparse \
    -i ${WORK_DIR}/reuters-out-seqdir/ \
    -o ${WORK_DIR}/reuters-out-seqdir-sparse-fkmeans --maxDFPercent 85 --namedVector \
  && \
  $SCOUT fkmeans \
    -i ${WORK_DIR}/reuters-out-seqdir-sparse-fkmeans/tfidf-vectors/ \
    -c ${WORK_DIR}/reuters-fkmeans-clusters \
    -o ${WORK_DIR}/reuters-fkmeans \
    -dm org.apache.mahout.common.distance.CosineDistanceMeasure \
    -x 10 -k 20 -ow -m 1.1 \
  && \
  $SCOUT clusterdump \
    -i ${WORK_DIR}/reuters-fkmeans/clusters-*-final \
    -o ${WORK_DIR}/reuters-fkmeans/clusterdump \
    -d ${WORK_DIR}/reuters-out-seqdir-sparse-fkmeans/dictionary.file-0 \
    -dt sequencefile -b 100 -n 20 -sp 0 \
    && \
  cat ${WORK_DIR}/reuters-fkmeans/clusterdump
elif [ "x$clustertype" == "xlda" ]; then
  $SCOUT seq2sparse \
    -i ${WORK_DIR}/reuters-out-seqdir/ \
    -o ${WORK_DIR}/reuters-out-seqdir-sparse-lda -ow --maxDFPercent 85 --namedVector \
  && \
  $SCOUT rowid \
    -i ${WORK_DIR}/reuters-out-seqdir-sparse-lda/tfidf-vectors \
    -o ${WORK_DIR}/reuters-out-matrix \
  && \
  rm -rf ${WORK_DIR}/reuters-lda ${WORK_DIR}/reuters-lda-topics ${WORK_DIR}/reuters-lda-model \
  && \
  $SCOUT cvb \
    -i ${WORK_DIR}/reuters-out-matrix/matrix \
    -o ${WORK_DIR}/reuters-lda -k 20 -ow -x 20 \
    -dict ${WORK_DIR}/reuters-out-seqdir-sparse-lda/dictionary.file-* \
    -dt ${WORK_DIR}/reuters-lda-topics \
    -mt ${WORK_DIR}/reuters-lda-model \
  && \
  $SCOUT vectordump \
    -i ${WORK_DIR}/reuters-lda-topics/part-m-00000 \
    -o ${WORK_DIR}/reuters-lda/vectordump \
    -vs 10 -p true \
    -d ${WORK_DIR}/reuters-out-seqdir-sparse-lda/dictionary.file-* \
    -dt sequencefile -sort ${WORK_DIR}/reuters-lda-topics/part-m-00000 \
    && \
  cat ${WORK_DIR}/reuters-lda/vectordump
elif [ "x$clustertype" == "xstreamingkmeans" ]; then
  $SCOUT seq2sparse \
    -i ${WORK_DIR}/reuters-out-seqdir/ \
    -o ${WORK_DIR}/reuters-out-seqdir-sparse-streamingkmeans -ow --maxDFPercent 85 --namedVector \
  && \
  rm -rf ${WORK_DIR}/reuters-streamingkmeans \
  && \
  $SCOUT streamingkmeans \
    -i ${WORK_DIR}/reuters-out-seqdir-sparse-streamingkmeans/tfidf-vectors/ \
    --tempDir ${WORK_DIR}/tmp \
    -o ${WORK_DIR}/reuters-streamingkmeans \
    -sc org.apache.mahout.math.neighborhood.FastProjectionSearch \
    -dm org.apache.mahout.common.distance.SquaredEuclideanDistanceMeasure \
    -k 10 -km 100 -ow \
  && \
  $SCOUT qualcluster \
    -i ${WORK_DIR}/reuters-out-seqdir-sparse-streamingkmeans/tfidf-vectors/part-r-00000 \
    -c ${WORK_DIR}/reuters-streamingkmeans/part-r-00000   \
    -o ${WORK_DIR}/reuters-cluster-distance.csv \
    && \
  cat ${WORK_DIR}/reuters-cluster-distance.csv
else 
  echo "unknown cluster type: $clustertype"
fi 
