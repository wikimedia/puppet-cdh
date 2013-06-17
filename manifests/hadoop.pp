#
# == Class cdh4::hadoop
#
# Installs the main Hadoop/HDFS packages and config files.  This
# By default this will set Hadoop config files to run YARN (MapReduce 2).
#
# This assumes that your JBOD mount points are already
# formatted and mounted at the locations listed in $datanode_mounts.
#
# dfs.datanode.data.dir will be set to each of ${dfs_data_dir_mounts}/$data_path
# yarn.nodemanager.local-dirs will be set to each of ${dfs_data_dir_mounts}/$yarn_local_path
# yarn.nodemanager.log-dirs will be set to each of ${dfs_data_dir_mounts}/$yarn_logs_path
#
# == Parameters
#   $namenode_hostname   - hostname of the NameNode.  This will also be used as the hostname for the historyserver, proxyserver, and resourcemanager.
#   $dfs_name_dir        - full path to hadoop NameNode name directory.  This can be an array of paths or a single string path.
#   $config_directory    - path of the hadoop config directory.
#   $datanode_mounts     - array of JBOD mount points.  Hadoop datanode and mapreduce/yarn directories will be here.
#   $dfs_data_path       - path relative to JBOD mount point for HDFS data directories.
#   $enable_jmxremote    - enables remote JMX connections for all Hadoop services.  Ports are not currently configurable.  Default: true.
#   $yarn_local_path     - path relative to JBOD mount point for yarn local directories.
#   $yarn_logs_path      - path relative to JBOD mount point for yarn log directories.
#   $dfs_block_size      - HDFS block size in bytes.  Default 64MB.
#   $io_file_buffer_size
#   $map_tasks_maximum
#   $reduce_tasks_maximum
#   $mapreduce_job_reuse_jvm_num_tasks
#   $reduce_parallel_copies
#   $map_memory_mb
#   $reduce_memory_mb
#   $mapreduce_task_io_sort_mb
#   $mapreduce_task_io_sort_factor
#   $mapreduce_map_java_opts
#   $mapreduce_child_java_opts
#   $mapreduce_intermediate_compression   - If true, intermediate MapReduce data will be compressed with Snappy.    Default: true.
#   $mapreduce_final_compession           - If true, Final output of MapReduce jobs will be compressed with Snappy. Default: false.
#   $yarn_nodemanager_resource_memory_mb
#   $yarn_resourcemanager_scheduler_class - If you change this (e.g. to FairScheduler), you should also provide your own scheduler config .xml files outside of the cdh4 module.
#   $use_yarn
#   $ganglia_hosts                        - Set this to an array of ganglia host:ports if you want to enable ganglia sinks in hadoop-metrics2.properites
#
class cdh4::hadoop(
    $namenode_hostname,
    $dfs_name_dir,
    $config_directory                        = $::cdh4::hadoop::defaults::config_directory,
    $datanode_mounts                         = $::cdh4::hadoop::defaults::datanode_mounts,
    $dfs_data_path                           = $::cdh4::hadoop::defaults::dfs_data_path,
    $yarn_local_path                         = $::cdh4::hadoop::defaults::yarn_local_path,
    $yarn_logs_path                          = $::cdh4::hadoop::defaults::yarn_logs_path,
    $dfs_block_size                          = $::cdh4::hadoop::defaults::dfs_block_size,
    $enable_jmxremote                        = $::cdh4::hadoop::defaults::enable_jmxremote,
    $enable_webhdfs                          = $::cdh4::hadoop::defaults::enable_webhdfs,
    $io_file_buffer_size                     = $::cdh4::hadoop::defaults::io_file_buffer_size,
    $mapreduce_map_tasks_maximum             = $::cdh4::hadoop::defaults::mapreduce_map_tasks_maximum,
    $mapreduce_reduce_tasks_maximum          = $::cdh4::hadoop::defaults::mapreduce_reduce_tasks_maximum,
    $mapreduce_job_reuse_jvm_num_tasks       = $::cdh4::hadoop::defaults::mapreduce_job_reuse_jvm_num_tasks,
    $mapreduce_reduce_shuffle_parallelcopies = $::cdh4::hadoop::defaults::mapreduce_reduce_shuffle_parallelcopies,
    $mapreduce_map_memory_mb                 = $::cdh4::hadoop::defaults::mapreduce_map_memory_mb,
    $mapreduce_reduce_memory_mb              = $::cdh4::hadoop::defaults::mapreduce_reduce_memory_mb,
    $mapreduce_task_io_sort_mb               = $::cdh4::hadoop::defaults::mapreduce_task_io_sort_mb,
    $mapreduce_task_io_sort_factor           = $::cdh4::hadoop::defaults::mapreduce_task_io_sort_factor,
    $mapreduce_map_java_opts                 = $::cdh4::hadoop::defaults::mapreduce_map_java_opts,
    $mapreduce_reduce_java_opts              = $::cdh4::hadoop::defaults::mapreduce_reduce_java_opts,
    $mapreduce_intermediate_compression      = $::cdh4::hadoop::defaults::mapreduce_intermediate_compression,
    $mapreduce_final_compession              = $::cdh4::hadoop::defaults::mapreduce_final_compession,
    $yarn_nodemanager_resource_memory_mb     = $::cdh4::hadoop::defaults::yarn_nodemanager_resource_memory_mb,
    $yarn_resourcemanager_scheduler_class    = $::cdh4::hadoop::defaults::yarn_resourcemanager_scheduler_class,
    $use_yarn                                = $::cdh4::hadoop::defaults::use_yarn,
    $ganglia_hosts                           = $::cdh4::hadoop::defaults::ganglia_hosts
) inherits cdh4::hadoop::defaults
{
    # JMX Ports
    $namenode_jmxremote_port           = 9980
    $datanode_jmxremote_port           = 9981
    $secondary_namenode_jmxremote_port = 9982
    $resourcemanager_jmxremote_port    = 9983
    $nodemanager_jmxremote_port        = 9984
    $proxyserver_jmxremote_port        = 9985

    package { 'hadoop-client':
        ensure => 'installed'
    }

    # All config files require hadoop-client package
    File {
        require => Package['hadoop-client']
    }

    # ensure for yarn specific config files.
    $yarn_ensure = $use_yarn ? {
        false   => 'absent',
        default => 'present',
    }

    # Common hadoop config files
    file { $config_directory:
        ensure => 'directory',
    }

    file { "${config_directory}/log4j.properties":
        content => template('cdh4/hadoop/log4j.properties.erb'),
    }

    file { "${config_directory}/core-site.xml":
        content => template('cdh4/hadoop/core-site.xml.erb'),
    }

    file { "$config_directory/hdfs-site.xml":
        content => template('cdh4/hadoop/hdfs-site.xml.erb'),
    }

    file {"$config_directory/httpfs-site.xml":
        content => template('cdh4/hadoop/httpfs-site.xml.erb'),
    }

    file { "${config_directory}/hadoop-env.sh":
        content => template('cdh4/hadoop/hadoop-env.sh.erb'),
    }

    file { "${config_directory}/mapred-site.xml":
        content => template('cdh4/hadoop/mapred-site.xml.erb'),
    }

    file { "${config_directory}/yarn-site.xml":
        ensure  => $yarn_ensure,
        content => template('cdh4/hadoop/yarn-site.xml.erb'),
    }

    file { "${config_directory}/yarn-env.sh":
        ensure  => $yarn_ensure,
        content => template('cdh4/hadoop/yarn-env.sh.erb'),
    }

    # render hadoop-metrics2.properties
    # if we hav Ganglia Hosts to send metrics to.
    $hadoop_metrics2_ensure = $ganglia_hosts ? {
        undef   => 'absent',
        default => 'present',
    }
    file { "${config_directory}/hadoop-metrics2.properties":
        ensure  => $hadoop_metrics2_ensure,
        content => template('cdh4/hadoop/hadoop-metrics2.properties.erb'),
    }
}
