# == Class cdh::hadoop::jmxtrans::historyserver
# Sets up a jmxtrans instance for a Hadoop MapReduce History Server
# running on the current host.
# Note: This requires the jmxtrans puppet module found at
# https://github.com/wikimedia/puppet-jmxtrans.
#
# == Parameters
# $jmx_port      - Map Reduce Job History JMX port.  Default: 9986
# $ganglia       - Ganglia host:port
# $graphite      - Graphite host:port
# $statsd        - statsd host:port
# $outfile       - outfile to which Kafka stats will be written.
# $objects       - objects parameter to pass to jmxtrans::metrics.  Only use
#                  this if you need to override the default ones that this
#                  class provides.
#
# == Usage
# class { 'cdh::hadoop::jmxtrans::historyserver':
#     ganglia => 'ganglia.example.org:8649'
# }
#
class cdh::hadoop::jmxtrans::historyserver(
    $jmx_port       = $cdh::hadoop::defaults::mapreduce_history_jmxremote_port,
    $ganglia        = undef,
    $graphite       = undef,
    $statsd         = undef,
    $outfile        = undef,
    $objects        = undef,
) inherits cdh::hadoop::defaults
{
    $jmx = "${::fqdn}:${jmx_port}"
    $group_name = 'Hadoop.JobHistoryServer'

    # query for metrics from Hadoop MapReduce JobHistory's JVM
    jmxtrans::metrics::jvm { 'hadoop-mapreduce-historyserver':
        jmx          => $jmx,
        group_prefix => "${group_name}.",
        outfile      => $outfile,
        ganglia      => $ganglia,
        graphite     => $graphite,
        statsd       => $statsd,
    }


    $historyserver_objects = $objects ? {
        # if $objects was not set, then use this as the
        # default set of JMX MBean objects to query.
        undef   => [
            {
                'name'          => 'Hadoop:name=JvmMetrics,service=JobHistoryServer',
                'resultAlias'   => "${group_name}.JvmMetrics",
                'attrs'         => {
                    'GcCount'                       => { 'slope' => 'positive' },
                    'GcCountPS MarkSweep'           => { 'slope' => 'positive' },
                    'GcCountPS Scavenge'            => { 'slope' => 'positive' },
                    'GcTimeMillis'                  => { 'slope' => 'both' },
                    'GcTimeMillisPS MarkSweep'      => { 'slope' => 'both' },
                    'GcTimeMillisPS Scavenge'       => { 'slope' => 'both' },
                    'LogError'                      => { 'slope' => 'positive' },
                    'LogFatal'                      => { 'slope' => 'positive' },
                    'LogInfo'                       => { 'slope' => 'both' },
                    'LogWarn'                       => { 'slope' => 'positive' },
                    'MemHeapCommittedM'             => { 'slope' => 'both' },
                    'MemHeapUsedM'                  => { 'slope' => 'both' },
                    'MemNonHeapCommittedM'          => { 'slope' => 'both' },
                    'MemNonHeapUsedM'               => { 'slope' => 'both' },
                    'ThreadsBlocked'                => { 'slope' => 'both' },
                    'ThreadsNew'                    => { 'slope' => 'both' },
                    'ThreadsRunnable'               => { 'slope' => 'both' },
                    'ThreadsTerminated'             => { 'slope' => 'both' },
                    'ThreadsTimedWaiting'           => { 'slope' => 'both' },
                    'ThreadsWaiting'                => { 'slope' => 'both' },
                },

            },
            {
                'name' =>          'Hadoop:name=RpcDetailedActivityForPort10020,service=JobHistoryServer',
                'resultAlias'   => "${group_name}.RpcDetailedActivityForPort10020",
                'attrs'         => {
                    'GetCountersAvgTime'                    => { 'slope' => 'both' },
                    'GetCountersNumOps'                     => { 'slope' => 'both' },
                    'GetJobReportAvgTime'                   => { 'slope' => 'both' },
                    'GetJobReportNumOps'                    => { 'slope' => 'both' },
                    'GetTaskAttemptCompletionEventsAvgTime' => { 'slope' => 'both' },
                    'GetTaskAttemptCompletionEventsNumOps'  => { 'slope' => 'both' },
                    'GetTaskReportsAvgTime'                 => { 'slope' => 'both' },
                    'GetTaskReportsNumOps'                  => { 'slope' => 'both' },
                },
            },
            {
                'name' =>          'Hadoop:name=UgiMetrics,service=JobHistoryServer',
                'resultAlias'   => "${group_name}.UgiMetrics",
                'attrs'         => {
                    'GetGroupsAvgTime'    => { 'slope' => 'both' },
                    'GetGroupsNumOps'     => { 'slope' => 'both' },
                    'LoginFailureAvgTime' => { 'slope' => 'both' },
                    'LoginFailureNumOps'  => { 'slope' => 'positive' },
                    'LoginSuccessAvgTime' => { 'slope' => 'both' },
                    'LoginSuccessNumOps'  => { 'slope' => 'positive' },
                    'RenewalFailures'     => { 'slope' => 'both' },

                },
            },
        ],

        # else use $objects
        default => $objects,
    }

    # query for jmx metrics
    jmxtrans::metrics { "hadoop-mapreduce-historyserver-${::hostname}-${jmx_port}":
        jmx                  => $jmx,
        outfile              => $outfile,
        ganglia              => $ganglia,
        ganglia_group_name   => $group_name,
        graphite             => $graphite,
        graphite_root_prefix => $group_name,
        statsd               => $statsd,
        statsd_root_prefix   => $group_name,
        objects              => $historyserver_objects,
    }
}