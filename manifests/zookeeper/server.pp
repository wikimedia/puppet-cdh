# == Class cdh4::zookeeper::server
# Ensures that myid is in place and that the zookeep-server is running
class cdh4::zookeeper::server inherits cdh4::zookeeper::config {
	# Infer the current node's myid from numbers in the hostname.
	$myid = inline_template("<%= @zookeeper_hosts[fqdn] %>")
	notice("${myid}")

	# init the zookeeper data dir
	exec { "zookeeper-server-initialize":
		command => "/usr/bin/zookeeper-server-initialize --myid=${myid}",
		unless  => "/usr/bin/test -f $cdh4::zookeeper::config::data_dir/myid",
		user    => "zookeeper",
		require => Class["cdh4::zookeeper::config"],
	}

	# manage the zookeeper-server service
	class { "cdh4::zookeeper::service":
		require => Exec["zookeeper-server-initialize"],
	}
}