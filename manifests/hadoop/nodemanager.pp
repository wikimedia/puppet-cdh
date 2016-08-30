# == Class cdh::hadoop::nodemanager
# Installs and configures a Hadoop NodeManager worker node.
#
class cdh::hadoop::nodemanager {
    Class['cdh::hadoop'] -> Class['cdh::hadoop::nodemanager']


    package { ['hadoop-yarn-nodemanager', 'hadoop-mapreduce']:
        ensure => 'installed',
    }

    # Some Hadoop jobs need Zookeeper libraries, but for some reason they
    # are not installed via package dependencies.  Install the CDH
    # zookeeper package here explicitly.  This avoids
    # java.lang.NoClassDefFoundError: org/apache/zookeeper/KeeperException
    # errors.
    if !defined(Package['zoookeeper']) {
        package { 'zookeeper':
            ensure => 'installed'
        }
    }

    # NodeManager (YARN TaskTracker)
    service { 'hadoop-yarn-nodemanager':
        ensure     => 'running',
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        alias      => 'nodemanager',
        require    => [Package['hadoop-yarn-nodemanager', 'hadoop-mapreduce']],
    }
}

