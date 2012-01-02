node base {
  include "common"
  include "ntp"
  include "syslog::client"
}

node default inherits base {
  if 'logging' in $roles {
    include "syslog::server"
  }
  if 'monitor' in $roles {
    include "zenoss"
  }
    
}

