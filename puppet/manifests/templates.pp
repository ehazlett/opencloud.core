node base {
  include "common"
  include "ntp"
  include "syslog::client"
}

node 'opencloud-monitor' inherits base {
  include "syslog::server"
}

node default inherits base {
}

