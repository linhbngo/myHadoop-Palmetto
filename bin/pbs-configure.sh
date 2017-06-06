#!/bin/bash

function print_usage {
    echo "Usage: -n NODES -p -d BASE_DIR -c CONFIG_DIR -h"
    echo "       -n: Number of nodes requested for the Hadoop installation"
    echo "       -p: Whether the Hadoop installation should be persistent"
    echo "           If so, data directories will have to be linked to a"
    echo "           directory that is not local to enable persistence"
    echo "       -d: Base directory to persist HDFS stat, to be used if"
    echo "           -p is set"
    echo "       -c: The directory to generate Hadoop configs in"
    echo "       -h: Print help"
}

# initialize arguments
NODES=""
PERSIST="false"
BASE_DIR=""
CONFIG_DIR=""

# parse arguments
args=`getopt n:pd:c:h $*`
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
        -d) shift;
            BASE_DIR=$1
            shift;;
        -c) shift;
            CONFIG_DIR=$1
            shift;;
        -p) shift;
            PERSIST="true"
            ;;
        -h) shift;
            print_usage
            exit 0
    esac
done

if [ "$NODES" != "" ]; then
    echo "Number of Hadoop nodes requested: $NODES"
else
    echo "Required parameter not set - number of nodes (-n)"
    print_usage
    exit 1
fi

if [ "$CONFIG_DIR" != "" ]; then
    echo "Generation Hadoop configuration in directory: $CONFIG_DIR"
else
    echo "Location of configuration directory not specified"
    print_usage
    exit 1
fi

if [ "$PERSIST" = "true" ]; then
    echo "Persisting HDFS state (-p)"
    if [ "$BASE_DIR" = "" ]; then
        echo "Base directory (-d) not set for persisting HDFS state"
        print_usage
        exit 1
    else
        echo "Using directory $BASE_DIR for persisting HDFS state"
    fi
else
    echo "Not persisting HDFS state"
fi

# get the number of nodes from PBS
if [ -e $PBS_NODEFILE ]; then
    PBS_NODES=`awk 'END { print NR }' $PBS_NODEFILE`
    echo "Received $PBS_NODES nodes from PBS"

    if [ "$NODES" != "$PBS_NODES" ]; then
        echo "Number of nodes received from PBS not the same as the nubmer of nodes requested by user"
        exit 1
    fi
else
    echo "PBS_NODEFILE is unavailable"
    exit 1
fi

# create the config, data, and log directories
rm -rf $CONFIG_DIR
mkdir -p $CONFIG_DIR

# pick the master node as the first node in the PBS_NODEFILE
MASTER_NODE=`awk 'NR==1{print;exit}' $PBS_NODEFILE`
# export MASTER env for Spark/Shark
export MASTER=$MASTER_NODE

echo "Master Node is: $MASTER_NODE"
echo $MASTER_NODE >> $CONFIG_DIR/masters

# pick the resource manager node as the second node in the PBS_NODEFILE
RESOURCE=`awk 'NR==2{print;exit}' $PBS_NODEFILE`
export RESOURCE_NODE=$RESOURCE
export HISTORY_NODE =$RESOURCE

echo "Resource Manager Node is: $RESOURCE_NODE"
#echo $RESOURCE_NODE >> $CONFIG_DIR/masters
echo $RESOURCE_NODE >> $CONFIG_DIR/regionservers

NUM_SLAVE_NODES=$(expr $NODES - 2)
NUM_ZOO_NODES=3

tail -n -${NUM_SLAVE_NODES} $PBS_NODEFILE > $CONFIG_DIR/slaves
tail -n -${NUM_SLAVE_NODES} $PBS_NODEFILE > $CONFIG_DIR/regionservers
tail -n -${NUM_ZOO_NODES} $PBS_NODEFILE > $CONFIG_DIR/zoonodes

DATA_LIST=`awk -vORS=, '{ print $1 }' $CONFIG_DIR/slaves | sed 's/,$/\n/'`
#echo "Data Nodes: $DATA_LIST"
ZOO_LIST=`awk -vORS=, '{ print $1 }' $CONFIG_DIR/zoonodes | sed 's/,$/\n/'`
#echo "Zookeeper Nodes: $ZOO_LIST"

