# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bwmaas/sandbox-minikube"
  if Vagrant::Util::Platform.windows? then
      config.vm.network "private_network", ip: "172.16.0.2", name: "VirtualBox Host-Only Ethernet Adapter", adapter: 2
  else
      config.vm.network "private_network", ip: "172.16.0.2", name: "vboxnet0", adapter: 2
  end
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
    vb.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
    vb.customize [ "modifyvm", :id, "--audio", "none" ]
  end
end
