#!/bin/bash

function print_usage {
	echo "Usage: -n NODES -h"
	echo "       -n: Number of nodes requested for the Hadoop installation"
	echo "       -h: Print help"
}
NAME_NODE=`awk 'NR==1{print;exit}' $PBS_NODEFILE`
RESOURCE_NODE=`awk 'NR==2{print;exit}' $PBS_NODEFILE`
KAFKA_NODE=`awk 'NR==3{print;exit}' $PBS_NODEFILE`
export HADOOP_CONF_DIR="${MY_HADOOP_DIR}/config"

#initialize arguments
NODES=""

# parse arguments
args=`getopt n:h $*`
if test $? != 0
then
    print_usage
    exit 1
fi
set -- $args
for i
do
    case "$i" in
        -n) shift;
            NODES=$1
            shift;;
        -h) shift;
            print_usage
            exit 0
    esac
done

if [ "$NODES" != "" ]; then
    echo "Number of Hadoop nodes specified by user: $NODES"
else
    echo "Required parameter not set - number of nodes (-n)"
    print_usage
    exit 1
fi

# get the number of nodes from PBS
if [ -e $PBS_NODEFILE ]; then
    pbsNodes=`awk 'END {print NR}' $PBS_NODEFILE`
    echo "Received $pbsNodes nodes from PBS"

    if [ "$NODES" != "$pbsNodes" ]; then
        echo "Number of nodes received from PBS not the same as number of nodes requested by user"
        exit 1;
    fi
else
    echo "PBS_NODEFILE is unavailable"
    exit 1
fi

#: Stop Spark Services

: "Stop all HBase Services"
${HBASE_HOME}/bin/stop-hbase.sh
: "Stop all Hadoop Services"

ssh ${NAME_NODE} "${HADOOP_PREFIX}/sbin/mr-jobhistory-daemon.sh stop historyserver --config $HADOOP_CONF_DIR"
${HADOOP_PREFIX}/sbin/yarn-daemons.sh --config $YARN_CONF_DIR stop nodemanager
ssh ${RESOURCE_NODE} "${HADOOP_PREFIX}/sbin/yarn-daemon.sh --config $YARN_CONF_DIR stop resourcemanager"
ssh ${RESOURCE_NODE} "${HADOOP_PREFIX}/sbin/hadoop-daemon.sh --config ${HADOOP_CONF_DIR} --script hdfs stop secondarynamenode"
${HADOOP_PREFIX}/sbin/hadoop-daemons.sh --config ${HADOOP_CONF_DIR} --script hdfs stop datanode
ssh ${NAME_NODE} "${HADOOP_PREFIX}/sbin/hadoop-daemon.sh --config ${HADOOP_CONF_DIR} --script hdfs stop namenode"

# clean up working directories for N-node Hadoop cluster
for ((i=1; i<=$NODES; i++))
do
	node=`awk 'NR=='"$i"'{print;exit}' $PBS_NODEFILE`
	echo "Clean up node: $node"
	cmd="rm -rf $HADOOP_DATA_DIR $HADOOP_LOG_DIR $HADOOP_TMP_DIR $YARN_LOCAL_DIR $HBASE_TMP_DIR"
	echo $cmd
	ssh $node $cmd
	ssh $node "rm -rf /local_scratch/${USER}"
done
