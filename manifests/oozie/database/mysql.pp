# == Class cdh::oozie::database::mysql
# Configures and sets up a MySQL database for Oozie.
#
# Note that this class does not support running
# the Oozie database on a different host than where your
# oozie server will run.  Permissions will only be granted
# for localhost MySQL users, so oozie server must run on this node.
#
# See: http://www.cloudera.com/content/cloudera-content/cloudera-docs/CDH5/latest/CDH5-Installation-Guide/cdh5ig_oozie_configure.html
#
# == Parameters
# $db_root_username              - username for metastore database creation commands. Default: undef
# $db_root_password              - password for metastore database creation commands.
#
class cdh::oozie::database::mysql(
    $db_root_username            = $cdh::oozie::defaults::db_root_username,
    $db_root_password            = $cdh::oozie::defaults::db_root_password,
) inherits cdh::oozie::defaults
{
    # Infer mysql creds from either cdh::oozie::server class
    # or from hiera, if the cdh::oozie::server class has not been included.
    if defined(Class['cdh::oozie::server']) {
        $jdbc_database = $cdh::oozie::server::jdbc_database
        $jdbc_username = $cdh::oozie::server::jdbc_username
        $jdbc_password = $cdh::oozie::server::jdbc_password
    }
    else {
        $jdbc_database = hiera('cdh::oozie::server::jdbc_database', $cdh::oozie::defaults::jdbc_database)
        $jdbc_username = hiera('cdh::oozie::server::jdbc_username', $cdh::oozie::defaults::jdbc_username)
        $jdbc_password = hiera('cdh::oozie::server::jdbc_password', $cdh::oozie::defaults::jdbc_password)
    }

    # Only use -u or -p flag to mysql commands if
    # root username or root password are set.
    $username_option = $db_root_username ? {
        undef   => '',
        default => "-u'${db_root_username}'",
    }
    $password_option = $db_root_password? {
        undef   => '',
        default => "-p'${db_root_password}'",
    }

    # oozie is going to need an oozie database and user.
    exec { 'oozie_mysql_create_database':
        command => "/usr/bin/mysql ${username_option} ${password_option} -e \"
CREATE DATABASE ${jdbc_database};
GRANT ALL PRIVILEGES ON ${jdbc_database}.* TO '${jdbc_username}'@'localhost' IDENTIFIED BY '${jdbc_password}';
GRANT ALL PRIVILEGES ON ${jdbc_database}.* TO '${jdbc_username}'@'127.0.0.1' IDENTIFIED BY '${jdbc_password}';\"",
        unless  => "/usr/bin/mysql ${username_option} ${password_option} -BNe 'SHOW DATABASES' | /bin/grep -q ${jdbc_database}",
        user    => 'root',
    }
}
