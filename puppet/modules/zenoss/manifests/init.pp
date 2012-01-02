class zenoss {
  require "common"

  $zenoss_url = "http://downloads.sourceforge.net/zenoss/zenoss-stack_3.2.1_x64.deb"

  Exec { path => "${::path}", }

  exec { "zenoss::wget_zenoss":
    cwd       => "/tmp",
    command   => "wget ${zenoss_url} -O zenoss.deb > ${common::opencloud_conf_dir}/zenoss_wget_zenoss",
    timeout   => 1800,
    creates   => "${common::opencloud_conf_dir}/zenoss_wget_zenoss",
    notify    => Exec["zenoss::install_zenoss"],
  }
  exec { "zenoss::install_zenoss":
    cwd         => "/tmp",
    command     => "dpkg -i zenoss.deb",
    refreshonly => true,
    timeout     => 1800,
    require     => Exec["zenoss::wget_zenoss"],
  }
}
