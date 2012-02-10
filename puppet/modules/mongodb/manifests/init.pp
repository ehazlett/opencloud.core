class mongodb {
  $mongodb_url = "http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.0.2.tgz"
  $mongodb_dir = "/opt/mongodb"
  $mongodb_data_dir = "/opt/mongodb_data"

  Exec { path => "${::path}", }

  exec { "mongodb::wget_mongodb":
    cwd       => "/tmp",
    command   => "wget ${mongodb_url} -O mongodb.tar.gz > ${common::opencloud_conf_dir}/mongodb_wget_redis",
    creates   => "${common::opencloud_conf_dir}/mongodb_wget_redis",
    notify    => Exec["mongodb::extract_mongodb"],
  }
  exec { "mongodb::extract_mongodb":
    cwd         => "/tmp",
    command     => "tar zxf mongodb.tar.gz ; mv mongodb-* /opt/ ; mv /opt/mongodb* ${mongodb_dir} ; rm -rf mongodb*",
    refreshonly => true,
    require     => Exec["mongodb::wget_mongodb"],
  }
  file { "mongodb::mongodb_data_dir":
    ensure    => directory,
    path      => "${mongodb_data_dir}",
  }
  file { "mongodb::mongodb_supervisor":
    path    => "/etc/supervisor/conf.d/mongodb.conf",
    content => template("mongodb/mongodb_supervisor.conf.erb"),
    owner   => "root",
    group   => "root",
    mode    => 0644,
    require => Package["supervisor"],
    notify  => Exec["mongodb::update_supervisor"],
  }
  exec { "mongodb::update_supervisor":
    command     => "supervisorctl update",
    require     => [ File["mongodb::mongodb_supervisor"], File["mongodb::mongodb_data_dir"] ],
    refreshonly => true,
  }
}
