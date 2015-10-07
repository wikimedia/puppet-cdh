# == Class cdh::hadoop::jmxtrans::worker
# Convenience class to include jmxtrans classes for DataNode and NodeManager
class cdh::hadoop::jmxtrans::worker(
    $ganglia        = undef,
    $graphite       = undef,
    $statsd         = undef,
    $outfile        = undef,
)
{
    class { ['cdh::hadoop::jmxtrans::datanode', 'cdh::hadoop::jmxtrans::nodemanager']:
        ganglia  => $ganglia,
        graphite => $graphite,
        statsd   => $statsd,
        outfile  => $outfile,
    }
}