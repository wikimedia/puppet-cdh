# == Class cdh::hadoop::mount
# Mounts the HDFS filesystem at $mount_point using hadoop-hdfs-fuse.
#
# See: http://www.cloudera.com/content/cloudera-content/cloudera-docs/CDH5/latest/CDH5-Installation-Guide/cdh5ig_hdfs_mountable.html
#
# == Parameters
# $mount_point       - Path at which HDFS should be mounted.  This path will be
#                      ensured to be a directory.  Default: /mnt/hdfs
# $read_only         - If false, mount will be writeable.  Default: true
#
class cdh::hadoop::mount(
    $mount_point     = '/mnt/hdfs',
    $read_only       = true,
)
{
    Class['cdh::hadoop'] -> Class['cdh::hadoop::mount']

    package { 'hadoop-hdfs-fuse':
        ensure => 'installed',
    }

    $device = $::cdh::hadoop::ha_enabled ? {
        true    => "hadoop-fuse-dfs#dfs://${::cdh::hadoop::nameservice_id}",
        default => "hadoop-fuse-dfs#dfs://${::cdh::hadoop::primary_namenode_host}:8020",
    }

    $options = $read_only ? {
        true    => 'allow_other,usetrash,ro',
        default => 'allow_other,usetrash,rw',
    }

    file { $mount_point:
        ensure => 'directory',
    }

    mount { 'hdfs-fuse':
        ensure   => 'mounted',
        device   => $device,
        name     => $mount_point,
        fstype   => 'fuse',
        options  => $options,
        dump     => '0',
        pass     => '0',
        remounts => false,
        require  => [Package['hadoop-hdfs-fuse'], File[$mount_point]],
    }
}
