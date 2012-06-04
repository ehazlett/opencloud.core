class memcached::package {
  require "memcached::config"
  if ! defined(Package["memcached"]) { package { "memcached": ensure => installed, } }

  Exec { path => "/bin:/usr/bin:/usr/local/bin", }
  
}
