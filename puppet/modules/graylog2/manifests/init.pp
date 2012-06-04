# Class: graylog2
#
# This module manages graylog2
#
# Parameters:
#   n/a
# Actions:
#   Installs and configures Graylog2 logger
# Requires:
#   n/a
#
# Sample usage:
#
#  include graylog2
#
class graylog2 {
  class { 'graylog2::config':
  }
  class { 'graylog2::package':
    require => Class['graylog2::config'],
  }
}
