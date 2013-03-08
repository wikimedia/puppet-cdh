# == Class cdh4::zookeeper::server
# Ensures that the Zookeeper logs are cleaned up. It will keep the last 4 logs.
class cdh4::zookeeper::cron inherits cdh4::zookeeper::config {

    cron { 'zookeeper-log-cleanup':
        command => "/usr/lib/zookeeper/bin/zkCleanup.sh $cdh4::zookeeper::config::data_dir $cdh4::zookeeper::config::data_dir 4 > /dev/null",
        user    => root,
        hour    => 2,
        minute  => fqdn_rand( 60 ),
    }

}