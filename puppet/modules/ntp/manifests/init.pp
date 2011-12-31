class ntp {
  package { "ntp":
    name    => "ntp",
    ensure  => installed,
  }
  file { "ntp_conf":
    path    => "/etc/ntp.conf",
    require => Package["ntp"],
  }
  service { "ntp":
    ensure    => running,
    subscribe => File["ntp_conf"],
  }
}
