# This file contains classes to manage the various
# Hadoop services.  Each of the ::service:: classes
# require their corresponding ::install:: classes.
#
# You should probably not include these classes directly,
# but instead use the hadoop::master and hadoop::worker
# classes defined in hadoop.pp.


class cdh4::hadoop::service::namenode {
	require cdh4::hadoop::install::namenode
	require cdh4::hadoop::config


	file { "$cdh4::hadoop::config::config_directory/hosts.exclude": 
		ensure => "file"
	}

	service { "hadoop-hdfs-namenode": 
		ensure   => "running",
		enable  => true,
		alias   => "namenode",
		require => File["$cdh4::hadoop::config::config_directory/hosts.exclude"],
	}
}

class cdh4::hadoop::service::secondarynamenode {
	require cdh4::hadoop::install::secondarynamenode
	require cdh4::hadoop::config

	service { "hadoop-hdfs-secondarynamenode": 
		ensure => "running",
		enable => true,
		alias  => "secondarynamenode",
	}
}

class cdh4::hadoop::service::datanode {
	require cdh4::hadoop::install::datanode
	require cdh4::hadoop::config

	# install datanode daemon package
	service { "hadoop-hdfs-datanode": 
		ensure => "running",
		enable => true,
		alias  => "datanode",
	}
}

#
# YARN services
#

class cdh4::hadoop::service::resourcemanager {
	require cdh4::hadoop::install::resourcemanager
	require cdh4::hadoop::config

	# ResourceManager (YARN JobTracker)
	service { "hadoop-yarn-resourcemanager":
		ensure => "running",
		enable => true,
		alias  => "resourcemanager",
	}
}


class cdh4::hadoop::service::nodemanager {
	# nodemanagers are also datanodes
	require cdh4::hadoop::install::nodemanager
	require cdh4::hadoop::config

	# NodeManager (YARN TaskTracker)
	service { "hadoop-yarn-nodemanager":
		ensure => "running",
		enable => true,
		alias  => "nodemanager",
	}
}

class cdh4::hadoop::service::historyserver {
	require cdh4::hadoop::install::historyserver
	require cdh4::hadoop::config

	service { "hadoop-mapreduce-historyserver":
		ensure    => "running",
		enable    => true,
		alias     => "historyserver",
		subscribe => File["$cdh4::hadoop::config::config_directory/mapred-site.xml"],
	}
}

class cdh4::hadoop::service::proxyserver {
	require cdh4::hadoop::install::proxyserver
	require cdh4::hadoop::config

	# install proxyserver daemon package
	service { "hadoop-yarn-proxyserver":
		ensure => "running",
		enable => true,
		alias  => "proxyserver",
	}
}


# Class: cdh4::hadoop::service::jobtracker
class cdh4::hadoop::service::jobtracker {
    require cdh4::hadoop::install::jobtracker
 	require cdh4::hadoop::config

    service { "hadoop-0.20-mapreduce-jobtracker":
        ensure => "running",
        enable => true,
    }
}

# Class: cdh4::hadoop::service::tasktracker
class cdh4::hadoop::service::tasktracker {
    require cdh4::hadoop::install::tasktracker

    service { "hadoop-0.20-mapreduce-tasktracker":
        ensure => "running",
        enable => true,
    }
}
