#!/usr/bin/env bash
cloud_type=$1
opscenter_version=6.5.3

if [ -z "$OPSC_VERSION" ]
then
  echo "env \$OPSC_VERSION is not set, using default: $opscenter_version"
else
  echo "env \$OPSC_VERSION is set: $OPSC_VERSION overiding default"
  opscenter_version=$OPSC_VERSION
fi

echo "Installing OpsCenter"

echo "Adding the DataStax repository"
if [[ $cloud_type == "gce" ]] || [[ $cloud_type == "gke" ]]; then
  echo "deb http://datastax%40google.com:8GdeeVT2s7zi@debian.datastax.com/enterprise stable main" | sudo tee -a /etc/apt/sources.list.d/datastax.sources.list
elif [[ $cloud_type == "azure" ]]; then
  echo "deb http://datastax%40microsoft.com:3A7vadPHbNT@debian.datastax.com/enterprise stable main" | sudo tee -a /etc/apt/sources.list.d/datastax.sources.list
elif [[ $cloud_type == "aws" ]]; then
  echo "deb http://datastax%40amazon.com:A8ePXn%5EHH0%260@debian.datastax.com/enterprise stable main" | sudo tee -a /etc/apt/sources.list.d/datastax.sources.list
elif [[ $cloud_type == "oracle" ]] || [[ $cloud_type == "bmc" ]]; then
  echo "deb http://datastax%40oracle.com:*9En9HH4j%5Ep4@debian.datastax.com/enterprise stable main" | sudo tee -a /etc/apt/sources.list.d/datastax.sources.list
else
  echo "deb http://datastax%40clouddev.com:CJ9o%21wOlDX1a@debian.datastax.com/enterprise stable main" | sudo tee -a /etc/apt/sources.list.d/datastax.sources.list
fi


#
killall -9 apt apt-get apt-key
#
rm /var/lib/dpkg/lock
#
dpkg --configure -a
#
end=300

# check for lock
echo -e "Checking if apt/dpkg running before repo-key, start: $(date +%r)"
while [ $SECONDS -lt $end ]; do
   output=`ps -A | grep -e apt -e dpkg`
   if [ -z "$output" ]
   then
     break;
   fi
done



curl -L http://debian.datastax.com/debian/repo_key | sudo apt-key add -

# check for lock 
echo -e "Checking if apt/dpkg running before update, start: $(date +%r)"
while [ $SECONDS -lt $end ]; do
   output=`ps -A | grep -e apt -e dpkg`
   if [ -z "$output" ]
   then
     break;
   fi
done

echo "before apt-get update $output"
apt-get -y update
# check for lock
echo -e "Checking if apt/dpkg running before update, start: $(date +%r)"
while [ $SECONDS -lt $end ]; do
   output=`ps -A | grep -e apt -e dpkg`
   if [ -z "$output" ]
   then
     break;
   fi
done
echo "before opsc install  $output"

apt-get -y install opscenter=$opscenter_version
