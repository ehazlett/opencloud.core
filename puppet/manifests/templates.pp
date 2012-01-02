node base {
  include "common"
  include "ntp"
  include "syslog::client"
}

node 'opencloud-logging' inherits base {
  include "syslog::server"
}

node 'opencloud-monitor' inherits base {
  include "zenoss"
}

node default inherits base {
}

