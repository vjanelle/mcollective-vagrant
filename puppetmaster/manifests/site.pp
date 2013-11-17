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

node 'puppetmaster.localdomain' {
  class { '::mcollective':
    middleware       => true,
    middleware_hosts => [ $broker ],
    client           => true,
  }
  include puppetdb
}

node default {
  class { '::mcollective':
    middleware_hosts => [ $broker ],
    client           => true,
  }
}
