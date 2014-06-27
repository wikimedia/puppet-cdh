require 'puppet'

Facter.add('cdh_version') do
    setcode "/usr/bin/dpkg-query --show hadoop | awk -F '+' '{print $2}'"
end

Facter.add('hadoop_version') do
    setcode "/usr/bin/dpkg-query --show hadoop | awk '{print $2}' | awk -F '+' '{print $1}'"
end

Facter.add('hive_version') do
    setcode "/usr/bin/dpkg-query --show hive | awk '{print $2}' | awk -F '+' '{print $1}'"
end

Facter.add('oozie_version') do
    setcode "/usr/bin/dpkg-query --show oozie | awk '{print $2}' | awk -F '+' '{print $1}'"
end
