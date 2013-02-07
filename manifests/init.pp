
# == Class cdh4
#
# Installs common Cloudera / Hadoop packages.
class cdh4 {
	case $::operatingsystem {
		"debian", "ubuntu": { }
		"centos": { }
		default: {
			fail("Module ${module_name} is not supported on ${::operatingsystem}")
		}
	}

	include hadoop
	include hbase
	include hive
	include zookeeper
	include pig
	include sqoop
	include oozie
}
