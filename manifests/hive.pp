# == Class cdh4::hive
#
# Installs Hive packages (needed for Hive Client).
# Use cdh4::hive::server to install and set up a Hive server.
#
class cdh4::hive {
    package { 'hive':
        ensure => 'installed',
    }
}