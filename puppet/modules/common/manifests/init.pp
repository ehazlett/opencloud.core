class common {
  $opencloud_conf_dir = "/etc/opencloud"

  define base_packages() {
    package { "${name}":
      ensure  => installed,
    }
  }

  base_packages{[
    "build-essential",
    "curl",
    "git-core",
    "nagios-nrpe-server",
    "python-dev",
    "python-setuptools",
    "snmpd",
    "supervisor",
    "zip",
  ]: }

  Exec {
    path    => "${::path}",
  }

  file { "common::opencloud_conf_dir":
    ensure  => directory,
    path    => "${common::opencloud_conf_dir}",
    owner   => root,
    group   => root,
  }

}
