# == Class cdh::hadoop::users
# Ensures that all users in the posix group $group
# have HDFS user directories at /user/<username>
#
# == Parameters
# $group        - Group name in which all users should have
#                 access to Hadoop.  Default: hadoop
#
# == Usage
# The following will ensure that any users in the
# posix group 'my-analytics-group' have HDFS user
# directories.
#
#    class { 'cdh::hadoop::users':
#        group => 'my-analytics-group',
#    }
#
class cdh::hadoop::users($group = 'hadoop') {
    Class['cdh::hadoop'] -> Class['cdh::hadoop::users']

    file { '/usr/local/bin/create_hdfs_user_directories.sh':
        source => 'puppet:///modules/cdh/hadoop/create_hdfs_user_directories.sh',
        mode   => '0755',
    }

    exec { 'create_hdfs_user_directories':
        command   => "/usr/local/bin/create_hdfs_user_directories.sh --verbose ${group}",
        unless    => "/usr/local/bin/create_hdfs_user_directories.sh --check-for-changes ${group}",
        user      => 'hdfs',
        logoutput => true,
    }
}
