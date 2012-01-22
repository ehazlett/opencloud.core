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
apt-get update
apt-get -y install build-essential irb libopenssl-ruby libreadline-ruby rdoc ri ruby ruby-dev rubygems supervisor

# install facter
echo "Installing facter"
wget http://downloads.puppetlabs.com/facter/facter-1.6.1.tar.gz
tar zxf facter*
cd facter* ; ruby install.rb --no-tests --no-rdoc --quick
cd ../ ; rm -rf facter*

# install puppet
echo "Installing puppet"
wget http://puppetlabs.com/downloads/puppet/puppet-latest.tgz
tar zxf puppet-latest.tgz
cd puppet* ; ruby install.rb --no-tests --no-rdoc --quick &
cd ../ ; rm -rf puppet*

# create puppet group
echo "Adding puppet group"
groupadd puppet

# create supervisor config for puppet master
echo "Creating puppet-agent supervisor config"
echo "[program:puppet-agent]
command=/usr/bin/puppet agent
  --verbose
  --no-daemonize
user=root
stopsignal=QUIT" > /etc/supervisor/conf.d/puppet-agent.conf

# create initial puppet config
echo "Creating puppet.conf"
echo "[main]
  pluginsync = true

[master]
  allow_duplicate_certs = True
  node_name = facter

[agent]
  node_name_fact = fqdn
  runinterval = 300" > /etc/puppet/puppet.conf


# setup puppet host
echo "Updating /etc/hosts"
PUPPET_HOST=`grep puppet /etc/hosts`
if [ -n "$PUPPET_HOST" ]; then
  echo "Warning: Puppet host previously setup.  Remove the entry from /etc/hosts for setup to configure."
else
  echo "$1    puppet" >> /etc/hosts
fi

echo "Creating default roles.yml"
mkdir -p /etc/opencloud
echo "- role: default" > /etc/opencloud/roles.yml

supervisorctl update

echo "OpenCloud node setup complete."

exit 0