# Copy all information to the configuration file (with all information on nodes)
echo "NameNode"
echo "    Identifier: $MASTER_NODE"
echo "    Services: NameNode, JobHistoryServer, HMaster"
echo ""
echo "Resource Manager Node"
echo "    Identifier: $RESOURCE_NODE"
echo "    Services: Resource Manager, Secondary NameNode"
echo ""
echo "Data Nodes"
echo "    Identifiers: $DATA_LIST"
echo "    Services: DataNode, NodeManager, HRegionServer"
echo ""
echo "Zookeeper Nodes"
echo "    Identifiers: $ZOO_LIST"
echo "    Services: HQuorumPeer"

# copy all config file templates
#cp $MY_HADOOP_DIR/config_templates/core-site.xml.template $CONFIG_DIR/core-site.xml
#cp $MY_HADOOP_DIR/config_templates/hadoop-env.sh.template $CONFIG_DIR/hadoop-env.sh
cp $MY_HADOOP_DIR/config_templates/hbase-site.xml.template $CONFIG_DIR/hbase-site.xml
cp $MY_HADOOP_DIR/config_templates/hdfs-site.xml.template $CONFIG_DIR/hdfs-site.xml
cp $MY_HADOOP_DIR/config_templates/hive-site.xml.template $CONFIG_DIR/hive-site.xml
cp $MY_HADOOP_DIR/config_templates/hive-site.xml.template $HIVE_HOME/conf/hive-site.xml
cp $MY_HADOOP_DIR/config_templates/spark-env.sh.template $CONFIG_DIR/spark-env.sh
cp $MY_HADOOP_DIR/config_templates/yarn-site.xml.template $CONFIG_DIR/yarn-site.xml
cp $MY_HADOOP_DIR/config_templates/capacity-scheduler.xml $CONFIG_DIR/capacity-scheduler.xml
cp $MY_HADOOP_DIR/config_templates/spark-defaults.conf.template $CONFIG_DIR/spark-defaults.conf
# update all config files
cp $MY_HADOOP_DIR/config_templates/log4j-server.properties $MY_HADOOP_DIR/config/log4j-server.properties
# core-site.xml
#sed -i 's:hdfs:\/\/.*:hdfs:\/\/'"$MASTER_NODE"':g' $CONFIG_DIR/core-site.xml
sed 's/hdfs:\/\/.*:/hdfs:\/\/'"$MASTER_NODE"':/g' $MY_HADOOP_DIR/config_templates/core-site.xml.template > $CONFIG_DIR/core-site.xml
sed -i 's:HADOOP_DATA_DIR:'"$HADOOP_DATA_DIR"':g' $CONFIG_DIR/core-site.xml
sed -i 's:HADOOP_TMP_DIR:'"$HADOOP_TMP_DIR"':g' $CONFIG_DIR/core-site.xml

# hadoop-env.sh
echo "" >> $CONFIG_DIR/hadoop-env.sh
echo "# Overwrite location of the log directory" >> $CONFIG_DIR/hadoop-env.sh
echo "export HADOOP_LOG_DIR=$HADOOP_LOG_DIR" >> $CONFIG_DIR/hadoop-env.sh

# hbase-site.xml
#sed 's/hdfs:\/\/.*:/hdfs:\/\/'"$MASTER_NODE"':/g' $MY_HADOOP_DIR/config_templates/hbase-site.xml.template > $CONFIG_DIR/hbase-site.xml
#sed 's:HBASE_DIR:'"${HBASE_HOME}"':g' $CONFIG_DIR/hbase-site.xml
#sed -i 's:hdfs:\/\/.*:/hdfs:\/\/'"$MASTER_NODE"':g' $CONFIG_DIR/hbase-site.xml
sed -i 's:ZOOKEEPER:'"$ZOO_LIST"':g' $CONFIG_DIR/hbase-site.xml
sed -i 's:HBASE_TMP_DIR:'"${HBASE_TMP_DIR}"':g' $CONFIG_DIR/hbase-site.xml

