class syslog::server {
  require "common"

  $server_name = "opencloud-monitor.lumentica.com"
  $graylog_dir = "/opt/opencloud_syslog"
  $graylog_server_dir = "/opt/opencloud_syslog_server"
  $graylog_server_url = "https://github.com/downloads/Graylog2/graylog2-server/graylog2-server-0.9.6.tar.gz"
  $mongodb_url = "http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.0.2.tgz"
  $elasticsearch_url = "https://github.com/downloads/elasticsearch/elasticsearch/elasticsearch-0.18.6.tar.gz"

  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }
  
  define syslog::base_packages() {
    package { "${name}":
      ensure  => installed,
      require => Class["common"],
    }
  }

  syslog::base_packages{[
    "autoconf",
    "irb",
    "libopenssl-ruby",
    "libreadline-ruby",
    "openjdk-6-jre",
    "rake",
    "rdoc",
    "ri",
    "ruby",
    "ruby-dev",
  ]: }
  
  exec { "syslog::get_updated_rubygems":
    command => "wget http://production.cf.rubygems.org/rubygems/rubygems-1.3.7.tgz && tar zxf rubygems* && cd rubygems* && ruby setup.rb && cd ../ && rm -rf rubygems* > ${common::opencloud_conf_dir}/rubygems.installed",
    creates => "${common::opencloud_conf_dir}/rubygems.installed",
    require => File["${common::opencloud_conf_dir}"],
    notify  => Exec["syslog::update_alternate_rubygems"],
  }

  exec { "syslog::update_alternate_rubygems":
    command     => "update-alternatives --install /usr/bin/gem gem /usr/bin/gem1.8 1",
    require     => Exec["syslog::get_updated_rubygems"],
    refreshonly => true,
  }

  exec { "syslog::update_supervisor":
    command     => "supervisorctl update",
    refreshonly => true,
  }

  exec { "syslog::wget_elasticsearch":
    cwd       => "/tmp",
    command   => "wget ${elasticsearch_url} -O elasticsearch.tar.gz > ${common::opencloud_conf_dir}/syslog_wget_elasticsearch",
    creates   => "${common::opencloud_conf_dir}/syslog_wget_elasticsearch",
    notify    => Exec["syslog::extract_elasticsearch"],
  }
  exec { "syslog::extract_elasticsearch":
    cwd         => "/tmp",
    command     => "tar zxf elasticsearch.tar.gz ; mv elasticsearch-* /opt/ ; mv /opt/elasticsearch* /opt/elasticsearch ; rm -rf elasticsearch*",
    refreshonly => true,
    require     => Exec["syslog::wget_elasticsearch"],
  }
  file { "syslog::elasticsearch_data":
    ensure  => directory,
    path    => "/opt/elasticsearch/data",
    require => Exec["syslog::extract_elasticsearch"],
  }

  file { "syslog::elasticsearch_logs":
    ensure  => directory,
    path    => "/opt/elasticsearch/logs",
    require => Exec["syslog::extract_elasticsearch"],
  }
  file { "/etc/supervisor/conf.d/elasticsearch.conf":
    source    => "puppet:///modules/syslog/elasticsearch.conf",
    notify    => Exec["syslog::update_supervisor"],
    require   => [ File["syslog::elasticsearch_data"], File["syslog::elasticsearch_data"], Exec["syslog::extract_elasticsearch"], Package["supervisor"] ],
  }

  # graylog setup
  git::clone{ "syslog::clone_graylog":
    repo      => "https://github.com/ehazlett/graylog",
    revision  => "master",
    dest      => "${graylog_dir}",
    require   => Package["git-core"],
  }
  file { "${graylog_dir}/config/general.yml":
    ensure    => present,
    content   => template("syslog/opencloud_syslog_general.yml.erb"),
    owner     => root,
    group     => root,
    require   => Git::Clone["syslog::clone_graylog"],
  }
  file { "${graylog_dir}/config/email.yml":
    ensure    => present,
    source    => "puppet:///modules/syslog/opencloud_syslog_email.yml",
    owner     => root,
    group     => root,
    require   => Git::Clone["syslog::clone_graylog"],
  }
  file { "${graylog_dir}/config/mongoid.yml":
    ensure    => present,
    source    => "puppet:///modules/syslog/opencloud_syslog_mongoid.yml",
    owner     => root,
    group     => root,
    require   => Git::Clone["syslog::clone_graylog"],
  }
  file { "/etc/supervisor/conf.d/opencloud_syslog.conf":
    content   => template("syslog/opencloud_syslog.conf.erb"),
    notify    => Exec["syslog::update_supervisor"],
    require   => [ File["${graylog_dir}/config/mongoid.yml"], Package["supervisor"] ],
  }
  exec { "syslog::wget_mongodb":
    cwd       => "/tmp",
    command   => "wget ${mongodb_url} -O mongodb.tar.gz > ${common::opencloud_conf_dir}/syslog_wget_mongodb",
    creates   => "${common::opencloud_conf_dir}/syslog_wget_mongodb",
    notify    => Exec["syslog::extract_mongodb"],
  }
  exec { "syslog::extract_mongodb":
    cwd         => "/tmp",
    command     => "tar zxf mongodb.tar.gz ; mv mongodb-linux* /opt/ ; mv /opt/mongodb-linux* /opt/mongodb ; rm -rf mongodb*",
    refreshonly => true,
    require     => Exec["syslog::wget_mongodb"],
  }
  file { "syslog::mongodb_data":
    ensure    => directory,
    path      => "/opt/mongodb_data",
    owner     => root,
    group     => root,
  }
  file { "/etc/supervisor/conf.d/mongodb.conf":
    source    => "puppet:///modules/syslog/mongodb.conf",
    notify    => Exec["syslog::update_supervisor"],
    require   => [ File["syslog::mongodb_data"], Exec["syslog::extract_mongodb"], Package["supervisor"] ],
  }
  package { "bundler":
    provider  => gem,
    require   => Exec["syslog::get_updated_rubygems"],
  }
  exec { "syslog::bundle_install":
    cwd     => "${graylog_dir}",
    command => "bundle install > ${common::opencloud_conf_dir}/syslog_bundle_install",
    user    => root,
    creates => "${common::opencloud_conf_dir}/syslog_bundle_install",
    require => [ Package["bundler"], Git::Clone["syslog::clone_graylog"] ],
  }
  exec { "syslog::wget_graylog_server":
    cwd       => "/tmp",
    command   => "wget ${graylog_server_url} -O graylog-server.tar.gz > ${common::opencloud_conf_dir}/syslog_wget_graylog_server_url",
    creates   => "${common::opencloud_conf_dir}/syslog_wget_graylog_server_url",
    notify    => Exec["syslog::extract_graylog_server"],
  }
  exec { "syslog::extract_graylog_server":
    cwd         => "/tmp",
    command     => "tar zxf graylog-server.tar.gz ; mv graylog2-server* /opt/ ; mv /opt/graylog2-server* ${graylog_server_dir} ; rm -rf graylog*",
    refreshonly => true,
    require     => Exec["syslog::wget_graylog_server"],
  }
  file { "/etc/graylog2.conf":
    ensure    => present,
    source    => "puppet:///modules/syslog/graylog2.conf",
    owner     => root,
    group     => root,
  }
  file { "/etc/supervisor/conf.d/opencloud_syslog_server.conf":
    content   => template("syslog/opencloud_syslog_server.conf.erb"),
    notify    => Exec["syslog::update_supervisor"],
    require   => [ Exec["syslog::extract_graylog_server"], Package["supervisor"] ],
  }
  # end graylog
}
