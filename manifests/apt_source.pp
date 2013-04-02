# == Class cdh4::apt_source
#
# Configures an apt source list pointing at
# Cloudera's CDH4 apt repository.
#
class cdh4::apt_source($cdhversion = 4) {
	$operatingsystem_lowercase = inline_template("<%= operatingsystem.downcase %>")

	file { "/etc/apt/sources.list.d/cdh4.list":
		content => "deb [arch=${architecture}] http://archive.cloudera.com/cdh4/${operatingsystem_lowercase}/${lsbdistcodename}/${architecture}/cdh ${lsbdistcodename}-cdh${cdhversion} contrib\ndeb-src http://archive.cloudera.com/cdh4/${operatingsystem_lowercase}/${lsbdistcodename}/${architecture}/cdh ${lsbdistcodename}-cdh${cdhversion} contrib\n",
		mode    => 0444,
		ensure  => 'present',
	}

	exec { "import_cloudera_apt_key":
		command   => "/usr/bin/curl -s http://archive.cloudera.com/cdh4/${operatingsystem_lowercase}/${lsbdistcodename}/${architecture}/cdh/archive.key | /usr/bin/apt-key add -",
		subscribe => File["/etc/apt/sources.list.d/cdh4.list"],
		unless    => "/usr/bin/apt-key list | /bin/grep -q Cloudera",
	}

	exec { "apt_get_update_for_cloudera":
		command => "/usr/bin/apt-get update",
		timeout => 240,
		returns => [ 0, 100 ],
		refreshonly => true,
		subscribe => [File["/etc/apt/sources.list.d/cdh4.list"], Exec["import_cloudera_apt_key"]],
	}
}