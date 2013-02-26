
# == Class cdh4::hadoop
#
# Ensures that hadoop client packages are installed.
# All hadoop nodes require this class.
class cdh4::hadoop {
  include cdh4::hadoop::install::client
}

# == Class cdh4::hadoop::yarn::master
#
# The Hadoop Master is the NameNode,  ResourceManager, and HistoryServer.
# This ensures that the proper packages are installed, and that
# the services are running.
class cdh4::hadoop::yarn::master inherits cdh4::hadoop {
	include cdh4::hadoop::service::namenode
	include cdh4::hadoop::service::resourcemanager
	include cdh4::hadoop::service::historyserver

	# TODO:  Do we need this on master?
	# cdh4::hadoop::service::proxyserver
}

# == Class cdh4::hadoop::master
# Just a compatibility class, points to cdh4::hadoop::yarn::master
class cdh4::hadoop::master {

    include cdh4::hadoop::yarn::master
}

# == Class cdh4::hadoop::worker
# Just a compatibility class, points to cdh4::hadoop::yarn::worker
class cdh4::hadoop::worker {
    include cdh4::hadoop::yarn::worker
}

# == Class cdh4::hadoop::yarn::worker
#
# A Hadoop worker node is the DataNode and NodeManager.
class cdh4::hadoop::yarn::worker inherits cdh4::hadoop {
	include cdh4::hadoop::service::datanode
	include cdh4::hadoop::service::nodemanager
}

# == Class cdh4::hadoop::mr1::master
#
# The Hadoop Master is the NameNode and Jobtracker.
# This ensures that the proper packages are installed, and that
# the services are running.
class cdh4::hadoop::mr1::master inherits cdh4::hadoop {
	include cdh4::hadoop::service::namenode
	include cdh4::hadoop::service::jobtracker

}


# == Class cdh4::hadoop::mr1::worker
#
# A Hadoop worker node is the DataNode and Tasktracker.
class cdh4::hadoop::mr1::worker inherits cdh4::hadoop {
	include cdh4::hadoop::service::datanode
	include cdh4::hadoop::service::tasktracker
}