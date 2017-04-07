# -*- mode: ruby -*-
# vi: set ft=ruby :

# If you edit this file, use two spaces for tabs, not TAB characters

# If your PC does not support VT extensions, paste this line into the config code below:
#   v.customize ["modifyvm", :id, "--hwvirtex", "off"]

# On your host system, you need to install vagrant plugins before using this vagrantfile:
#
# If you see "Unknown configuration section 'proxy'" then
#   vagrant plugin install vagrant-proxyconf
#
# If you see "The '' provisioner could not be found" 
#   vagrant plugin install vagrant-hosts

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!


username = "null"
password = "null"

if Dir.glob("#{File.dirname(__FILE__)}/.vagrant/machines/ansible_controller/virtualbox/*").empty? #|| ARGV[1] == '--provision'
  if not ENV['password'] or not ENV['username']
    puts "Set environment variable 'username' and 'password'"
	exit 0
  end
  username = ENV['username']
  password = ENV['password']
end

VAGRANTFILE_API_VERSION = "2"

HOSTS_NO_PROXY  = "localhost, 127.0.0.0/8, ansible-controller, ansible-client"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box_download_insecure = true
  config.proxy.no_proxy = HOSTS_NO_PROXY
  #config.proxy.no_proxy = HOSTS_NO_PROXY
  
  # Configure VM
  config.vm.define :ansible_controller do |ansible_controller_config|
    ansible_controller_config.vm.box = "server.box"
	ansible_controller_config.vm.network :private_network, ip: "10.1.172.25"
    ansible_controller_config.vm.network :forwarded_port,guest: 22,host: 2225,id: "ssh",host_ip: "127.0.0.1",auto_correct: false
    ansible_controller_config.vm.hostname = "ansible-controller.virtualbox.net"
	

    # modify server vm settings and attach disks
    ansible_controller_config.vm.provider "virtualbox" do |v, override|
      v.name = "ansible-controller"
      v.gui = false
      v.customize ["modifyvm", :id, "--memory", 1024]
      v.customize ["modifyvm", :id, "--ioapic", "on"]
      v.customize ["modifyvm", :id, "--cpus", "1"]
      v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
	  #override.proxy.enabled = false
    end
	ansible_controller_config.vm.provision :shell, :path => "controller.sh", :args => [username, password]
  end
  # /configure server VM
  
  # Configure VM
  config.vm.define :ansible_client do |ansible_client_config|
    ansible_client_config.vm.box = "server.box"
	ansible_client_config.vm.network :private_network, ip: "10.1.172.26"
    ansible_client_config.vm.network :forwarded_port,guest: 22,host: 2226,id: "ssh",host_ip: "127.0.0.1",auto_correct: false
    ansible_client_config.vm.hostname = "ansible-client.virtualbox.net"
	

    # modify server vm settings and attach disks
    ansible_client_config.vm.provider "virtualbox" do |v, override|
      v.name = "ansible-client"
      v.gui = false
      v.customize ["modifyvm", :id, "--memory", 1024]
      v.customize ["modifyvm", :id, "--ioapic", "on"]
      v.customize ["modifyvm", :id, "--cpus", "1"]
      v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
	  #override.proxy.enabled = false
    end

	ansible_client_config.vm.provision "shell",
      inline: "sh /vagrant/client.sh"
  end
  # /configure server VM

  # Set /etc/hosts entries
  config.vm.provision :hosts do |provisioner|
	provisioner.add_host '10.1.172.25', ['ansible-controller.virtualbox.net', 'ansible-controller']
	provisioner.add_host '10.1.172.26', ['ansible-client.virtualbox.net', 'ansible-client']
  end
  
end
# This doesn't work
system('history -c')

