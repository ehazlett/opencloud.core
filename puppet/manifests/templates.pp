node base {
  include "common"
  include "ntp"
}

node 'opencloud-monitor' inherits base {
  include "syslog::server"
}

node default inherits base {

}

