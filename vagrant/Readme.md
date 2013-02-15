# Vagrant setup for puppet-cdh4

## The Java module
You need to add files generate by https://github.com/flexiondotorg/oab-java6 to the vagrant/modules/java/files/root/java/ folder, it should look like 
```
ia32-sun-java6-bin_6.38-1~precise1_amd64.deb  sun-java6-bin_6.38-1~precise1_amd64.deb
Packages                                      sun-java6-fonts_6.38-1~precise1_all.deb
Packages.gz                                   sun-java6-javadb_6.38-1~precise1_all.deb
pubkey.asc                                    sun-java6-jdk_6.38-1~precise1_amd64.deb
Release                                       sun-java6-jre_6.38-1~precise1_all.deb
Release.gpg                                   sun-java6-plugin_6.38-1~precise1_amd64.deb
sun-java6_6.38-1~precise1_amd64.changes       sun-java6-source_6.38-1~precise1_all.deb
```

## Using 
Check the Vagrantfile and the vagrant getting started guide http://docs.vagrantup.com/v1/docs/getting-started/index.html if you have not used vagrant.

##In short
To build the machines specified in the Vagrantfile, using nodes.pp and vagrant.pp from the /vagrant folder to configure them
```
# vagrant up
```
To rerun puppet on the existing machines

``` 
# vagrant provision
```
To ssh into a machine.

```
# vagrant ssh <MACHINENAME>
```

**The idea is to get all of the config to happen in a single run from vagrant up**