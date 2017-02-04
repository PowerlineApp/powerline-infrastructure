# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
  end
  config.vm.define :master do |master_config|
    master_config.vm.box = "ubuntu/trusty64"
    master_config.vm.host_name = 'saltmaster.local'
    master_config.vm.network "private_network", ip: "192.168.11.10"
    master_config.vm.synced_folder "./states", "/srv/salt/"
    master_config.vm.synced_folder "./pillar/", "/srv/pillar"
    master_config.vm.synced_folder "./reactor/", "/srv/reactor"

    master_config.vm.provision :salt do |salt|
      salt.master_config = "dev/etc/master"
      salt.master_key = "dev/keys/master_minion.pem"
      salt.master_pub = "dev/keys/master_minion.pub"
      salt.minion_key = "dev/keys/master_minion.pem"
      salt.minion_pub = "dev/keys/master_minion.pub"
      salt.seed_master = {
                          "minion1" => "dev/keys/minion1.pub",
                         }

      salt.install_type = "stable"
      salt.install_master = true
      salt.no_minion = true
      salt.verbose = true
      salt.bootstrap_options = "-P -c /tmp"
    end

    master_config.vm.provision "shell",
      path: "dev/dev-setup.sh"

  end

  config.vm.define :minion1 do |minion_config|
    minion_config.vm.box = "ubuntu/trusty64"
    minion_config.vm.host_name = 'saltminion1.local'
    minion_config.vm.network "private_network", ip: "192.168.11.11"
    minion_config.vm.network :forwarded_port, guest: 80, host: 8080
    minion_config.vm.network :forwarded_port, guest: 443, host: 8433

    minion_config.vm.provision :salt do |salt|
      salt.minion_config = "dev/etc/minion1"
      salt.minion_key = "dev/keys/minion1.pem"
      salt.minion_pub = "dev/keys/minion1.pub"
      salt.install_type = "stable"
      salt.verbose = true
      salt.colorize = true
      salt.bootstrap_options = "-P -c /tmp"
      #salt.run_highstate = true
    end

    minion_config.vm.provision "shell",
      inline: "ln -s /vagrant/dev/etc/minion_grains /etc/salt/grains"

    minion_config.vm.provision "shell",
      inline: "service salt-minion restart"
  end

end
