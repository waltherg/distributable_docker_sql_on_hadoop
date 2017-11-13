# Distributable Docker SQL on Hadoop

This repository expands on my earlier [Docker-Hadoop repository](https://github.com/waltherg/distributed_docker_hadoop)
where I put together a basic HDFS/YARN/MapReduce system.
In the present repository I explore various SQL-on-Hadoop options by spelling
out the various services explicitly in the accompanying Docker Compose file.

* [Prerequisites](#prerequisites)
* [Setup](#setup)
  * [Build Docker image:](#build-docker-image)
  * [Start cluster](#start-cluster)
* [Cluster services](#services-and-their-components)
  * [Hadoop distributed file system (HDFS)](#hadoop-distributed-file-system-hdfs)
  * [HBase](#hbase)
  * [Yet another resource negotiator (YARN)](#yet-another-resource-negotiator-yarn)
  * [MapReduce Job History Server](#mapreduce-job-history-server)
  * [ZooKeeper](#zookeeper)
  * [Spark](#spark)
  * [Tez](#tez)
  * [Hive](#hive)
  * [Hue](#hue)
  * [Impala](#impala)
  * [Presto](#presto)
  * [Drill](#drill)
  * [Spark SQL](#spark-sql)
  * [Phoenix](#phoenix)
* [Moving towards production](#moving-towards-production)

## Prerequisites

Ensure you have Python Anaconda (the Python 3 flavor) installed:
[https://www.anaconda.com/download](https://www.anaconda.com/download).
Further ensure you have a recent version of Docker installed.
The Docker version I developed this example on is:

    $ docker --version
    Docker version 17.09.0-ce, build afdb6d4

## Setup

We will use Docker Compose to spin up the various Docker containers constituting
our Hadoop system.
To this end let us create a clean Anaconda Python virtual environment and install
a current version of Docker Compose in it:

    $ conda create --name distributable_docker_sql_on_hadoop python=3.6 --yes
    $ source activate distributable_docker_sql_on_hadoop
    $ pip install -r requirements.txt

Make certain `docker-compose` points to this newly installed version in the virtual
environment:

    $ which docker-compose

In case this does not point to the `docker-compose` binary in your virtual environment,
reload the virtual environment and check again:

    $ source deactivate
    $ source activate distributable_docker_sql_on_hadoop

### Build Docker images

To build all relevant Docker images locally:

    $ source env
    $ ./build_images.sh

### Start cluster

To bring up the entire cluster run:

    $ docker-compose up --force-recreate

In a separate terminal you can now check the state of the cluster containers through

    $ docker ps

*Note*: When experimenting with the cluster you may need to start
over with a clean slate. To this end, remove all containers and related volumes:

    $ docker-compose rm -sv

## Services and their components

Here we take a closer look at the services we will run and their
respective components.

### Hadoop distributed file system (HDFS)

HDFS is the filesystem component of Hadoop and is optimized
for storing large data sets and sequential access to these data.
HDFS does not provide random read/write access to files, i.e. reading rows
X through X+Y in a large CSV or editing row Z in a CSV are operations that
HDFS does not provide.
For HDFS we need to run two components:

- Namenode
    - The master in HDFS
    - Stores data block metadata and directs the datanodes
    - Run two of these for high availability: one active, one standby
- Datanode
    - The worker in HDFS
    - Stores and retrieves data blocks
    - Run three data nodes in line with default block replication factor of three

The namenode provides a monitoring GUI at

[http://localhost:50070](http://localhost:50070)

### HBase

Distributed column(-family)-oriented data storage system
that provides random read/write data operations on top of HDFS
and auto-sharding across multiple hosts (region servers) of large tables.
Info as to what regions / shards of a table are stored where is kept in
the META table.

The HBase components are:

- HMaster
    - Coordinates the HBase cluster
    - Load balances data between the region servers
    - Handles region server failure
- Region servers
    - Store data pertaining to a given region (shard / partition of a table)
    - Respond to client requests directly - no need to go through HMaster for
      data requests
    - Run multiple of these (usually one region server service per physical host)
      to scale out data sizes that can be handled

In a production environment we would also start up an
HMaster backup server which our HBase cluster could
use as a fallback in case the original HMaster server failed.

Our HBase cluster provides the following web apps for monitoring:

- [HMaster](http://localhost:16010)
- [HMaster Thrift server](http://localhost:16011)
- [HBase Regionserver 0](http://localhost:16030)
- [HBase Regionserver 1](http://localhost:16031)
- [HBase Regionserver 2](http://localhost:16032)

Explore our HBase cluster with the HBase shell (quit the shell by pressing `Ctr+D`):

    $ source env
    $ docker run -ti --network distributabledockersqlonhadoop_hadoop_net --rm \
      ${hbase_image_name}:${image_version} bash -c '$HBASE_HOME/bin/hbase shell'

#### References

- [HBase documentation](https://hbase.apache.org/book.html)
- [HBase distributed mode](https://hbase.apache.org/book.html#fully_dist)
- [HBase fully distributed mode details](https://hbase.apache.org/book.html#quickstart_fully_distributed)
- [Configure ZooKeeper for HBase](https://hbase.apache.org/book.html#zookeeper)
- [HBase shell](http://hbase.apache.org/book.html#shell)
- [HBase shell exercises](http://hbase.apache.org/book.html#shell_exercises)

### Yet another resource negotiator (YARN)

The Hadoop cluster management system which requests cluster resources
for applications built on top of YARN.
YARN is compute layer of a Hadoop cluster and sits on top of the
cluster storage layer (HDFS or HBase).

The YARN components are:

- Resource manager
    - Manages the cluster resources
    - Run one per cluster
- Node manager
    - Manages containers that scheduled application processes are executed in
    - Run one per compute node
    - Run multiple compute nodes to scale out computing power

**Note**:
Where possible we want jobs that we submit to the cluster (e.g. MapReduce jobs)
to run on data stored locally on the executing host.
To this end we will start up the aforementioned HDFS data node service and
YARN node manager concurrently on a given host and call these hosts `hadoop-node`s.

The resource manager offers a management and monitoring GUI at

[http://localhost:8088](http://localhost:8088)

### MapReduce Job History Server

A number of the SQL-on-Hadoop approaches we will try out here translate
SQL queries to MapReduce jobs executed on the data stored in the cluster.
This service helps us keep track and visualize the MapReduce jobs we generated.

We run one job history server per cluster.

The job history server provides a monitoring GUI at

[http://localhost:19888](http://localhost:19888)

### ZooKeeper

ZooKeeper is used as a distributed coordination service between the
different Hadoop services of our system.
At its core, ZooKeeper provides a high-availability filesystem with ordered, atomic
operations.

We will run ZooKeeper in replicated mode where an ensemble of ZooKeeper servers
decides in a leader/follower fashion what the current consensus state is:

- ZooKeeper server
    - Run three servers so that a majority / quorum can be found in replicated mode

#### References

- [Replicated mode quickstart](
  https://zookeeper.apache.org/doc/r3.1.2/zookeeperStarted.html#sc_RunningReplicatedZooKeeper
)

### Spark

A cluster computing framework that does not translate user applications
to MapReduce operations but rather uses its own execution engine based
around directed acyclic graphs (DAGs).
In MapReduce all output (even intermediary results) is stored to disk
whereas the Spark engine has the ability to cache (intermediate) output
in memory thus avoiding the cost of reading from and writing to disk.
This is great for iterative algorithms and interactive data exploration
where code is executed against against the same set of data multiple times.

We will run Spark in cluster mode where a SparkContext object instantiated
in the user application connects to a cluster manager which
delegates sends the application code to one or multiple executors.
As cluster manager we choose YARN over its possible alternatives since
we already run it for other services of our system (alternatives are Spark's own
cluster manager and Mesos).

The executor processes are run on worker nodes:

- Worker node
    - Node in the Spark cluster that can run application code
    - Run multiple of these to scale out available computing power

#### References

- [Spark cluster mode](http://spark.apache.org/docs/latest/cluster-overview.html)

### Tez

Execution engine on top of YARN that translates user requests to directed acyclic
graphs (DAGs).
Tez was developed as a faster execution engine for other solutions that
would be otherwise executed as MapReduce jobs (Pig, Hive, etc.).

Tez needs to be installed on each compute node of our aforementioned YARN cluster.

#### References

- [Tez installation guide](https://tez.apache.org/install.html)

### Hive

Hive is a framework that allows you to analyze structured data files (stored locally
or in HDFS) using ANSI SQL.
As execution engine of Hive queries either MapReduce, Spark, or Tez may be used -
where the latter two promise accelerated execution time through their DAG-based engines.
Hive stores metadata on directories and files in its metastore which clients
need access to in order to run Hive queries.
Hive establishes data schemas on read thus allowing fast data ingestion.
HDFS does not support in-place file changes hence row updates are stored in delta
files and later merged into table files.
Hive does not locks natively and requires ZooKeeper for these.
Hive does however support indexes to improve query speeds.

To run Hive on our existing Hadoop cluster we need to add the following:

- HiveServer2
    - Service that allows clients to execute queries against Hive
- Metastore database
    - A traditional RDBMS server that persists relevant metadata
- Metastore server
    - Service that queries the metastore database for metadata on behalf of clients

To try out Hive you can connect to your instance of HiveServer2 through a CLI called Beeline.
Once you brought up the Hadoop cluster as described above start a container that runs
the Beeline CLI:

    $ source env
    $ docker run -ti --network distributabledockersqlonhadoop_hadoop_net --rm ${hive_image_name}:${image_version} \
      bash -c 'beeline -u jdbc:hive2://hive-hiveserver2:10000 -n root'

To look around:

    0: jdbc:hive2://hive-hiveserver2:10000> show tables;
    +-----------+
    | tab_name  |
    +-----------+
    +-----------+
    No rows selected (0.176 seconds)

To create a table:

    CREATE TABLE IF NOT EXISTS apache_projects (id int, name String, website String)
    COMMENT 'Hadoop-related Apache projects'
    ROW FORMAT DELIMITED
    FIELDS TERMINATED BY ','
    LINES TERMINATED BY '\n'
    STORED AS TEXTFILE;

Quit the Beeline client (and the Docker container) by pressing `Ctrl + D`.

The HiveServer2 instance also offers a web interface accessible at

[http://localhost:10002](http://localhost:10002)

Browse the HiveServer2 web interface to see logs of the commands and queries you executed in the
Beeline client and general service logs.

#### References

- [Running Hive quickstart](https://cwiki.apache.org/confluence/display/Hive/GettingStarted#GettingStarted-RunningHive)
- [HiveServer2 reference](https://cwiki.apache.org/confluence/display/Hive/HiveServer2+Overview)
- [Metastore reference](https://cwiki.apache.org/confluence/display/Hive/AdminManual+MetastoreAdmin)

### Hue

Hue is a graphical analytics workbench on top of Hadoop.
The creators of Hue maintain a [Docker image](https://hub.docker.com/r/gethue/hue/)
which allows for a quick start with this platform.
Here we merely update Hue's settings in line with our Hadoop cluster -
see `images/hue` for details.

Hue runs as a web application accessible at

[http://localhost:8888](http://localhost:8888)

When first opening the web application create a user account `root` with
arbitrary password.

Locate the Hive table you created earlier through the Beeline CLI -
you should find it in the `default` Hive database.

### Impala

### Presto

### Drill

### Spark SQL

### Phoenix

## Notes

### Hostnames

Hadoop hostnames are not permitted to contain underscores `_`, therefore make certain
to spell out longer hostnames with dashes `-` instead.

### Moving towards production

It should be relatively simple to scale out our test cluster to multiple physical hosts.
Here is a sketch of steps that are likely to get you closer to running this on multiple hosts:

* Create a [Docker swarm](https://docs.docker.com/engine/swarm/)
* Instead of the current Docker bridge network use an
  [overlay network](https://docs.docker.com/engine/userguide/networking/get-started-overlay/)
* Add an [OpenVPN server container](https://github.com/kylemanna/docker-openvpn) to your
  Docker overlay network to grant you continued web interface access from your computer
* You would likely want to use an orchestration framework such as
  [Ansible](https://www.ansible.com/) to tie the different steps and components
  of a more elaborate multi-host deployment together
