#!/bin/bash
mkdir -p /etc/puppet/
echo '[main]' > /etc/puppet/puppet.conf
echo 'pluginsync = true' >> /etc/puppet/puppet.conf
echo '127.0.0.1 localhost' > /etc/hosts
echo '33.33.66.1 puppet' >> /etc/hosts
echo '33.33.66.100 master.vagrant' >> /etc/hosts
echo '33.33.66.101 slave1.vagrant' >> /etc/hosts
echo '33.33.66.102 slave2.vagrant' >> /etc/hosts
echo '33.33.66.103 slave3.vagrant' >> /etc/hosts
echo '33.33.66.111 zookeeper1.vagrant' >> /etc/hosts
echo '33.33.66.112 zookeeper2.vagrant' >> /etc/hosts
echo '33.33.66.113 zookeeper3.vagrant' >> /etc/hosts
mkdir -p /data0/mapred/local
mkdir -p /data0/hdfs/data/
