# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "centos_6_4_x86_64"
  config.vm.provision "shell", inline: "yum -y localinstall http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm"

  config.vm.define "puppetmaster" do |puppetmaster|
    puppetmaster.vm.hostname = "puppetmaster"
    config.vm.provision "shell", inline: "yum -y install puppet-server"
    config.vm.provision "shell", inline: "cp /vagrant/puppetmaster/puppet.conf /etc/puppet"
  end

  5.times do |i|
    config.vm.define "mcollective#{i}" do |mc1|
      mc1.vm.hostname = "mcollective#{i}"
      config.vm.provision "shell", inline: "mkdir -p /vagrant/mcollective#{i}-ssl"
      config.vm.provision "shell", inline: "puppet agent -t ; echo ''"
      config.vm.provision "shell", inline: "cp -R /var/lib/puppet/ssl/* /vagrant/mcollective#{i}-ssl/"
    end
  end

end
