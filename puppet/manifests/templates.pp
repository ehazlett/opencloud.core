node base {
  include "common"
  include "ntp"
  include "syslog::client"
}

node default inherits base {
  if $roles {
    if 'dashboard' in $roles {
      include "redis"
    }
    if 'logger' in $roles {
      include "syslog::server"
    }
    if 'webserver:nginx' in $roles {
      include "nginx"
    }
    if 'redis' in $roles {
      include "redis"
    }
    if 'mongodb' in $roles {
      include "mongodb"
    }
  }
}

