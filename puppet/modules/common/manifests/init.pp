class common {
  $opencloud_conf_dir = "/etc/opencloud"
  $snmp_rw_community = "opencloud"
  $snmp_sys_location = "Default Location"
  $snmp_sys_contact = "Default Contact <root@localhost>"

  Exec {
    path    => "${::path}",
  }

  if ! defined(Package["build-essential"]) { package { "build-essential": ensure => installed, } }
  if ! defined(Package["curl"]) { package { "curl": ensure => installed, } }
  if ! defined(Package["git-core"]) { package { "git-core": ensure => installed, } }
  if ! defined(Package["python-dev"]) { package { "python-dev": ensure => installed, } }
  if ! defined(Package["python-setuptools"]) { package { "python-setuptools": ensure => installed, } }
  if ! defined(Package["snmpd"]) { package { "snmpd": ensure => installed, } }
  if ! defined(Package["snmp-mibs-downloader"]) { package { "snmp-mibs-downloader": ensure => installed, } }
  if ! defined(Package["supervisor"]) { package { "supervisor": ensure => installed, } }
  if ! defined(Package["zip"]) { package { "zip": ensure => installed, } }

  service { "snmpd":
    ensure    => running,
  }
  # snmp config
  file { "common::snmp_conf":
    path    => "/etc/snmp/snmpd.conf",
    content => template("common/snmpd.conf.erb"),
    owner   => root,
    group   => root,
    require => Package["snmpd"],
    notify  => Service["snmpd"],
  }
  # puppet config
  file { "common::puppet_conf":
    path    => "/etc/puppet/puppet.conf",
    content => template("common/puppet.conf.erb"),
    owner   => root,
    group   => root,
  }

}
