require 'puppet'

Facter.add('cdh_version') do
    setcode "/usr/bin/hadoop version | head -n 1 | awk -F '-cdh' '{print $2}'"
end

Facter.add('hadoop_version') do
    setcode "/usr/bin/hadoop version | head -n 1 | awk '{print $2}' | awk -F '-cdh' '{print $1}'"
end

Facter.add('hive_version') do
    setcode "/usr/bin/hive -e 'set system:sun.java.command;' 2> /dev/null | awk '{print $2}' | awk -F '-' '{print $3}'"
end

Facter.add('oozie_version') do
    setcode "/usr/bin/oozie admin -version | awk -F ': ' '{print $2}' | awk -F '-' '{print $1}'"
end
