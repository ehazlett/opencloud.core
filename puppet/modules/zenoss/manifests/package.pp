class zenoss::package {
  require "zenoss::config"

  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }

  exec { "zenoss::package::wget_zenoss":
    cwd       => "/tmp",
    command   => "wget ${zenoss::params::zenoss_url} -O zenoss.deb",
    creates   => "/usr/local/zenoss",
    timeout   => 1800,
    notify    => Exec["zenoss::package::install_zenoss"],
  }
  exec { "zenoss::package::install_zenoss":
    cwd         => "/tmp",
    command     => "dpkg -i zenoss.deb ; rm -rf zenoss.deb",
    refreshonly => true,
    timeout     => 1800,
    require     => Exec["zenoss::package::wget_zenoss"],
  }
}
