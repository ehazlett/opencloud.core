class memcached::config inherits memcached::params {
  file { "memcached::config::memcached_conf":
    path    => "/etc/memcached.conf",
    owner   => root,
    group   => root,
    mode    => 0644,
    content => template("memcached/memcached.conf.erb"),
  }
}
