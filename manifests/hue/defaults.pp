# == Class cdh::hue::defaults
#
class cdh::hue::defaults {
    $http_host                  = '0.0.0.0'
    $http_port                  = 8888
    $secret_key                 = undef
    $app_blacklist              = ['hbase', 'impala', 'search', 'spark', 'rdbms', 'zookeeper']

    $hive_server_host           = undef

    # Set Hue Oozie defaults to those already
    # set in the cdh::oozie class.
    if (defined(Class['cdh::oozie'])) {
        $oozie_url              = $cdh::oozie::url
        $oozie_proxy_regex      = "${cdh::oozie::oozie_host}:(11000|11443)"
    }
    # Otherwise disable Oozie interface for Hue.
    else {
        $oozie_url              = undef
        $oozie_proxy_regex      = ''

    }
    $oozie_security_enabled     = false

    # local variable to use in inline_template below
    $namenode_hosts = $cdh::hadoop::namenode_hosts
    $proxy_whitelist            = [
        # namenode + resourcemanager + history server host and ports
        inline_template("(<%= @namenode_hosts.join('|') %>):(50070|50470|8088|19888)"),
        # Oozie Web UI.
        $oozie_proxy_regex,
        # No way to determine DataNode or NodeManager hostname defaults.
        # If you want to restrict this, make sure you override $proxy_whitelist parameter.
        '.+:(50075|8042)',
    ]
    $proxy_blacklist            = undef

    $smtp_host                  = 'localhost'
    $smtp_port                  = 25
    $smtp_user                  = undef
    $smtp_password              = undef
    $smtp_from_email            = undef

    $ssl_private_key            = '/etc/ssl/private/hue.key'
    $ssl_certificate            = '/etc/ssl/certs/hue.cert'
    $secure_proxy_ssl_header    = false

    $ldap_url                   = undef
    $ldap_cert                  = undef
    $ldap_nt_domain             = undef
    $ldap_bind_dn               = undef
    $ldap_base_dn               = undef
    $ldap_bind_password         = undef
    $ldap_username_pattern      = undef
    $ldap_user_filter           = undef
    $ldap_user_name_attr        = undef
    $ldap_group_filter          = undef
    $ldap_group_name_attr       = undef
    $ldap_group_member_attr     = undef
    $ldap_create_users_on_login = true

    $hue_ini_template           = 'cdh/hue/hue.ini.erb'
    $hue_log4j_template         = 'cdh/hue/log4j.properties.erb'
    $hue_log_conf_template      = 'cdh/hue/log.conf.erb'

    $database_host              = undef
    $database_port              = undef
    $database_user              = undef
    $database_password          = undef
    $database_name              = '/var/lib/hue/desktop.db'
    $database_engine            = 'sqlite3'
}
