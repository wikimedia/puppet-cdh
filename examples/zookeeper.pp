

# == Class analytics::zookeeper::config
# Sets up zoo.cfg with the proper zookeeper server list.
#
class analytics::zookeeper::config {
	$zookeeper_hosts = {
		"zookeeper1.cluster.example" => 1,
		"zookeeper2.cluster.example" => 2,
		"zookeeper3.cluster.example" => 3
	}

	class { "cdh4::zookeeper::config":
		zookeeper_hosts => $zookeeper_hosts,
	}
}

# == Class analytics::zookeeper::server
# Installs and configures a zookeeper server.
#
class analytics::zookeeper::server {
	require analytics::zookeeper::config
	include cdh4::zookeeper::server
}