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
    master_config.vm.host_name = 'saltmaster'
    master_config.vm.network "private_network", ip: "192.168.11.10"
    master_config.vm.synced_folder "./states", "/srv/powerline-infrastructure/states/"
    master_config.vm.synced_folder "./pillar/", "/srv/powerline-infrastructure/pillar"
    master_config.vm.synced_folder "./reactor/", "/srv/powerline-infrastructure/reactor"
    master_config.vm.synced_folder "./runners/", "/srv/powerline-infrastructure/runners"
    master_config.vm.synced_folder "./dev/gpgkeys", "/etc/salt/gpgkeys"

    master_config.vm.provision :salt do |salt|

      salt.master_key = "dev/keys/master_minion.pem"
      salt.master_pub = "dev/keys/master_minion.pub"
      salt.minion_key = "dev/keys/master_minion.pem"
      salt.minion_pub = "dev/keys/master_minion.pub"

      salt.master_config = "dev/etc/master"
      salt.grains_config = "dev/etc/saltmaster_grains"
      salt.minion_config = "dev/etc/saltmaster_minion"

      salt.seed_master = {
        "apiserver" => "dev/keys/minion1.pub",
        "saltmaster" => "dev/keys/master_minion.pub"
      }

      salt.install_type = "stable"
      salt.install_master = true
      salt.no_minion = false
      salt.verbose = true
      salt.bootstrap_options = "-P -c /tmp"
    end

  end

  config.vm.define :apiserver do |api_config|
    api_config.vm.box = "ubuntu/trusty64"
    api_config.vm.host_name = 'apiserver'
    api_config.vm.network "private_network", ip: "192.168.11.11"
    api_config.vm.network :forwarded_port, guest: 80, host: 8080
    api_config.vm.network :forwarded_port, guest: 443, host: 8433

    api_config.vm.provision :salt do |salt|

      salt.grains_config = "dev/etc/apiserver_grains"
      salt.minion_config = "dev/etc/apiserver_minion"

      salt.minion_key = "dev/keys/minion1.pem"
      salt.minion_pub = "dev/keys/minion1.pub"
      salt.install_type = "stable"
      salt.verbose = true
      salt.colorize = true
      salt.bootstrap_options = "-P -c /tmp"
      salt.run_highstate = true
    end

  end

end
