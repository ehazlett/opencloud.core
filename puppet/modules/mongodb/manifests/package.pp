class mongodb::package {
  require "mongodb::config"

  Exec { 
    path      => "${::path}", 
    logoutput => on_failure,
  }

  exec { "mongodb::package::wget_mongodb":
    cwd       => "/tmp",
    command   => "wget ${mongodb::params::mongodb_url} -O mongodb.tar.gz",
    creates   => "${mongodb::params::mongodb_dir}/bin/mongod",
    notify    => Exec["mongodb::package::extract_mongodb"],
  }
  exec { "mongodb::package::extract_mongodb":
    cwd         => "/tmp",
    command     => "tar zxf mongodb.tar.gz ; mv mongodb-* /opt/ ; mv /opt/mongodb-* ${mongodb::params::mongodb_dir} ; rm -rf mongodb*",
    logoutput   => true,
    refreshonly => true,
    require     => Exec["mongodb::package::wget_mongodb"],
  }
}
