# == Class cdh4::rpm_source
#
# Configures an rpm source list pointing at
# Cloudera's CDH4 rpm repository.
#
class cdh4::rpm_source($cdhversion = 4) {
	$operatingsystem_lowercase = inline_template("<%= operatingsystem.downcase %>")

	file { "/etc/yum.repos.d/cdh4.repo":
	    content => "[cloudera-cdh4] \nname=Cloudera's Distribution for Hadoop, Version ${cdhversion} \nbaseurl=http://archive.cloudera.com/cdh4/redhat/6/x86_64/cdh/${cdhversion}/ \ngpgkey = http://archive.cloudera.com/cdh4/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera \ngpgcheck = 1",
		mode    => 0444,
		ensure  => 'present',
	}

	exec { "import_cloudera_yum_key":
		command   => "sudo rpm --import http://archive.cloudera.com/cdh4/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera",
		subscribe => File["/etc/yum.repos.d/cdh4.repo"],
		refreshonly => true,
	}

	exec { "yum_check_update_for_cloudera":
		command => "/usr/bin/yum check-update",
		timeout => 240,
		refreshonly => true,
		subscribe => [File["/etc/yum.repos.d/cdh4.repo"], Exec["import_cloudera_yum_key"]],
	}
}