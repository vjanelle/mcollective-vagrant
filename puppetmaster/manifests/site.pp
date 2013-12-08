include epel

# Add some sanity to package management
Yumrepo<| |> -> Package<| |>

# Mcollective-activemq server is the puppetserver

$broker = $::servername
$plugins = [
  filemgr,
  iptables,
  nettest,
  nrpe,
  package,
  puppet,
  service,
]

mcollective::plugin { $plugins:
  package => true,
}
mcollective::plugin { 'sysctl':
  package    => true,
  type       => 'data',
  has_client => false,
}
mcollective::server::setting { 'direct_addressing':
  setting => 'direct_addressing',
  value   => 1,
}

package {'git':
  ensure => installed,
}

node 'puppetmaster.localdomain' {
  include puppetdb
  include puppetdb::master::config

  class { '::mcollective':
    middleware       => true,
    middleware_hosts => [ $broker ],
    client           => true,
  }
  package { 'colorize':
    ensure   => installed,
    provider => gem,
  }
}

node default {
  class { '::mcollective':
    middleware_hosts => [ $broker ],
    client           => true,
  }
}

node 'haproxy' {
  include haproxy
}

node 'mcollective0' inherits default {
  include apache
  package { 'php':
  }
  package { 'php-pgsql':
  }
  package { 'php-ZendFramework-Db-Adapter-Pdo-Pgsql':
  }
  apache::mod { 'php5':
  }
  include php_composer_rpms
}

node 'db' inherits default {
  class {'postgresql::server':
    listen_addresses => '*',
    ipv4acls         => ['host all webapp 192.168.50.0/24 md5']
  }
  postgresql::server::db {'webapp':
    user     => 'webapp',
    password => postgresql_password('webapp','webapppw')
  }
}
