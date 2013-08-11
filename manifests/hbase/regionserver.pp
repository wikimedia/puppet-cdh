# == Class cdh4::hbase::master
# Installs HBase regionserver
#
class cdh4::hbase::regionserver {

  Class['cdh4::hbase'] -> Class['cdh4::hbase::regionserver']

  package { 'hbase-regionserver': 
    ensure => 'installed',
  }

  service { 'hbase-regionserver':
    ensure      => 'running',
    enable      => true,
    hasrestart  => true,
  }

}
