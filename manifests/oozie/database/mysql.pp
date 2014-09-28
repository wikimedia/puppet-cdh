# == Class cdh::oozie::database::mysql
# Configures and sets up a MySQL database for Oozie.
#
# Note that this class does not support running
# the Oozie database on a different host than where your
# oozie server will run.  Permissions will only be granted
# for localhost MySQL users, so oozie server must run on this node.
#
# Also, root must be able to run /usr/bin/mysql with no password and have permissions
# to create databases and users and grant permissions.
#
# You probably shouldn't be including this class directly.  Instead, include
# cdh::oozie::server with database => 'mysql'.
#
# See: http://www.cloudera.com/content/cloudera-content/cloudera-docs/CDH5/latest/CDH5-Installation-Guide/cdh5ig_oozie_configure.html
#
class cdh::oozie::database::mysql {
    Class['cdh::oozie'] -> Class['cdh::oozie::database::mysql']

    if (!defined(Package['libmysql-java'])) {
        package { 'libmysql-java':
            ensure => 'installed',
        }
    }

    # symlink mysql.jar into /var/lib/oozie
    file { '/var/lib/oozie/mysql.jar':
        ensure  => 'link',
        target  => '/usr/share/java/mysql.jar',
        require => Package['libmysql-java'],
    }

    $db_host = $cdh::oozie::server::jdbc_host
    $db_name = $cdh::oozie::server::jdbc_database
    $db_user = $cdh::oozie::server::jdbc_username
    $db_pass = $cdh::oozie::server::jdbc_password

    # Only use -u or -p flag to mysql commands if
    # root username or root password are set.
    $username_option = $cdh::oozie::server::db_root_username ? {
        undef   => '',
        default => "-u'${cdh::oozie::server::db_root_username}'",
    }
    $password_option = $cdh::oozie::server::db_root_password ? {
        undef   => '',
        default => "-p'${cdh::oozie::server::db_root_password}'",
    }

    # oozie is going to need an oozie database and user.
    exec { 'oozie_mysql_create_database':
        command => "/usr/bin/mysql ${username_option} ${password_option} -e \"
CREATE DATABASE ${db_name};
GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user}'@'localhost' IDENTIFIED BY '${db_pass}';
GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user}'@'127.0.0.1' IDENTIFIED BY '${db_pass}';\"",
        unless  => "/usr/bin/mysql ${username_option} ${password_option} -BNe 'SHOW DATABASES' | /bin/grep -q ${db_name}",
        user    => 'root',
    }

    # run ooziedb.sh to create the oozie database schema
    exec { 'oozie_mysql_create_schema':
        command => '/usr/lib/oozie/bin/ooziedb.sh create -run',
        require => [Exec['oozie_mysql_create_database'], File['/var/lib/oozie/mysql.jar']],
        unless  => "/usr/bin/mysql ${username_option} ${password_option} -u${db_user} -p'${db_pass}' ${db_name} -BNe 'SHOW TABLES;' | /bin/grep -q OOZIE_SYS",
        user    => 'oozie',
    }
}
