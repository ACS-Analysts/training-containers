# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bwmaas/sandbox-minikube"
  config.vm.provider "virtualbox" do |vb|
     vb.memory = "2048"
     vb.cpus = 2
     vb.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
     vb.customize [ "modifyvm", :id, "--audio", "none" ]
  end
end
