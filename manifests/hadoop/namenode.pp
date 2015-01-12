# == Class cdh::hadoop::namenode
# Installs and configureds Hadoop NameNode.
# This will format the NameNode if it is not
# already formatted.  It will also create
# a common HDFS directory hierarchy.
#
# Note:  If you are using HA NameNode (indicated by setting
# cdh::hadoop::nameservice_id), your JournalNodes should be running before
# this class is applied.
#
class cdh::hadoop::namenode {
    Class['cdh::hadoop'] -> Class['cdh::hadoop::namenode']

    # install namenode daemon package
    package { 'hadoop-hdfs-namenode':
        ensure => 'installed',
    }

    # NameNodes expect that the hosts.exclude file exists.
    # I don't want to manage this as a puppet file resource,
    # as users of this class might want to manage it themselves.
    # Instead, this exec just touches the file if it doesn't exist.
    exec { 'touch hosts.exclude':
        command => "/usr/bin/touch ${::cdh::hadoop::config_directory}/hosts.exclude",
        unless  => "/usr/bin/test -f ${::cdh::hadoop::config_directory}/hosts.exclude",
        require => Package['hadoop-hdfs-namenode'],
    }

    # Ensure that the namenode directory has the correct permissions.
    file { $::cdh::hadoop::dfs_name_dir:
        ensure  => 'directory',
        owner   => 'hdfs',
        group   => 'hdfs',
        mode    => '0700',
        require => Package['hadoop-hdfs-namenode'],
    }

    # If $dfs_name_dir/current/VERSION doesn't exist, assume
    # NameNode has not been formated.  Format it before
    # the namenode service is started.
    exec { 'hadoop-namenode-format':
        command => '/usr/bin/hdfs namenode -format -nonInteractive',
        creates => "${::cdh::hadoop::dfs_name_dir_main}/current/VERSION",
        user    => 'hdfs',
        require => [File[$::cdh::hadoop::dfs_name_dir], Exec['touch hosts.exclude']],
    }

    service { 'hadoop-hdfs-namenode':
        ensure     => 'running',
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        alias      => 'namenode',
        require    => Exec['hadoop-namenode-format'],
    }
}
