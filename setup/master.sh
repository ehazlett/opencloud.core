#!/bin/sh
#
#  Sets up the OpenCloud master server
#

PUPPET_CONF_DIR=`dirname $(pwd)`/puppet

if [ "$(id -u)" != "0" ]; then echo "Error: You must be root to run setup"; exit; fi

# install dependencies
apt-get update && apt-get -y upgrade
apt-get -y install build-essential irb libmysql-ruby libmysqlclient-dev libopenssl-ruby libreadline-ruby rdoc ri ruby ruby-dev rubygems supervisor

# install facter
wget http://downloads.puppetlabs.com/facter/facter-1.6.1.tar.gz
tar zxf facter*
cd facter* ; sudo ruby install.rb
cd ../ ; rm -rf facter*

# install puppet
wget http://puppetlabs.com/downloads/puppet/puppet-latest.tgz
tar zxf puppet-latest.tgz
cd puppet* ; sudo ruby install.rb
cd ../ ; rm -rf puppet*

# create puppet group
groupadd puppet

# create puppet directories
mkdir -p /etc/puppet/ssl

# symlink config
ln -sf  $PUPPET_CONF_DIR/manifests /etc/puppet/manifests
ln -sf  $PUPPET_CONF_DIR/modules /etc/puppet/modules

# create puppet users
puppet master --mkusers --verbose
sleep 10
killall puppet

# create supervisor config for puppet master
echo "[program:puppet-master]
command=puppet master
  --verbose
  --no-daemonize
autorestart=true
user=root
directory=/etc/puppet
stopsignal=QUIT" > /etc/supervisor/conf.d/puppet-master.conf

supervisorctl update

# update hosts
sed -i 's/^127\.0\.0\.1\s+*/127\.0\.0\.1    puppet /g' /etc/hosts

echo "OpenCloud master setup complete."

