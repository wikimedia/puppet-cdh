# == Class cdh4::hbase
#
# Installs HBase packages needed for server and region-servers
#
# == Parameters
#   $rootdir            - HBase root directory in HDFS
#   $config_directory   - Path of the HBase config directory
#   $zookeeper_hosts    - Array of Zookeeper hostnames 
#
class cdh4::hbase(
  $rootdir          = $::cdh4::hbase::defaults::rootdir,
  $config_directory = $::cdh4::hbase::defaults::config_directory,
  $zookeeper_hosts  = $::cdh4::hbase::defaults::zookeeper_master,
) inherits cdh4::hbase::defaults 
{
  Class['cdh4::hadoop'] -> Class['cdh4::hbase']
 
  package { 'hbase':
    ensure => 'installed',
  }

  $namenode_host = $::cdh4::hadoop::primary_namenode_host

  file { "${config_directory}/hbase-site.xml":
    content => template('cdh4/hbase/hbase-site.xml.erb'),
  }
}
