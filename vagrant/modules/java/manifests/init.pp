class java {
  File["/etc/apt/sources.list.d/java-local.list"] ~> Exec['refresh-apt']
  File["/root/java"] ~> Exec["get gpg key"] ~> Exec['refresh-apt'] ~> Package["sun-java6-jdk"]
  
  File { 
    owner => "root", 
    group => "root",
    mode => 0440,
  }
  
  file { "/etc/apt/sources.list.d/java-local.list":
    source => "puppet:///modules/java/etc/apt/sources.list.d/java-local.list", 
  }
  
  exec { "get gpg key":
    command => "/usr/bin/apt-key add /root/java/pubkey.asc",
    refreshonly => true,
  }
  
  exec { "refresh-apt":
    command => "/usr/bin/apt-get update",
    refreshonly => true,
  }
  
  package { "sun-java6-jdk":
    ensure  => "latest",
  }

  file { "/root/java":
    source => "puppet:///modules/java/root/java",
    ensure => directory,
    recurse => true,
  }
}
