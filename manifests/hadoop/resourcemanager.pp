# == Class cdh::hadoop::resourcemanager
# Installs and configures Hadoop YARN ResourceManager.
# This will create YARN HDFS directories.
#
class cdh::hadoop::resourcemanager {
    Class['cdh::hadoop::namenode'] -> Class['cdh::hadoop::resourcemanager']

    # Create YARN HDFS directories.
    # See: http://www.cloudera.com/content/cloudera-content/cloudera-docs/CDH5/latest/CDH5-Installation-Guide/cdh5ig_yarn_cluster_deploy.html?scroll=topic_11_4_10_unique_1
    cdh::hadoop::directory { '/var/log/hadoop-yarn':
        # sudo -u hdfs hdfs dfs -mkdir /var/log/hadoop-yarn
        # sudo -u hdfs hdfs dfs -chown yarn:mapred /var/log/hadoop-yarn
        owner   => 'yarn',
        group   => 'mapred',
        mode    => '0755',
        # Make sure HDFS directories are created before
        # resourcemanager is installed and started, but after
        # the namenode.
        require => [Service['hadoop-hdfs-namenode'], Cdh::Hadoop::Directory['/var/log']],
    }

    package { 'hadoop-yarn-resourcemanager':
        ensure  => 'installed',
        require => Cdh::Hadoop::Directory['/var/log/hadoop-yarn'],
    }

    service { 'hadoop-yarn-resourcemanager':
        ensure     => 'running',
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        alias      => 'resourcemanager',
        require    => Package['hadoop-yarn-resourcemanager'],
    }
}
