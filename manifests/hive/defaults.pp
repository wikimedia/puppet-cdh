# == Class hive::defaults
# Default Hive configs
#
class cdh::hive::defaults {
    $zookeeper_hosts             = undef
    # if $zookeeper_hosts is set, assume concurrency
    # locking support is also wanted.
    $support_concurrency         = $zookeeper_hosts ? {
        undef   => false,
        default => true,
    }

    $jdbc_driver                 = 'com.mysql.jdbc.Driver'
    $jdbc_protocol               = 'mysql'
    $jdbc_database               = 'hive_metastore'
    $jdbc_host                   = 'localhost'
    $jdbc_port                   = 3306
    $jdbc_username               = 'hive'
    $jdbc_password               = 'hive'

    $db_root_username            = undef
    $db_root_password            = undef

    $variable_substitute_depth   = undef

    # Further path/jar to add to hive's classpath.
    # Until Hive 0.12.0 this can only be a single path. See HIVE-2269.
    $auxpath                     = undef

    $parquet_compression         = undef

    $exec_parallel_thread_number = 8  # set this to 0 to disable hive.exec.parallel
    $optimize_skewjoin           = false
    $skewjoin_key                = 10000
    $skewjoin_mapjoin_map_tasks  = 10000
    $skewjoin_mapjoin_min_split  = 33554432

    $stats_enabled               = false
    $stats_dbclass               = 'jdbc:derby'
    $stats_jdbcdriver            = 'org.apache.derby.jdbc.EmbeddedDriver'
    $stats_dbconnectionstring    = 'jdbc:derby:;databaseName=TempStatsStore;create=true'

    # Default puppet paths to template config files.
    # This allows us to use custom template config files
    # if we want to override more settings than this
    # module yet supports.
    $hive_site_template          = 'cdh/hive/hive-site.xml.erb'
    $hive_log4j_template         = 'cdh/hive/hive-log4j.properties.erb'
    $hive_exec_log4j_template    = 'cdh/hive/hive-exec-log4j.properties.erb'
    $hive_env_template           = 'cdh/hive/hive-env.sh.erb'

    $java_home                   = undef

    # Jmx ports
    $hive_server_jmx_port        = 9978
    $hive_metastore_jmx_port     = 9979
    $hive_metastore_opts         = '-Xmx2048m'
    $hive_server_opts            = '-Xmx2048m'

    $hive_server_udf_blacklist   = undef
}