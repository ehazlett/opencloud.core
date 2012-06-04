# Class: redis
#
# This module manages redis
#
# Parameters:
#   n/a
# Actions:
#   Installs and configures Redis
# Requires:
#   n/a
# Sample usage:
#
#   include redis
#
class redis {
  $redis_url = "http://redis.googlecode.com/files/redis-2.4.5.tar.gz"
  $redis_dir = "/opt/redis"
  $redis_data_dir = "/opt/redis_data"

  Exec { path => "${::path}", }

  exec { "redis::wget_redis":
    cwd       => "/tmp",
    command   => "wget ${redis_url} -O redis.tar.gz",
    creates   => "/usr/local/bin/redis-server",
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
}
