OpenCloud
==========
Cloud management built on open source.  OpenCloud manages the scaffolding behind the scenes in the cloud; things like configuration management, system monitoring, and reporting.  OpenCloud also helps in managing the cloud infrastructure as it grows.  One of the core principles in OpenCloud is to use completely open source software.

Getting Started
----------------
OpenCloud has only been tested on Debian/Ubuntu -- others may work but the setup scripts are for Debian/Ubuntu only.  OpenCloud consists of three core nodes (these can be all on one if required, but it must have enough ram -- 2GB min):

Puppet master
--------------
OpenCloud uses Puppet for configuration management.  This node is the master.  To install the OpenCloud Puppet master:

`$> sh setup/master.sh`

Clients
-------
For all servers that will be a part of OpenCloud, run the `node.sh` setup script.  Make sure to enter the hostname/IP of the puppet master created above:

`$> sh setup/node.sh 10.0.0.5` -- replace `10.0.0.5` with the hostname/IP of your OpenCloud Puppet master.

Once the `node.sh` setup is complete, you will need to authorize the node on the OpenCloud Puppet master.  On the master run the following:

`$> puppet cert list`

This should show the fqdn of the node.  If not, check your network settings to make sure the node can communicate with the master.

Run the following to authorize the node:

`$> puppet cert sign <fqdn>` -- replace `<fqdn>` by the hostname listed.

OpenCloud Roles
----------------
All OpenCloud server types are created using roles.  OpenCloud uses a custom Puppet Fact to query the roles for each system.  To set/add a role to a system, edit the Yaml file located in `/etc/opencloud/roles.yml`.  

For example, to add the `logging` role (in `/etc/opencloud/roles.yml`):

```yaml
- role: default
- role: logging
```

The Puppet agent will run every five minutes to check for updates.  Updated role definitions will be picked up at the same time.  To force a sync, run `sudo supervisorctl restart puppet-agent`.

Logging
--------
OpenCloud uses a fork of Graylog2 (https://github.com/ehazlett/graylog) for centralized syslogging.  Edit `/etc/opencloud/roles.yml` like the following:

```yaml
- role: default
- role: logging
```

Monitoring
-----------
OpenCloud uses Zenoss for system monitoring and reporting.  Edit `/etc/opencloud/roles.yml` like the following:

```yaml
- role: default
- role: monitor
```
