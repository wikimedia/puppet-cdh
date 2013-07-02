node /slave\d+/ {
  require java
  include hadoop::datanode
  include hadoop::tasktracker
  include hbase::regionserver
}

node master {
  require java
  include hadoop::namenode
  include hadoop::jobtracker
  include hbase::master
}

node hiveserver {
  require java
  include hive::server
}

node /zookeeper\d+/ {
  require java
  include vagrant::zookeeper
}
