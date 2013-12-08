package {['avahi','avahi-tools']:
    ensure => installed,
}

service { 'avahi-daemon':
    enable => true,
    ensure => true,
}

class { 'nsswitch':
    hosts => ['files', 'mdns_minimal [NOTFOUND=return]', 'dns'],
    require => Package['avahi']
}
