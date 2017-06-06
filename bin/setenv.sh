#!/bin/bash

# Set this to the location of hadoop-dist
export MY_HADOOP_DIR="/home/${USER}/hdp-2.2"
export SOFTWARE_HOME="/home/${USER}/software"
# Set this to the location of Java
export JAVA_HOME="${SOFTWARE_HOME}/jdk1.7.0_25"

# Set this to the location of the Hadoop Installation
export HADOOP_HOME="${SOFTWARE_HOME}/hadoop-2.2.0.2.1.0.0-92"
export HADOOP_PREFIX="${HADOOP_HOME}"
export HADOOP_HOME_WARN_SUPPRESS=1
export HADOOP_MAPRED_HOME="${HADOOP_PREFIX}"
export HADOOP_COMMON_HOME="${HADOOP_PREFIX}"
export HADOOP_HDFS_HOME="${HADOOP_PREFIX}"
export HADOOP_YARN_HOME="${HADOOP_PREFIX}"
export HADOOP_CONF_DIR="${MY_HADOOP_DIR}/config"
export YARN_CONF_DIR="${MY_HADOOP_DIR}/config"
export HADOOP_COMMON_LIB_NATIVE_DIR="${HADOOP_PREFIX}/lib/native"
export HADOOP_OPTS="-Djava.library.path=${HADOOP_PREFIX}/lib"

# Set this to the location you want to use for HDFS
# Note that this path should point to a LOCAL directory,
# and that the path should exist on all slave nodes.
export HADOOP_DATA_DIR="/local_scratch/${USER}/hdfs/datanode"
# Set this to the location of where you want the Hadoop logfiles
export HADOOP_LOG_DIR="/local_scratch/${USER}/hadoop/log"
# Set this to the location of where you want the Hadoop temp directory
export HADOOP_TMP_DIR="/local_scratch/${USER}/hadoop/tmp"
# Set this to the location of where you want the Yarn local directory
export YARN_LOCAL_DIR="/local_scratch/${USER}/yarn/data"
# Set this to the location of where you want the YARN log directory
export YARN_LOG_DIR="/local_scratch/${USER}/yarn/logs"
# Set this to the location of where you want the HBase temp directory
export HBASE_TMP_DIR="/local_scratch/${USER}/hbase/tmp"

# Set this to the location of the HBase Installation
export HBASE_HOME="${SOFTWARE_HOME}/hbase-0.98.0"
export HBASE_PREFIX="${HBASE_HOME}"
export HBASE_CONF_DIR="${HADOOP_CONF_DIR}"
export HBASE_REGIONSERVERS="${HADOOP_CONF_DIR}/regionservers"

# Set this to the location of the Hive Installation
export HIVE_HOME="${SOFTWARE_HOME}/hive-0.10.0"
export HIVE_CONF_DIR="${HADOOP_CONF_DIR}"

# Set this to the location of the Zookeeper Installation
export ZOOKEEPER_HOME="${SOFTWARE_HOME}/zookeeper-3.4.6"
export ZOOKEEPER_CONF_DIR="${HADOOP_CONF_DIR}"
export ZOOKEEPER_DATA_DIR="/local_scratch/${USER}/zookeeper/data"

# Set this to the location of the Spark Installation
#export SPARK_HOME="${SOFTWARE_HOME}/spark-1.4.1-bin-without-hadoop"
export SPARK_HOME="${SOFTWARE_HOME}/spark-1.5.2"
export SPARK_CONF_DIR="${HADOOP_CONF_DIR}"

# Set this to the location of the Scala Installation
export SCALA_HOME="${SOFTWARE_HOME}/scala-2.10.4"
export SCALA_CONF_DIR="${HADOOP_CONF_DIR}"
export SBT_HOME="${SOFTWARE_HOME}/sbt"
export SBT_CONF_DIR="${SBT_HOME}/conf"

# Set all of the Path and Classpath variables
export PATH=${JAVA_HOME}/bin:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${PATH}:${HBASE_HOME}/bin:${HIVE_HOME}/bin:${ZOOKEEPER_HOME}/bin:${SPARK_HOME}/bin:${SPARK_HOME}/sbin:${SCALA_HOME}/bin:${SBT_HOME}/bin
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${SPARK_HOME}/lib:${SCALA_HOME}/lib


export HADOOP_HOME_LIBS=${HADOOP_HOME}/share/hadoop
export HADOOP_CLASSPATH=${HADOOP_CLASSPATH}:${HADOOP_HOME_LIBS}/common/*
export HADOOP_CLASSPATH=${HADOOP_CLASSPATH}:${HADOOP_HOME_LIBS}/common/lib/*
export HADOOP_CLASSPATH=${HADOOP_CLASSPATH}:${HADOOP_HOME_LIBS}/mapreduce/*
export HADOOP_CLASSPATH=${HADOOP_CLASSPATH}:${HADOOP_HOME_LIBS}/mapreduce/lib/*
export HADOOP_CLASSPATH=${HADOOP_CLASSPATH}:${HADOOP_HOME_LIBS}/yarn/*
export HADOOP_CLASSPATH=${HADOOP_CLASSPATH}:${HADOOP_HOME_LIBS}/yarn/lib/*
export HADOOP_CLASSPATH=${HADOOP_CLASSPATH}:${HADOOP_HOME_LIBS}/hdfs/*
export HADOOP_CLASSPATH=${HADOOP_CLASSPATH}:${HADOOP_HOME_LIBS}/hdfs/lib/*

export CLASSPATH=${CLASSPATH}:${HADOOP_CLASSPATH}

export SPARK_CLASSPATH=$CLASSPATH
export HBASE_CLASSPATH=${CLASSPATH}
