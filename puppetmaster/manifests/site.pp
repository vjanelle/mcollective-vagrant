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

@mcollective::plugin { $plugins:
  package => true,
}
@mcollective::plugin { 'sysctl':
  package    => true,
  type       => 'data',
  has_client => false,
}
@mcollective::server::setting { 'direct_addressing':
  setting => 'direct_addressing',
  value   => 1,
}

package {'git':
  ensure => installed,
}

puppet_config { 'agent/server':
  ensure => present,
  value  => 'puppetmaster.local',
}

node 'puppetmaster' {
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
  Mcollective::Server::Setting <| |>
  Mcollective::Plugin <| |>
}

node default {
  class { '::mcollective':
    middleware_hosts => [ $broker ],
    client           => true,
  }
  Mcollective::Server::Setting <| |>
  Mcollective::Plugin <| |>
}

node 'haproxy' {
  package { 'socat':
    ensure => installed,
  }
  class { 'haproxy':
    enable                  => true,
    global_options          => {
      'log'                 => "${::ipaddress} local0",
      'chroot'              => '/var/lib/haproxy',
      'pidfile'             => '/var/run/haproxy.pid',
      'maxconn'             => '4000',
      'user'                => 'haproxy',
      'group'               => 'haproxy',
      'daemon'              => '',
      'stats'               => 'socket /var/lib/haproxy/stats'
    },
    defaults_options        => {
      'log'                 => 'global',
      'stats'               => 'enable',
      'option'              => 'redispatch',
      'retries'             => '3',
      'timeout'             => [
        'http-request 10s',
        'queue 1m',
        'connect 10s',
        'client 1m',
        'server 1m',
        'check 10s'
      ],
      'maxconn'             => '8000'
    },
  }
  haproxy::listen { 'testapp00':
    ipaddress        => $::ipaddress,
    ports            => '80',
    mode             => 'http',
    options          => {
      'http-check'   => ['expect string true'],
      'option'       => ['httpchk /testapp-0.1/lbPing/index'],
    }
  }
}

node /mcollective(.+)/ inherits default {
  package { 'tomcat6':
    ensure => installed,
  }
  @@haproxy::balancermember { $::fqdn:
    listening_service => 'testapp00',
    server_names      => $::fqdn,
    ipaddresses       => $::ipaddress,
    ports             => '8080',
    options           => ['check']
  }
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
