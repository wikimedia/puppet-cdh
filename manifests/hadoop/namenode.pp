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

    if ($::cdh::hadoop::ha_enabled and $::cdh::hadoop::zookeeper_hosts) {
        if !defined(Package['zookeeper']) {
            package { 'zookeeper':
                ensure => 'installed'
            }
        }

        package { 'hadoop-hdfs-zkfc':
            ensure => 'installed',
        }
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

    if ($::cdh::hadoop::ha_enabled and $::cdh::hadoop::zookeeper_hosts) {
        # Create a znode in ZooKeeper inside of which the automatic failover
        # system stores its data. The command will create a znode in ZooKeeper
        # and it needs to be executed only when the znode is not present.

        # Catch-all if the zookeeper_hosts is not an array.
        $zookeeper_hosts = $::cdh::hadoop::zookeeper_hosts
        $zookeeper_hosts_string = inline_template(
            '<%= Array(@zookeeper_hosts).join(",") %>'
        )

        exec { 'hadoop-hdfs-zkfc-init':
            # If the znode created by -formatZK already exists, and for
            # some buggy reason it happens to run, -formatZK will prompt
            # the user to confirm if the znode should be reformatted.
            # Puppet isn't able to answer this question on its own.
            # Default to answering with 'N' if the command asks.
            # This should never happen, but just in case it does,
            # We don't want this eternally unanswered prompt to fill up
            # puppet logs and disks.
            command => '/bin/echo N | /usr/bin/hdfs zkfc -formatZK',
            user    => 'hdfs',
            require => [
                Service['hadoop-hdfs-namenode'],
                Package['zookeeper'],
            ],
            # Don't attempt to run this command if the znode already exists
            # or if a Java Exception is returned by the zkCli tool containing
            # the ERROR log (for example when the Zookeeper node is down).
            unless  => "/usr/lib/zookeeper/bin/zkCli.sh \
                -server ${zookeeper_hosts_string} \
                stat /hadoop-ha/${::cdh::hadoop::cluster_name} 2>&1 \
                | /bin/egrep -q 'ctime|ERROR'",
        }

        # Supporting daemon to enable automatic-failover via health-check.
        # Stores its state in zookeper.
        service { 'hadoop-hdfs-zkfc':
            ensure     => 'running',
            enable     => true,
            hasstatus  => true,
            hasrestart => true,
            require    => [
                Exec['hadoop-hdfs-zkfc-init'],
                Service['hadoop-hdfs-namenode'],
            ],
        }
    }
}
