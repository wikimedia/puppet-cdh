# == Class cdh::spark
# Installs spark set up to work in YARN mode.
# You should include this on your client nodes.
# This does not need to be on all worker nodes.
#
# == Parameters
# $hive_support_enabled - If true, Hive jars will be automatically loaded
#                         into Spark's classpath, and hive-site.xml will
#                         be symlinked into /etc/spark/conf and cdh::hive
#                         will be added as a dependency.  Default: true
#
class cdh::spark(
    $hive_support_enabled = true,
)
{
    # Spark requires Hadoop configs installed.
    Class['cdh::hadoop'] -> Class['cdh::spark']

    # If we are using Hive, then require cdh::hive
    if $hive_support_enabled {
        Class['cdh::hive'] -> Class['cdh::spark']
    }

    package { ['spark-core', 'spark-python']:
        ensure => 'installed',
    }

    $config_directory = "/etc/spark/conf.${cdh::hadoop::cluster_name}"
    # Create the $cluster_name based $config_directory.
    file { $config_directory:
        ensure  => 'directory',
        require => Package['spark-core'],
    }
    cdh::alternative { 'spark-conf':
        link    => '/etc/spark/conf',
        path    => $config_directory,
    }


    # sudo -u hdfs hdfs dfs -mkdir /user/oozie
    # sudo -u hdfs hdfs dfs -chmod 0775 /user/oozie
    # sudo -u hdfs hdfs dfs -chown oozie:oozie /user/oozie
    cdh::hadoop::directory { '/user/spark':
        owner   => 'spark',
        group   => 'spark',
        mode    => '0755',
        require => Package['spark-core'],
    }

    cdh::hadoop::directory { '/user/spark/share':
        owner   => 'spark',
        group   => 'spark',
        mode    => '0755',
        require => Cdh::Hadoop::Directory['/user/spark'],

    }
    cdh::hadoop::directory { '/user/spark/share/lib':
        owner   => 'spark',
        group   => 'spark',
        mode    => '0755',
        require => Cdh::Hadoop::Directory['/user/spark/share'],
    }

    cdh::hadoop::directory { ['/user/spark/applicationHistory']:
        owner   => 'spark',
        group   => 'spark',
        mode    => '1775',
        require => Cdh::Hadoop::Directory['/user/spark'],
    }

    # Put Spark assembly jar into HDFS so that it d
    # doesn't have to be loaded for each spark job submission.
    $namenode_address = $::cdh::hadoop::ha_enabled ? {
        true    => $cdh::hadoop::nameservice_id,
        default => $cdh::hadoop::primary_namenode_host,
    }
    $spark_jar_hdfs_path = "hdfs://${namenode_address}/user/spark/share/lib/spark-assembly.jar"
    exec { 'spark_assembly_jar_install':
        command => "/usr/bin/hdfs dfs -put -f /usr/lib/spark/lib/spark-assembly.jar ${spark_jar_hdfs_path}",
        unless  => '/usr/bin/hdfs dfs -ls /user/spark/share/lib/spark-assembly.jar | grep -q /user/spark/share/lib/spark-assembly.jar',
        user    => 'spark',
        require => Cdh::Hadoop::Directory['/user/spark/share/lib'],
    }

    file { "${config_directory}/spark-env.sh":
        content => template('cdh/spark/spark-env.sh.erb'),
        require => Exec['spark_assembly_jar_install'],
    }

    file { "${config_directory}/spark-defaults.conf":
        content => template('cdh/spark/spark-defaults.conf.erb'),
        require => Exec['spark_assembly_jar_install'],
    }


    file { "${config_directory}/log4j.properties":
        source => 'puppet:///modules/cdh/spark/log4j.properties',
    }

    $hive_site_symlink_ensure = $hive_support_enabled ? {
        true    => 'link',
        default => 'absent'
    }
    # If Hive support is enabled, then symlink hive-site.xml into /etc/spark/conf
    file { "${config_directory}/hive-site.xml":
        ensure => $hive_site_symlink_ensure,
        target => "${::cdh::hive::config_directory}/hive-site.xml",
    }
}
