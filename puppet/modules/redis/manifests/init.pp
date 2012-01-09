class redis {
  $redis_url = "http://redis.googlecode.com/files/redis-2.4.5.tar.gz"
  $redis_dir = "/opt/redis"
  $redis_data_dir = "/opt/redis_data"

  Exec { path => "${::path}", }

  exec { "redis::wget_redis":
    cwd       => "/tmp",
    command   => "wget ${redis_url} -O redis.tar.gz > ${common::opencloud_conf_dir}/redis_wget_redis",
    creates   => "${common::opencloud_conf_dir}/redis_wget_redis",
    notify    => Exec["redis::extract_redis"],
  }
  exec { "redis::extract_redis":
    cwd         => "/tmp",
    command     => "tar zxf redis.tar.gz ; mv redis-* /opt/ ; mv /opt/redis* ${redis_dir} ; rm -rf redis*",
    refreshonly => true,
    require     => Exec["redis::wget_redis"],
    notify      => Exec["redis::build_redis"],
  }
  exec { "redis::build_redis":
    cwd         => "${redis_dir}",
    command     => "make",
    refreshonly => true,
    require     => Exec["redis::extract_redis"],
    notify      => Exec["redis::install_redis"],
  }
  exec { "redis::install_redis":
    cwd         => "${redis_dir}",
    command     => "make install",
    refreshonly => true,
    require     => Exec["redis::build_redis"],
  }
  file { "redis::redis_data_dir":
    ensure    => directory,
    path      => "${redis_data_dir}",
    owner     => "root",
    group     => "root",
    mode      => 0770,
    require   => Exec["redis::extract_redis"],
  }
  file { "redis::redis_conf":
    path    => "/etc/redis.conf",
    content => template("redis/redis.conf.erb"),
    owner   => "root",
    group   => "root",
    mode    => 0644,
  }
  file { "redis::redis_supervisor":
    path    => "/etc/supervisor/conf.d/redis.conf",
    content => template("redis/redis_supervisor.conf.erb"),
    owner   => "root",
    group   => "root",
    mode    => 0644,
    require => Package["supervisor"],
    notify  => Exec["redis::update_supervisor"],
  }
  exec { "redis::update_supervisor":
    command     => "supervisorctl update",
    require     => File["redis::redis_supervisor"],
    refreshonly => true,
  }
}
