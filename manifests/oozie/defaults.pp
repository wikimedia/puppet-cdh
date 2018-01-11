# == Class cdh::oozie::defaults
#
class cdh::oozie::defaults {
    $database                                    = 'mysql'

    $jdbc_driver                                 = 'com.mysql.jdbc.Driver'
    $jdbc_protocol                               = 'mysql'
    $jdbc_database                               = 'oozie'
    $jdbc_host                                   = 'localhost'
    $jdbc_port                                   = 3306
    $jdbc_username                               = 'oozie'
    $jdbc_password                               = 'oozie'

    $db_root_username                            = undef
    $db_root_password                            = undef

    $smtp_host                                   = undef
    $smtp_port                                   = 25
    $smtp_from_email                             = undef
    $smtp_username                               = undef
    $smtp_password                               = undef

    $authorization_service_authorization_enabled = true
    $admin_users                                 = ['hdfs']
    $java_home                                   = undef
    $jvm_opts                                    = '-Xmx1024m'
    $purge_jobs_older_than_days                  = 90

    # Default puppet paths to template config files.
    # This allows us to use custom template config files
    # if we want to override more settings than this
    # module yet supports.
    $oozie_site_template                         = 'cdh/oozie/oozie-site.xml.erb'
    $oozie_env_template                          = 'cdh/oozie/oozie-env.sh.erb'
    $oozie_log4j_template                        = 'cdh/oozie/oozie-log4j.properties.erb'
}
