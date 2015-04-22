# == Class cdh::impala::worker
# Installs and runs impalad server.
# You should probably include this on all your Hadoop worker nodes
#
class cdh::impala::worker inherits cdh::impala {
    package {'impala-server':
        ensure => 'installed',
    }

    $hadoop_config_directory = $::cdh::hadoop::config_directory
    $fair_scheduler_enabled = $::cdh::hadoop::fair_scheduler_enabled

    # Create a path in which to store Cgroups for Impala.
    $cgroup_path = '/sys/fs/cgroup/impala'
    file { $cgroup_path:
        ensure  => 'directory',
        owner   => 'impala',
        group   => 'impala',
        require => Package['impala-server'],
    }

    file { '/etc/default/impala':
        content => template('cdh/impala/default-impala.erb'),
        require => Package['impala-server'],
    }

    service { 'impala-server':
        ensure     => 'running',
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        require    => [
            Package['impala-server'],
            File[$cgroup_path],
            File['/etc/default/impala'],
        ]
    }
}
