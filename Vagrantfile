# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

AGENTS=4
puppetMasterIP = "192.168.50.10"
puppetMasterHostname = "puppetmaster"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "centos_6_4_x86_64"
  config.vm.provision "shell", inline: "yum -y localinstall http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm"
  config.vm.provision "shell", inline: "puppet resource host #{puppetMasterHostname}.localdomain ip=#{puppetMasterIP} host_aliases=puppet"
  AGENTS.times do |a|
    config.vm.provision "shell", inline: "puppet resource host mcollective#{a}.localdomain ip=192.168.50.#{11+a}"
  end

  config.vm.define "puppetmaster" do |puppetmaster|
    config.vm.network "private_network", ip: puppetMasterIP

    puppetmaster.vm.hostname = "puppetmaster"
    config.vm.provision "shell", inline: "yum -y install puppet-server"
    config.vm.provision "shell", inline: "cp /vagrant/puppetmaster/puppet.conf /etc/puppet"
    config.vm.provision "shell", inline: "puppet resource service iptables ensure=stopped enable=false"
    config.vm.provision "shell", inline: "service puppetmaster start"
  end

  AGENTS.times do |i|
    config.vm.define "mcollective#{i}" do |mc1|
      mc1.vm.hostname = "mcollective#{i}"
      config.vm.network "private_network", ip: "192.168.50.#{11+i}"
      config.vm.provision "shell", inline: "mkdir -p /vagrant/mcollective#{i}-ssl"
      config.vm.provision "shell", inline: "puppet resource host "
      config.vm.provision "shell", inline: "puppet agent -t --server=#{puppetMasterHostname}.localdomain; echo ''"
    end
  end

end
