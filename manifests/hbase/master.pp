# == Class cdh4::hbase::master
# Installs HBase master
#
class cdh4::hbase::master {

  Class['cdh4::hbase'] -> Class['cdh4::hbase::master']

  package { 'hbase-master': 
    ensure => 'installed',
  }

  service { 'hbase-master':
    ensure      => 'running',
    enable      => true,
    hasrestart  => true,
  }

  # sudo -u hdfs hadoop fs -mkdir /hbase
  # sudo -u hdfs hadoop fs -chown hbase /hbase
  cdh4::hadoop::directory { "${::cdh4::hbase::rootdir}":
    owner   => 'hbase',
    group   => 'hbase',
  }

}
