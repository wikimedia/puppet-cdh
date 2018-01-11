# == Class cdh::oozie::server
#
# Installs and configureds oozie server.  You must have an oozie
# database somewhere that is reachable by this oozie server.
# Configure the various $jdbc_ parameters to inform oozie server
# of how to connect to this database.
#
# If $jdbc_protocol = 'mysql', this class will attempt to
# initialize the oozie database using /usr/lib/oozie/bin/ooziedb.sh.
# To ensure this only happens initially, a mysql client is
# required at /usr/bin/mysql.
#
#
# See: http://www.cloudera.com/content/cloudera-content/cloudera-docs/CDH5/latest/CDH5-Installation-Guide/cdh5ig_oozie_configure.html
#
# == Parameters
# $jdbc_database                 - Oozie database name.                   Default: oozie
# $jdbc_username                 - Oozie JDBC username.                   Default: oozie
# $jdbc_password                 - Oozie JDBC password.                   Default: oozie
# $jdbc_host                     - Oozie JDBC hostname.                   Default: localhost
# $jdbc_port                     - Oozie JDBC port.                       Default: 3306
# $jdbc_driver                   - Oozie JDBC driver class name.          Default: com.mysql.jdbc.Driver
# $jdbc_protocol                 - Name of database protocol.             Default: mysql
# $db_root_username              - username for metastore database creation commands. Default: undef
# $db_root_password              - password for metastore database creation commands.
#                                  Only set these if your root user cannot issue database
#                                  commands without a different username and password.
#                                  Default: undef
# $smtp_host                     - SMTP host for email notifications.
#                                  Default: undef, SMTP will not be configured.
# $smtp_port                     - SMTP port.                             Default: 25
# $smtp_from_email               - Sender email address of notifications. Default: undef
# $smtp_username                 - Username for SMTP authentication.      Default: undef
# $smtp_password                 - Password for SMTP authentication.      Default: undef
#
# $authorization_service_security_enabled - If disabled any user can manage Oozie
#                                           system and manage any job.  Default: true
# $admin_users                   - Array of users that are oozie admins.  Default: ['hdfs']
# $heapsize                      - Xmx in MB to pass to oozie server.  Default: 1024
# $purge_jobs_older_than_days    - Completed workflow, coordinator, and bundle
#                                  jobs will be deleted after this many days.
#                                  Default: 90
#
class cdh::oozie::server(
    $jdbc_database                               = $cdh::oozie::defaults::jdbc_database,
    $jdbc_username                               = $cdh::oozie::defaults::jdbc_username,
    $jdbc_password                               = $cdh::oozie::defaults::jdbc_password,
    $jdbc_host                                   = $cdh::oozie::defaults::jdbc_host,
    $jdbc_port                                   = $cdh::oozie::defaults::jdbc_port,
    $jdbc_driver                                 = $cdh::oozie::defaults::jdbc_driver,
    $jdbc_protocol                               = $cdh::oozie::defaults::jdbc_protocol,

    $db_root_username                            = $cdh::oozie::defaults::db_root_username,
    $db_root_password                            = $cdh::oozie::defaults::db_root_password,

    $smtp_host                                   = $cdh::oozie::defaults::smtp_host,
    $smtp_port                                   = $cdh::oozie::defaults::smtp_port,
    $smtp_from_email                             = $cdh::oozie::defaults::smtp_from_email,
    $smtp_username                               = $cdh::oozie::defaults::smtp_username,
    $smtp_password                               = $cdh::oozie::defaults::smtp_password,

    $authorization_service_authorization_enabled = $cdh::oozie::defaults::authorization_service_authorization_enabled,
    $admin_users                                 = $cdh::oozie::defaults::admin_users,
    $java_home                                   = $cdh::oozie::defaults::java_home,
    $jvm_opts                                    = $cdh::oozie::defaults::jvm_opts,
    $purge_jobs_older_than_days                  = $cdh::oozie::defaults::purge_jobs_older_than_days,
    $oozie_site_template                         = $cdh::oozie::defaults::oozie_site_template,
    $oozie_env_template                          = $cdh::oozie::defaults::oozie_env_template,
    $oozie_log4j_template                        = $cdh::oozie::defaults::oozie_log4j_template
) inherits cdh::oozie::defaults
{
    # cdh::oozie::server requires Hadoop client and configs are installed.
    Class['cdh::hadoop'] -> Class['cdh::oozie::server']
    # Also require cdh::oozie client class.
    Class['cdh::oozie']  -> Class['cdh::oozie::server']

    package { 'oozie':
        ensure => 'installed',
    }

    $config_directory = "/etc/oozie/conf.${cdh::hadoop::cluster_name}"
    # Create the $cluster_name based $config_directory.
    file { $config_directory:
        ensure  => 'directory',
        require => Package['oozie'],
    }
    cdh::alternative { 'oozie-conf':
        link => '/etc/oozie/conf',
        path => $config_directory,
    }

    # TODO: This doesn't work, Oozie Web UI references ext-2.2
    # files directly, which cause 404s and Javascript errors
    # with the libjs-extjs package (which is version 3.0.3)

    # # Oozie needs extjs for its web UI.
    # if (!defined(Package['libjs-extjs'])) {
    #     package { 'libjs-extjs':
    #         ensure => 'installed',
    #     }
    # }
    # # Symlink extjs install path into /var/lib/oozie.
    # # This is required for the Oozie web interface to work.
    # file { '/var/lib/oozie/extjs':
    #     ensure  => 'link',
    #     target  => '/usr/share/javascript/extjs',
    #     require => [Package['oozie'], Package['libjs-extjs']],
    # }

    # Extract and install Oozie ShareLib into HDFS
    # at /user/oozie/share/lib/lib_<timestamp>
    # See also:
    # http://blog.cloudera.com/blog/2014/05/how-to-use-the-sharelib-in-apache-oozie-cdh-5/

    # sudo -u hdfs hdfs dfs -mkdir /user/oozie
    # sudo -u hdfs hdfs dfs -chmod 0775 /user/oozie
    # sudo -u hdfs hdfs dfs -chown oozie:oozie /user/oozie
    cdh::hadoop::directory { '/user/oozie':
        owner   => 'oozie',
        group   => 'hadoop',
        mode    => '0755',
        require => Package['oozie'],
    }

    # Put oozie sharelib into HDFS:
    $oozie_sharelib_archive = '/usr/lib/oozie/oozie-sharelib-yarn'

    $namenode_address = $::cdh::hadoop::ha_enabled ? {
        true    => $cdh::hadoop::nameservice_id,
        default => $cdh::hadoop::primary_namenode_host,
    }
    $hdfs_uri               = "hdfs://${namenode_address}"

    exec { 'oozie_sharelib_install':
        command => "/usr/bin/oozie-setup sharelib create -fs ${hdfs_uri} -locallib ${oozie_sharelib_archive}",
        unless  => '/usr/bin/hdfs dfs -ls /user/oozie | grep -q /user/oozie/share',
        user    => 'root',
        require => Cdh::Hadoop::Directory['/user/oozie'],
    }

    file { "${config_directory}/oozie-site.xml":
        content => template($oozie_site_template),
        mode    => '0440',  # has database pw in it, shouldn't be world readable.
        owner   => 'root',
        group   => 'oozie',
    }
    file { "${config_directory}/oozie-env.sh":
        content => template($oozie_env_template),
        mode    => '0444',
        owner   => 'root',
        group   => 'oozie',
    }
    file { "${config_directory}/oozie-log4j.properties":
        content => template($oozie_log4j_template),
        mode    => '0444',
        owner   => 'root',
        group   => 'oozie',
    }
    file { "${config_directory}/adminusers.txt":
        content => inline_template("# Admin Users, one user by line\n<%= Array(@admin_users).join('\n') %>\n"),
        mode    => '0440',  # has database pw in it, shouldn't be world readable.
        owner   => 'root',
        group   => 'oozie',
    }
    # Oozie needs action-conf directory inside of $config_directory
    #  to exist, even if there are no files in it.
    file { "${config_directory}/action-conf":
        ensure  => 'directory',
    }

    if ($jdbc_protocol == 'mysql') {
        # Need libmysql-java in /var/lib/oozie.
        if (!defined(Package['libmysql-java'])) {
            package { 'libmysql-java':
                ensure => 'installed',
            }
        }

        # symlink mysql.jar into /var/lib/oozie
        file { '/var/lib/oozie/mysql.jar':
            ensure  => 'link',
            target  => '/usr/share/java/mysql.jar',
            require => [Package['oozie'], Package['libmysql-java']],
        }

        # Run ooziedb.sh to create the oozie database schema.
        # This is here instead of in the cdh::oozie::database::mysql
        # class because ooziedb.sh is included in the 'oozie' server
        # package.
        exec { 'oozie_mysql_create_schema':
            command => '/usr/lib/oozie/bin/ooziedb.sh create -run',
            require => File['/var/lib/oozie/mysql.jar'],
            # TODO: Are we sure /usr/bin/mysql is installed?!
            unless  => "/usr/bin/mysql -h${jdbc_host} -P'${jdbc_port}' -u'${jdbc_username}' -p'${jdbc_password}' ${jdbc_database} -BNe 'SHOW TABLES;' | /bin/grep -q WF_JOBS",
            user    => 'oozie',
            before  => Service['oozie'],
        }
    }

    service { 'oozie':
        ensure     => 'running',
        hasrestart => true,
        hasstatus  => true,
        require    => [
            File["${config_directory}/oozie-site.xml"],
            File["${config_directory}/oozie-env.sh"]
        ],
        # require    => File['/var/lib/oozie/extjs'],
    }
}
