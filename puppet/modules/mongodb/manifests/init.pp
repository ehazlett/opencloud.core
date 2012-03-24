# Class: mongodb
#
# This module manages mongodb
#
# Parameters:
#   n/a
# Actions:
#   Installs and configures MongoDB
# Requires:
#   n/a
#
# Sample usage:
#
#  include mongodb
#
class mongodb {
  class { 'mongodb::config':
  }
  class { 'mongodb::package':
    require => Class['mongodb::config'],
  }
}
