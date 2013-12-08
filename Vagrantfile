# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# How many mcollective guests to spawn
AGENTS=2
puppetMasterHostname = "puppetmaster"

Vagrant.require_plugin "vagrant-cachier"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # This is quite heavily redhat centric, but only for provisioning - chicken and egg, etc
  # The box I've created doesn't have puppet installed so I can test different versions
  config.vm.box = "centos64"

  # vagrant-cachier config
  # Disabled everything but yum, it tries to take over gem dirs and this confuses the package
  # installers - cpio tries to change permissions, which it can't over vmhgfs
  config.cache.auto_detect = false
  config.cache.enable :yum

  # Install puppet, configure avahi so we can use zeroconf
  config.vm.provision "shell", inline: "yum -y localinstall http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm"
  config.vm.provision "shell", inline: "yum -y install puppet avahi avahi-tools"

  # configure nsswitch
  config.vm.provision "puppet" do |p|
    p.manifest_file = 'zeroconf.pp'
    p.module_path = 'puppetmaster/modules'
  end

  # Stub
  AGENTS.times do |a|
  end

  config.vm.define "puppetmaster" do |puppetmaster|
    puppetmaster.vm.hostname = "puppetmaster.local"

    puppetmaster.vm.provision "shell", inline: "yum -y install puppet-server puppetdb-terminus"
    puppetmaster.vm.provision "shell", inline: "cp /vagrant/puppetmaster/puppet.conf /etc/puppet"
    puppetmaster.vm.provision "shell", inline: "service puppetmaster start"
    puppetmaster.vm.provision "puppet" do |p|
        p.manifest_file = 'puppetdb.pp'
    end
    # PuppetDB Takes a while to start - Java
    puppetmaster.vm.provision "shell", inline: "sleep 10"
    puppetmaster.vm.provision "puppet_server" do |puppet|
      puppet.puppet_server = "#{puppetMasterHostname}.local"
      puppet.options = "-t"
    end
  end

  # Below is single purpose containers for specific testbeds and demos

  config.vm.define "haproxy" do |ng|
    ng.vm.hostname = "haproxy.local"
    ng.vm.provision "puppet_server" do |puppet|
      puppet.puppet_server = "#{puppetMasterHostname}.local"
      puppet.options = "-t"
    end
  end

  config.vm.define "nagios" do |ng|
    ng.vm.hostname = "nagios.local"
    ng.vm.provision "puppet_server" do |puppet|
      puppet.puppet_server = "#{puppetMasterHostname}.local"
      puppet.options = "-t"
    end
  end

  config.vm.define "rundeck" do |rd|
    rd.vm.hostname = "rundeck.local"
    rd.vm.provision "puppet_server" do |puppet|
      puppet.puppet_server = "#{puppetMasterHostname}.local"
      puppet.options = "-t"
    end
  end

  config.vm.define "db" do |db|
    db.vm.hostname = "db.local"
    db.vm.provision "puppet_server" do |puppet|
      puppet.puppet_server = "#{puppetMasterHostname}.local"
      puppet.options = "-t"
    end
  end

  # Make a bunch of agents - if you decrease this number, make sure you
  # destroy the VMs, otherwise vagrant does strange things

  AGENTS.times do |i|
    config.vm.define "mcollective#{i}" do |mc1|
      mc1.vm.hostname = "mcollective#{i}.local"
      mc1.vm.provision "puppet_server" do |puppet|
        puppet.puppet_server = "#{puppetMasterHostname}.local"
        puppet.options = "-t"
      end
    end
  end

end
