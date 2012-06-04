class memcached::service {
  service { "memcached":
    ensure      => running,
    enable      => true,
    hasstatus   => true,
    hasrestart  => true,
  }
}