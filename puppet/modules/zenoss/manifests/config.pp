class zenoss::config inherits zenoss::params {
  Exec { 
    path      => "${::path}", 
    logoutput => on_failure,
  }
}
