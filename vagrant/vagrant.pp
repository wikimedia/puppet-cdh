class vagrant::hadoop::config {
	$namenode_hostname        = "master.vagrant"
	$hadoop_base_directory    = "/var/lib/hadoop"
	$hadoop_name_directory    = "$hadoop_base_directory/name"
	$hadoop_data_directory    = "$hadoop_base_directory/data"

	$hadoop_mounts = [
		"$hadoop_data_directory/one",
	]
  
	class { "cdh4::hadoop::config":
		namenode_hostname    => $namenode_hostname,
		datanode_mounts      => $hadoop_mounts,
		dfs_name_dir         => [$hadoop_name_directory],
		dfs_block_size       => 268435456,  # 256 MB
		map_tasks_maximum    => ($processorcount - 2) / 2,
		reduce_tasks_maximum => ($processorcount - 2) / 2,
		map_memory_mb        => 1536,
		io_file_buffer_size  => 131072,
		reduce_parallel_copies => 10,
		mapreduce_job_reuse_jvm_num_tasks => -1,
		mapreduce_child_java_opts => "-Xmx512M",
	}
}
class vagrant::zookeeper::server {
	require vagrant::zookeeper::config
	include cdh4::zookeeper::server
}

class vagrant::zookeeper inherits vagrant::base {
	include vagrant::zookeeper::server
}

class vagrant::base {
	require cdh4::apt_source
	include cdh4
	include vagrant::hadoop::config
	include vagrant::zookeeper::config
}

class vagrant::zookeeper::config {
	$zookeeper_hosts = {
		"zookeeper1.vagrant" => 1,
		"zookeeper2.vagrant" => 2,
		"zookeeper3.vagrant" => 3
	}

	class { "cdh4::zookeeper::config":
		zookeeper_hosts => $zookeeper_hosts,
	}
}
