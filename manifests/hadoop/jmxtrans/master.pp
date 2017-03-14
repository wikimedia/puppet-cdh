# == Class cdh::hadoop::jmxtrans::master
# Convenience class to include jmxtrans classes for NameNode and ResourceManager
class cdh::hadoop::jmxtrans::master(
    $ganglia        = undef,
    $graphite       = undef,
    $statsd         = undef,
    $outfile        = undef,
)
{
    class { ['cdh::hadoop::jmxtrans::namenode',
          'cdh::hadoop::jmxtrans::resourcemanager',
          'cdh::hadoop::jmxtrans::historyserver']:
        ganglia  => $ganglia,
        graphite => $graphite,
        outfile  => $outfile,
        statsd   => $statsd,
    }
}