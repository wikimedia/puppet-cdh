

# == Class analytics::zookeeper::config
# Sets up zoo.cfg with the proper zookeeper server list.
#
class analytics::zookeeper::config {
	$zookeeper_hosts = {
		"zookeeper1" => 1,
		"zookeeper2" => 2,
		"zookeeper3" => 3
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