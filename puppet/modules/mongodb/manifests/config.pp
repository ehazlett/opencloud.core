class mongodb::config inherits mongodb::params {
  Exec { 
    path      => "${::path}", 
    logoutput => on_failure,
  }
  file { "mongodb::config::mongodb_data_dir":
    ensure    => directory,
    path      => "${mongodb::params::mongodb_data_dir}",
  }
  file { "mongodb::config::mongodb_supervisor":
    path    => "/etc/supervisor/conf.d/mongodb.conf",
    content => template("mongodb/mongodb_supervisor.conf.erb"),
    owner   => "root",
    group   => "root",
    mode    => 0644,
    require => Package["supervisor"],
    notify  => Exec["mongodb::config::update_supervisor"],
  }
  exec { "mongodb::config::update_supervisor":
    command     => "supervisorctl update",
    require     => [ File["mongodb::config::mongodb_supervisor"], File["mongodb::config::mongodb_data_dir"] ],
    refreshonly => true,
  }
}
