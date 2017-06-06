# myHadoop-Palmetto
Modified myHadoop scripts to work on Palmetto Supercomputer for PBS

## Software Preparation

In your home directory on Palmetto, create a directory called software:

```
mkdir  ~/software
```

Copy the following files into the newly created directory

```
cp /scratch3/lngo/myHadoop/hdp.tar.gz  ~/software
cp /scratch3/lngo/myHadoop/java.tar.gz  ~/software
```

Decompressed the tar files:

```
cd  ~/software
tar –xzf  *.tar.gz
```

After decompression, in your software directory there should be two subdirectories:

```
hadoop-2.2.0.2.1.0.0-92
jdk1.7.0_25
```

## Management Preparation

Copy the following directory to your home directory and decompress

```
cd ~
cp /scratch3/lngo/myHadoop/hdp2.2.tar.gz ~
tar xzf hdp2.2.tar.gz
```

Open your .bashrc file to edit:

```
vim   ~/.bashrc
```

Add the following line to the end of your .bashrc file:

```
source   /home/$USER/hdp-2.2/bin/setenv.sh
```

## Start myHadoop on Palmetto

Go to the hdp-2.2 directory and start up the PBS job for Hadoop cluster

```
cd   ~/hdp-2.2
qsub   start-hadoop.pbs
```

You can modify the start-hadoop.pbs to request Palmetto resources that match your Hadoop infrastructure design.

## Customization Note:

Environment variables supporting myHadoop are declared in hdp-2.2/bin/setenv.sh. 
You can change them as needed. For example, if you want to use a different Java version rather than 1.7, 
you can change JAVA_HOME to point to your desired Java installation.
