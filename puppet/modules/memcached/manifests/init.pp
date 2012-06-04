# Class: memcached
#
# This module manages memcached
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class memcached {
  class { 'memcached::config': }
  class { 'memcached::package': 
    require => Class['memcached::config'],
  }
  class { 'memcached::service':
    require => Class['memcached::package'],
  }
}
