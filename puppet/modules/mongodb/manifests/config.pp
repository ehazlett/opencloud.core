class mongodb::config inherits mongodb::params {
  Exec { 
    path      => "${::path}", 
    logoutput => on_failure,
  }
}
