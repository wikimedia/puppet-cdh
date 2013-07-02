# puppet-cdh4

Puppet module to install and manage components of
Cloudera's Distribution 4 (CDH4) for Apache Hadoop.

# Description
Installs HDFS, YARN or MR1, Hive, Pig, Sqoop, Zookeeper, Oozie and
Hue.  Note that, in order for this module to work, you will have to ensure
that:

* Sun JRE version 6 is installed.
* Your package manager is configured with a repository containing the
  Cloudera 4 packages.

Note that many of the above mentioned services are not yet implemented in v0.2.
See the v0.1 branch if you'd like to use these now.

# Installation:
Clone (or copy) this repository into your puppet modules/cdh4 directory:
```bash
git clone git://github.com/wikimedia/puppet-cdh4.git modules/cdh4
```

Or you could also use a git submodule:
```bash
git submodule add git://github.com/wikimedia/puppet-cdh4.git modules/cdh4
git commit -m 'Adding modules/cdh4 as a git submodule.'
git submodule init && git submodule update
```

# Usage

## For all Hadoop nodes:
```puppet

include cdh4
class { "cdh4::hadoop":
	namenode_hostname => "namenode.hostname.org",
	datanode_mounts   => [
	    "/var/lib/hadoop/data/a",
	    "/var/lib/hadoop/data/b",
	    "/var/lib/hadoop/data/c"
	],
	dfs_name_dir      => ["/var/lib/hadoop/name", "/mnt/hadoop_name"],
}
```
This will ensure that CDH4 client packages are installed, and that
Hadoop related config files are in place with proper settings.

The datanode_mounts parameter assumes that you want to keep your
DataNode and YARN/MRv1 specific data in subdirectories in each of the mount
points provided.

If you would like to use MRv1 instead of YARN, set ```use_yarn``` to false.

## For your Hadoop master node:
```puppet
include cdh4::hadoop::master
```
This installs and starts up the NameNode.  If using YARN this will install
and set up ResourceManager and HistoryServer.  If using MRv1, this will install
and set up the JobTracker.

### For your Hadoop worker nodes:
```puppet
include cdh4::hadoop::worker
```

This installs and starts up the DataNode.  If using YARN, this will install
and set up the NodeManager.  If using MRv1, this will install and set up the
TaskTracker.

# Notes:

## Coming Soon:

- Hive
- Oozie
- Hue
