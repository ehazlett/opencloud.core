#!/bin/bash
#
#  Sets up the OpenCloud node
#

SETUP_DIR=`dirname $(pwd)`/setup

function show_help {
  echo "Usage: $0 <puppet_host>"
  exit
}

if [ "$(id -u)" != "0" ]; then echo "Error: You must be root to run setup"; exit; fi

if [ -z $1 ] ; then show_help ; fi

# install dependencies
apt-get update && apt-get -y upgrade
apt-get -y install build-essential irb libopenssl-ruby libreadline-ruby rdoc ri ruby ruby-dev rubygems supervisor

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

# create supervisor config for puppet master
echo "[program:puppet-agent]
command=/usr/bin/puppet agent
  --verbose
  --no-daemonize
user=root
stopsignal=QUIT" > /etc/supervisor/conf.d/puppet-agent.conf

# create initial puppet config
echo "[main]
  pluginsync = true

[master]
  allow_duplicate_certs = True
  node_name = facter

[agent]
  node_name_fact = fqdn
  runinterval = 300" > /etc/puppet/puppet.conf


# setup puppet host
PUPPET_HOST=`grep puppet /etc/hosts`
if [ -n "$PUPPET_HOST" ]; then
  echo "Warning: Puppet host previously setup.  Remove the entry from /etc/hosts for setup to configure."
else
  echo "$1    puppet" >> /etc/hosts
fi

mkdir -p /etc/opencloud
echo "- role: default" > /etc/opencloud/roles.yml

supervisorctl update

echo "OpenCloud node setup complete."

reboot

