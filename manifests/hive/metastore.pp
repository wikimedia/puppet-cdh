# == Class cdh::hive::metastore
# Configures hive-metastore.
# See: http://www.cloudera.com/content/cloudera-content/cloudera-docs/CDH5/latest/CDH5-Installation-Guide/cdh5ig_hive_metastore_configure.html
#
# == Parameters
# $port       - Port on which hive-metastore listens.  Default: undef
# $heapsize   - -Xmx in MB. Default: undef
#
class cdh::hive::metastore(
    $port             = undef,
    $heapsize         = undef,
    $jmx_port         = $cdh::hive::defaults::hive_metastore_jmx_port,
    $default_template = 'cdh/hive/hive-metastore.default.erb',
)
{
    Class['cdh::hive'] -> Class['cdh::hive::metastore']

    package { 'hive-metastore':
        ensure => 'installed',
    }

    file { '/etc/default/hive-metastore':
        content => template($default_template),
        require => Package['hive-metastore'],
    }

    # If the metastore will use MySQL for storage, then
    # we need to make sure the libmysql-java .jar is in
    # hive-metastore's classpath before it launches.
    if $::cdh::hive::jdbc_protocol == 'mysql' {
        include cdh::hive::metastore::mysql::jar
        Class['cdh::hive::metastore::mysql::jar'] -> Service['hive-metastore']
    }

    service { 'hive-metastore':
        ensure     => 'running',
        require    => [
            Package['hive-metastore'],
            File['/etc/default/hive-metastore'],
        ],
        hasrestart => true,
        hasstatus  => true,
    }
}