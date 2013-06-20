# == Class cdh4::hue
#
# Installs hue, sets up the hue.ini file
# and ensures that hue server is running.
# This requires that cdh4::hadoop is included.
#
# If cdh4::hive and/or cdh4::oozie are included
# on this node, hue will be configured to interface
# with hive and oozie.
#
# == Parameters
# $http_host              - IP for webservice to bind.
# $http_port              - Port for webservice to bind.
# $secret_key             - Secret key used for session hashing.
#
# $oozie_url              - URL for Oozie API.  If cdh4::oozie is included,
#                           this will be inferred.  Else this will be disabled.
# $oozie_security_enabled - Default: false.
#
# $smtp_host              - SMTP host for email notifications.
#                           Default: undef, SMTP will not be configured.
# $smtp_port              - SMTP port.                             Default: 25
# $smtp_from_email        - Sender email address of notifications. Default: undef
# $smtp_username          - Username for SMTP authentication.      Default: undef
# $smtp_password          - Password for SMTP authentication.      Default: undef
#
# $httpfs_enabled         - If true, Hue will be configured to interact with HDFS via
#                           HttpFS rather than the default WebHDFS.  You must
#                           manually configure HttpFS on your namenode.
#
# $ssl_certificate        - Path to SSL certificate.  Default: /etc/ssl/certs/ssl-cert-snakeoil.pem
# $ssl_private_key        - Path to SSL private key.  Default: /etc/ssl/private/ssl-cert-snakeoil.key
#                           If ssl_certificate and ssl_private_key are set to the defaults,
#                           the snakeoil certificates will be generated automatically for you.
#
# === LDAP parameters:
# See hue.ini comments for documentation.  By default these are undefined.
#
# $ldap_url
# $ldap_cert
# $ldap_nt_domain
# $ldap_bind_dn
# $ldap_base_dn
# $ldap_bind_password
# $ldap_username_pattern
# $ldap_user_filter
# $ldap_user_name_attr
# $ldap_group_filter
# $ldap_group_name_attr
# $ldap_group_member_attr
#
class cdh4::hue(
    $http_host                = $cdh4::hue::defaults::http_host,
    $http_port                = $cdh4::hue::defaults::http_port,
    $secret_key               = $cdh4::hue::defaults::secret_key,

    $oozie_url                = $cdh4::hue::defaults::oozie_url,
    $oozie_security_enabled   = $cdh4::hue::defaults::oozie_security_enabled,

    $smtp_host                = $cdh4::hue::defaults::smtp_host,
    $smtp_port                = $cdh4::hue::defaults::smtp_port,
    $smtp_user                = $cdh4::hue::defaults::smtp_user,
    $smtp_password            = $cdh4::hue::defaults::smtp_password,
    $smtp_from_email          = $cdh4::hue::defaults::smtp_from_email,

    $httpfs_enabled           = $cdh4::hue::defaults::httpfs_enabled,

    $ssl_certificate          = $cdh4::hue::defaults::ssl_certificate,
    $ssl_private_key          = $cdh4::hue::defaults::ssl_private_key,

    $ldap_url                 = $cdh4::hue::defaults::ldap_url,
    $ldap_cert                = $cdh4::hue::defaults::ldap_cert,
    $ldap_nt_domain           = $cdh4::hue::defaults::ldap_nt_domain,
    $ldap_bind_dn             = $cdh4::hue::defaults::ldap_bind_dn,
    $ldap_base_dn             = $cdh4::hue::defaults::ldap_base_dn,
    $ldap_bind_password       = $cdh4::hue::defaults::ldap_bind_password,
    $ldap_username_pattern    = $cdh4::hue::defaults::ldap_username_pattern,
    $ldap_user_filter         = $cdh4::hue::defaults::ldap_user_filter,
    $ldap_user_name_attr      = $cdh4::hue::defaults::ldap_user_name_attr,
    $ldap_group_filter        = $cdh4::hue::defaults::ldap_group_filter,
    $ldap_group_name_attr     = $cdh4::hue::defaults::ldap_group_name_attr,
    $ldap_group_member_attr   = $cdh4::hue::defaults::ldap_group_member_attr,

    $hue_ini_template       = $cdh4::hue::defaults::hue_ini_template
) inherits cdh4::hue::defaults
{
    Class['cdh4::hadoop'] -> Class['cdh4::hue']

    package { ['hue', 'hue-server']:
        ensure => 'installed'
    }

    # Managing the hue user here so we can add
    # it to the hive group if hive-site.xml is
    # not world readable.
    user { 'hue':
        gid        => 'hue',
        comment    => 'Hue daemon',
        home       => '/usr/share/hue',
        shell      => '/bin/false',
        managehome => false,
        system     => true,
        require    => [Package['hue'], Package['hue-server']],
    }
    # hive-site.xml might not be world readable.
    if (defined(Class['cdh4::hive'])) {
        # make sure cdh4::hive is applied before cdh4::hue.
        Class['cdh4::hive']  -> Class['cdh4::hue']
        # Add the hue user to the hive group.
        User['hue'] { groups +> 'hive'}

        # Growl.  The packaged hue init.d script
        # has a bug where it doesn't --chuid to hue.
        # this causes hue not to be able to read the
        # hive-site.xml file here, even though it is
        # in the hive group.  Install our own patched
        # init.d instead.  This will be removed once
        # Cloudera fixes the problem.
        # See: https://issues.cloudera.org/browse/HUE-1398
        file { '/etc/init.d/hue':
            source  => 'puppet:///modules/cdh4/hue/hue.init.d.sh',
            mode    => '0755',
            owner   => 'root',
            group   => 'root',
            require => Package['hue'],
            notify  => Service['hue'],
        }
    }

    if ($ssl_certificate and $ssl_private_key) {
        if (!defined(Package['python-openssl'])) {
            package{ 'python-openssl':
                ensure => 'installed',
            }
        }

        # If the ssl settings are left at the defaults (snakeoil),
        # then run make-ssl-cert to generate the default snakeoil cert.
        if (($ssl_certificate == $cdh4::hue::defaults::ssl_certificate) and
            ($ssl_private_key == $cdh4::hue::defaults::ssl_private_key)) {

            if (!defined(Package['ssl-cert'])) {
                package{ 'ssl-cert':
                    ensure => 'installed',
                }
            }

            exec { 'generate_hue_snakeoil_ssl_cert':
                command => '/usr/sbin/make-ssl-cert generate-default-snakeoil',
                creates => $ssl_certificate,
                require => Package['ssl-cert'],
            }

            # generate the cert before hue is started.
            Exec['generate_hue_snakeoil_ssl_cert'] -> Service['hue']
        }
    }

    $namenode_hostname = $cdh4::hadoop::namenode_hostname
    file { '/etc/hue/hue.ini':
        content => template($hue_ini_template),
        require => Package['hue-server'],
    }

    service { 'hue':
        ensure     => 'running',
        enable     => true,
        hasrestart => true,
        hasstatus  => true,
        subscribe  => File['/etc/hue/hue.ini'],
        require    => [Package['hue-server'], User['hue']],
    }
}
