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
    "ntp",
    "python-dev",
    "python-setuptools",
    "snmpd",
    "supervisor",
    "zip",
  ]: }

  Exec {
    path    => "${::path}",
  }
}
