node base {
  include "common"
  include "ntp"
  include "syslog::server"
}

node opencloud-monitor inherits base {
  include "syslog::server"
}

node default inherits base {

}