# hdfs-site.xml
sed -i 's:HADOOP_DATA_DIR:'"$HADOOP_DATA_DIR"':g' $CONFIG_DIR/hdfs-site.xml
sed -i 's:USER:'"$USER"':g' $CONFIG_DIR/hdfs-site.xml
# hive-site.xml
sed -i 's:HOST_NAME:'"$MASTER_NODE"':g' $CONFIG_DIR/hive-site.xml
sed -i 's:HADOOP_HOME:'"$HADOOP_HOME"':g' $CONFIG_DIR/hive-site.xml
sed -i 's:HADOOP_CONFIG_DIR:'"$HADOOP_CONF_DIR"':g' $CONFIG_DIR/hive-site.xml
cp $CONFIG_DIR/hive-site.xml $HIVE_HOME/conf/hive-site.xml

# server.properties
sed -i 's:KAFKA_LOG_DIR:'"$KAFKA_LOG_DIR"':g' ${KAFKA_HOME}/config/server.properties
sed -i 's:ZOO_LIST:'"$ZOO_LIST"':g' ${KAFKA_HOME}/config/server.properties

# zookeeper.properties
sed -i 's:ZOOKEEPER_DATA_DIR:'"$ZOOKEEPER_DATA_DIR"':g' ${KAFKA_HOME}/config/zookeeper.properties

# mapred-site.xml
sed 's/<value>.*:/<value>'"$MASTER_NODE"':/g' $MY_HADOOP_DIR/config_templates/mapred-site.xml.template > $CONFIG_DIR/mapred-site.xml
sed -i 's:HISTORY_SERVER:'"$MASTER_NODE"':g' $CONFIG_DIR/mapred-site.xml

# spark-default.conf
sed -i 's:MASTER:'"$MASTER"':g' $CONFIG_DIR/spark-defaults.conf

# spark-env.sh

# yarn-site.xml
sed -i 's:RESOURCE_MANAGER:'"$RESOURCE_NODE"':g' $CONFIG_DIR/yarn-site.xml
sed -i 's:YARN_LOCAL_DIR:'"$YARN_LOCAL_DIR"':g' $CONFIG_DIR/yarn-site.xml
sed -i 's:YARN_LOG_DIR:'"$YARN_LOG_DIR"':g' $CONFIG_DIR/yarn-site.xml
sed -i 's:HISTORY_SERVER:'"$MASTER_NODE"':g' $CONFIG_DIR/yarn-site.xml

# create or link HADOOP_{DATA,LOG}_DIR on all slave
for ((i=1; i<=$NODES; i++))
do
    node=`awk 'NR=='"$i"'{print;exit}' $PBS_NODEFILE`
    echo "Configuring node: $node"
    ssh $node 'df -h | grep /local_scratch'
    cmd="rm -Rf $HADOOP_LOG_DIR; mkdir -p $HADOOP_LOG_DIR; rm -Rf $YARN_LOCAL_DIR; mkdir -p $YARN_LOCAL_DIR; rm -Rf $YARN_LOG_DIR; mkdir -p $YARN_LOG_DIR"
    echo $cmd
    ssh $node $cmd
    if [ "$PERSIST" = "true" ]; then
        cmd="rm -Rf $HADOOP_DATA_DIR; ln -s $BASE_DIR/$i $HADOOP_DATA_DIR; rm -Rf $YARN_LOCAL_DIR; rm -Rf $YARN_LOG_DIR"
        echo $cmd
        ssh $node $cmd
    else
        cmd="rm -rf $HADOOP_DATA_DIR; mkdir -p $HADOOP_DATA_DIR; rm -Rf $YARN_LOCAL_DIR; mkdir -p $YARN_LOCAL_DIR; rm -Rf $YARN_LOG_DIR; mkdir -p $YARN_LOG_DIR"
        echo $cmd
        ssh $node $cmd
    fi
done
