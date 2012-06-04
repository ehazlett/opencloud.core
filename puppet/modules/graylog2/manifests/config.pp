class graylog2::config inherits graylog2::params {
  Exec { 
    path      => "${::path}", 
    logoutput => on_failure,
  }
}
