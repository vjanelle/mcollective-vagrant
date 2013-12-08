# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

AGENTS=1
puppetMasterIP = "192.168.50.10"
puppetMasterHostname = "puppetmaster"

Vagrant.require_plugin "vagrant-cachier"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "centos64"
  config.cache.auto_detect = false
  config.cache.enable :yum
  config.vm.provision "shell", inline: "yum -y localinstall http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm"
  config.vm.provision "shell", inline: "yum -y install puppet avahi avahi-tools"
  config.vm.provision "puppet" do |p|
    p.manifest_file = 'zeroconf.pp'
    p.module_path = 'puppetmaster/modules'
  end
  # config.vm.provision "shell", inline: "puppet resource host #{puppetMasterHostname}.local ip=#{puppetMasterIP} host_aliases=puppet"
  #config.vm.provision "shell", inline: "puppet resource service iptables ensure=stopped enable=false"
  AGENTS.times do |a|
    # config.vm.provision "shell", inline: "puppet resource host mcollective#{a}.local ip=192.168.50.#{11+a}"
  end

  config.vm.define "puppetmaster" do |puppetmaster|
    # puppetmaster.vm.network "private_network", ip: puppetMasterIP

    puppetmaster.vm.hostname = "puppetmaster.local"
    puppetmaster.vm.provision "shell", inline: "yum -y install puppet-server puppetdb-terminus"
    puppetmaster.vm.provision "shell", inline: "cp /vagrant/puppetmaster/puppet.conf /etc/puppet"
    puppetmaster.vm.provision "shell", inline: "service puppetmaster start"
    puppetmaster.vm.provision "puppet" do |p|
        p.manifest_file = 'puppetdb.pp'
    end
    puppetmaster.vm.provision "shell", inline: "sleep 10"
    #puppetmaster.vm.provision "puppet_server" do |puppet|
    #  puppet.puppet_server = "#{puppetMasterHostname}.local"
    #  puppet.options = "-t"
    #end
  end

  config.vm.define "haproxy" do |ng|
    ng.vm.hostname = "haproxy.local"
    # ng.vm.network "private_network", ip: '192.168.50.8'
    ng.vm.provision "puppet_server" do |puppet|
      puppet.puppet_server = "#{puppetMasterHostname}.local"
      puppet.options = "-t"
    end
  end

  config.vm.define "nagios" do |ng|
    ng.vm.hostname = "nagios.local"
    # ng.vm.network "private_network", ip: '192.168.50.9'
    ng.vm.provision "puppet_server" do |puppet|
      puppet.puppet_server = "#{puppetMasterHostname}.local"
      puppet.options = "-t"
    end
  end

  config.vm.define "rundeck" do |rd|
    rd.vm.hostname = "rundeck.local"
    # rd.vm.network "private_network", ip: '192.168.50.8'
    rd.vm.provision "puppet_server" do |puppet|
      puppet.puppet_server = "#{puppetMasterHostname}.local"
      puppet.options = "-t"
    end
  end

  config.vm.define "db" do |rd|
    rd.vm.hostname = "db.local"
    # rd.vm.network "private_network", ip: '192.168.50.7'
    rd.vm.provision "puppet_server" do |puppet|
      puppet.puppet_server = "#{puppetMasterHostname}.local"
      puppet.options = "-t"
    end
  end

  AGENTS.times do |i|
    config.vm.define "mcollective#{i}" do |mc1|
      mc1.vm.hostname = "mcollective#{i}.local"
      # mc1.vm.network "private_network", ip: "192.168.50.#{11+i}"
      mc1.vm.provision "shell", inline: "mkdir -p /vagrant/mcollective#{i}-ssl"
      mc1.vm.provision "shell", inline: "puppet resource host "
      mc1.vm.provision "puppet_server" do |puppet|
        puppet.puppet_server = "#{puppetMasterHostname}.local"
        puppet.options = "-t"
      end
    end
  end

end
