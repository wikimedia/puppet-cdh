# Class: cdh4::hadoop::config
#

#
# == Class cdh4::hadoop::config
#
# Installs the main Hadoop/HDFS config files.  This
# Will set Hadoop config files to run YARN (MapReduce 2).
#
# This assumes that your JBOD mount points are already
# formatted and mounted at the locations listed in $mounts.
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
#   $enable_intermediate_compression   - If true, intermediate MapReduce data will be compressed with Snappy.
#   $enable_final_compession           - If true, Final output of MapReduce jobs will be compressed with Snappy.
#   $io_file_buffer_size
#   $map_tasks_maximum
#   $reduce_tasks_maximum
#   $reduce_parallel_copies
#   $map_memory_mb
#   $mapreduce_job_reuse_jvm_num_tasks
#   $mapreduce_child_java_opts
#
# TODO:
#   - Change cluster (conf) name?  (use alternatives?)
#   - Manage each hadoop directory in mounts in puppet?
#   - Add parameters for historyserver, proxyserver, resourcemanager hostnames, etc.
#   - Set default map/reduce tasks automatically based on node stats.
class cdh4::hadoop::config(
	$namenode_hostname,
	$dfs_name_dir,
	$config_directory                  = '/etc/hadoop/conf',
	$datanode_mounts                   = undef,
	$dfs_data_path                     = 'hdfs/dn',
	$yarn_local_path                   = 'yarn/local',
	$yarn_logs_path                    = 'yarn/logs',
	$dfs_block_size                    = 67108864, # 64MB default
	$enable_jmxremote                  = true,
	$enable_webhdfs                    = true,
	$enable_intermediate_compression   = true,
	$enable_final_compession           = false,
	$io_file_buffer_size               = undef,
	$map_tasks_maximum                 = undef,
	$reduce_tasks_maximum              = undef,
	$reduce_parallel_copies            = undef,
	$map_memory_mb                     = undef,
	$mapreduce_job_reuse_jvm_num_tasks = undef,
	$mapreduce_child_java_opts         = undef,
	$use_yarn                           = true
) {

        file { "$config_directory":
                ensure => "directory"
        }

	file { "$config_directory/core-site.xml":
		content => template("cdh4/hadoop/core-site.xml.erb"),
		require => Package["hadoop-client"],
	}

	file { "$config_directory/hdfs-site.xml":
		content => template("cdh4/hadoop/hdfs-site.xml.erb"),
		require => Package["hadoop-client"],
	}
    if($use_yarn) {
        file { "$config_directory/yarn-site.xml":
            content => template("cdh4/hadoop/yarn-site.xml.erb"),
            require => Package["hadoop-client"],
        }
        file { "$config_directory/mapred-site.xml":
            content => template("cdh4/hadoop/mapred-site.xml.erb"),
            require => Package["hadoop-client"],
        }

    }
    else {
	file { "$config_directory/mapred-site.xml":
		content => template("cdh4/hadoop/mapred-site.mr1.xml.erb"),
		require => Package["hadoop-client"],
	}
    }


	file { "$config_directory/httpfs-site.xml":
		content => template("cdh4/hadoop/httpfs-site.xml.erb"),
		require => Package["hadoop-client"],
	}


	# render hadoop-env.sh and yarn-env.sh
	# for remote JMX configuration
	$namenode_jmxremote_port           = 9980
	$datanode_jmxremote_port           = 9981
	$secondary_namenode_jmxremote_port = 9982
	$resourcemanager_jmxremote_port    = 9983
	$nodemanager_jmxremote_port        = 9984
	$proxyserver_jmxremote_port        = 9985

	# If enable_remote_jmx is false, hadoop-env.sh and yarn-env.sh
	# won't have any content.  Might as well not render them.
	$env_file_ensure = $enable_jmxremote ? {
		false   => "absent",
		true    => "present"
	}

	file { "$config_directory/hadoop-env.sh":
		content => template("cdh4/hadoop/hadoop-env.sh.erb"),
		require => Package["hadoop-client"],
		ensure  => $env_file_ensure,
	}
	if($use_yarn) {
	    file { "$config_directory/yarn-env.sh":
            content => template("cdh4/hadoop/yarn-env.sh.erb"),
            require => Package["hadoop-client"],
            ensure  => $env_file_ensure,
        }
	}

}
