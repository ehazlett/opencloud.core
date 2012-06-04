# Class: zenoss
#
# This module manages zenoss
#
# Parameters:
#   n/a
# Actions:
#   Installs Zenoss
# Requires:
#   n/a
#
# Sample usage:
#
#  include zenoss
#
class zenoss {
  class { 'zenoss::config':
  }
  class { 'zenoss::package':
    require => Class['zenoss::config'],
  }
}
