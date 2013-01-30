# puppet-cdh4

Puppet module to install and manage components of a YARN installation of
Cloudera's Distribution 4 (CDH4) for Apache Hadoop.

# Description
Installs HDFS, YARN MapReduce, hive, hbase, pig, sqoop, zookeeper, oozie and
hue.  Note that, in order for this module to work, you will have to ensure
that:
* Sun JRE version 6 or greater is installed
* Your package manager is configured with a repository containing the
  Cloudera 4 packages.  (See examples/cloudera_apt.pp)

The ```cdh4::hadoop::master``` and ```cdh4::hadoop::worker``` classes will
manage hadoop services.


# Installation:
Clone (or copy) this repository into your puppet modules/cdh4 directory:
```bash
git clone git://github.com/wmf-analytics/cloudera-cdh4-puppet.git modules/cdh4
```

Or you could also use a git submodule:
```bash
git submodule add git://github.com/wmf-analytics/cloudera-cdh4-puppet.git modules/cdh4
git commit -m 'Adding modules/cdh4 as a git submodule.'
```

The ```cdh4::apt_source``` class will make the packages available from Cloudera's
apt repository.  If you are installing on a different Linux, then you'll need
to make sure that the packages are available somehow.

# Usage

## For all Hadoop nodes:
```puppet


include cdh4
class { "cdh4::hadoop::config":
	namenode_hostname => "namenode.hostname.org",
	mounts            => [
	    "/var/lib/hadoop/data/a",
	    "/var/lib/hadoop/data/b",
	    "/var/lib/hadoop/data/c"
	],
	dfs_name_dir      => ["/var/lib/hadoop/name", "/mnt/hadoop_name"],
}
```
This will ensure that CDH4 client packages are installed, and that
Hadoop related config files are in place with proper settings.

The mounts parameter assumes that you want to keep your
```dfs.datanode.data.dir```, ```yarn.nodemanager.local-dirs```, and
```yarn.nodemanager.log-dirs``` all as subdirectories in each of the mount
points provided.


## For your Hadoop master NameNode:
```puppet
include cdh4::hadoop::master
```
This installs and starts up the NameNode, ResourceManager and HistoryServer.

## For your Hadoop worker DataNodes:
```puppet
include cdh4::hadoop::worker
```
This installs and starts up the DataNode and NodeManager.

See [examples/](puppet-cdh4/tree/master/examples) for more ideas on how to use this module.
[examples/analytics.pp](puppet-cdh4/tree/master/examples/analytics.pp) shows an organized way you could group and install
the cdh4 classes.

## Requirements
This module was developed for  Ubuntu 12.04 LTS.  Since Cloudera's
package names are consistent across Linuxes, much of this could work in other
distributions.  However, there are pieces that will require tweaking for
that to work properly, so currently this module is restricted to Debian
and Ubuntu.
