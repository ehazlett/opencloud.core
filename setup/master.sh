#!/bin/sh
#
#  Sets up the OpenCloud master server
#

SETUP_DIR=`dirname $(pwd)`/setup
PUPPET_CONF_DIR=`dirname $(pwd)`/puppet
HOSTNAME=`hostname -s`
DOMAIN=`hostname -d`
HOSTNAME_FQDN=`hostname -f`

if [ "$(id -u)" != "0" ]; then echo "Error: You must be root to run setup"; exit; fi

# install dependencies
apt-get update && apt-get -y upgrade
apt-get -y install build-essential irb libmysql-ruby libmysqlclient-dev libopenssl-ruby libreadline-ruby psmisc rdoc ri ruby ruby-dev rubygems supervisor

cd /tmp
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

cd $SETUP_DIR

# symlink config
if [ -e /etc/puppet/manifests ]; then echo "Warning: Renaming existing manifests directory to /etc/puppet/manifests.old" ; mv /etc/puppet/manifests /etc/puppet/manifests.old; fi
if [ -e /etc/puppet/modules ]; then echo "Warning: Renaming existing modules directory to /etc/puppet/modules.old" ; mv /etc/puppet/modules /etc/puppet/modules.old; fi
ln -sf $PUPPET_CONF_DIR/manifests/ /etc/puppet/manifests
ln -sf $PUPPET_CONF_DIR/modules/ /etc/puppet/modules

# create initial puppet config
echo "[main]
  pluginsync = true

[master]
  allow_duplicate_certs = True
  node_name = facter
  certname = puppet

[agent]
  node_name_fact = fqdn
  runinterval = 300" > /etc/puppet/puppet.conf

# create cert
puppet cert generate puppet --dns_alt_names=puppet.$DOMAIN,$HOSTNAME,$HOSTNAME_FQDN

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

