class syslog::client {
  require "common"

  $sys_logger = "172.16.0.11:514"
  
  service { "rsyslog":
    ensure  => running,
  }
  file { "/etc/rsyslog.d/50-default.conf":
    ensure  => present,
    content => template("syslog/rsyslog-50-default.conf.erb"),
    notify  => Service["rsyslog"],
  }
}
