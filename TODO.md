# TODO:

## Hadoop

- Add hosts.exclude support for decommissioning nodes.
- Change cluster (conf) name?  (use update-alternatives?)
- Set default map/reduce tasks automatically based on facter node stats.
- Handle ensure => absent, especially for MRv1 vs YARN packages and services.
- Implement standalone yarn proxyserver support.
- Make log4j.properties more configurable.
- Support Secondary NameNode.
- Support High Availability NameNode.
- Make JMX ports configurable.
- Make hadoop-metrics2.properties more configurable.

## Oozie

## HBase

## Zookeeper

Won't implement. A Zookeeper package is available upstream in Debian/Ubuntu.
Puppetization for this package can be found at
https://github.com/wikimedia/operations-puppet-zookeeper
