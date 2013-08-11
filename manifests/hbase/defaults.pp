# == Class cdh4::hbase::defaults
# Default parameters for cdh4::hbase configuration.
#
class cdh4::hbase::defaults {
  $rootdir         = '/hbase'
  $config_directory = '/etc/hbase/conf'
  $zookeeper_hosts = undef
}
