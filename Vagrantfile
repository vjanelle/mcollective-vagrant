# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

AGENTS=1
puppetMasterIP = "192.168.50.10"
puppetMasterHostname = "puppetmaster"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "centos64"
  config.vm.provision "shell", inline: "yum -y localinstall http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm"
  config.vm.provision "shell", inline: "yum -y install puppet"
  config.vm.provision "shell", inline: "puppet resource host #{puppetMasterHostname}.localdomain ip=#{puppetMasterIP} host_aliases=puppet"
  config.vm.provision "shell", inline: "puppet resource service iptables ensure=stopped enable=false"
  AGENTS.times do |a|
    config.vm.provision "shell", inline: "puppet resource host mcollective#{a}.localdomain ip=192.168.50.#{11+a}"
  end

  config.vm.define "puppetmaster" do |puppetmaster|
    puppetmaster.vm.network "private_network", ip: puppetMasterIP

    puppetmaster.vm.hostname = "puppetmaster"
    puppetmaster.vm.provision "shell", inline: "yum -y install puppet-server"
    puppetmaster.vm.provision "shell", inline: "cp /vagrant/puppetmaster/puppet.conf /etc/puppet"
    puppetmaster.vm.provision "shell", inline: "service puppetmaster start"
    puppetmaster.vm.provision "puppet_server" do |puppet|
      puppet.puppet_server = "#{puppetMasterHostname}.localdomain"
      puppet.options = "-t"
    end
  end

  config.vm.define "nagios" do |ng|
    ng.vm.hostname = "nagios"
    ng.vm.network "private_network", ip: '192.158.50.9'
    ng.vm.provision "puppet_server" do |puppet|
      puppet.puppet_server = "#{puppetMasterHostname}.localdomain"
      puppet.options = "-t"
    end
  end

  config.vm.define "rundeck" do |rd|
    rd.vm.hostname = "rundeck"
    rd.vm.network "private_network", ip: '192.158.50.8'
    rd.vm.provision "puppet_server" do |puppet|
      puppet.puppet_server = "#{puppetMasterHostname}.localdomain"
      puppet.options = "-t"
    end
  end

  AGENTS.times do |i|
    config.vm.define "mcollective#{i}" do |mc1|
      mc1.vm.hostname = "mcollective#{i}"
      mc1.vm.network "private_network", ip: "192.168.50.#{11+i}"
      mc1.vm.provision "shell", inline: "mkdir -p /vagrant/mcollective#{i}-ssl"
      mc1.vm.provision "shell", inline: "puppet resource host "
      mc1.vm.provision "puppet_server" do |puppet|
        puppet.puppet_server = "#{puppetMasterHostname}.localdomain"
        puppet.options = "-t"
      end
    end
  end

end
