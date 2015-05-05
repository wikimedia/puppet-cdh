# == Class cdh::hadoop::master
# Wrapper class for Hadoop master node services:
# - NameNode
# - ResourceManager and HistoryServer (YARN)
#
# This requires that you run your primary NameNode and
# primary ResourceManager on the same host.  Standby services
# can be spread on any nodes.
#
class cdh::hadoop::master {
    Class['cdh::hadoop'] -> Class['cdh::hadoop::master']

    include cdh::hadoop::namenode::primary

    include cdh::hadoop::resourcemanager
    include cdh::hadoop::historyserver
}
