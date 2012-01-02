class common {
  $opencloud_conf_dir = "/etc/opencloud"
  $snmp_rw_community = "opencloud"
  $snmp_sys_location = "Default Location"
  $snmp_sys_contact = "Default Contact <root@localhost>"

  define base_packages() {
    package { "${name}":
      ensure  => installed,
    }
  }

  base_packages{[
    "build-essential",
    "curl",
    "git-core",
    "python-dev",
    "python-setuptools",
    "snmpd",
    "snmp-mibs-downloader",
    "supervisor",
    "zip",
  ]: }

  Exec {
    path    => "${::path}",
  }

  service { "snmpd":
    ensure    => running,
  }

  file { "common::opencloud_conf_dir":
    ensure  => directory,
    path    => "${common::opencloud_conf_dir}",
    owner   => root,
    group   => root,
  }

  file { "common::snmp_conf":
    path    => "/etc/snmp/snmpd.conf",
    content => template("common/snmpd.conf.erb"),
    owner   => root,
    group   => root,
    require => Package["snmpd"],
    notify  => Service["snmpd"],
  }

}
