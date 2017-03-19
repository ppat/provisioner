# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.box_version = "20170317.0.0"
  config.vm.box_check_update = false

  config.vm.synced_folder "~/", "/vagrant_home"

  config.vm.provider "virtualbox" do |vb|
     vb.memory = "1024"
  end

  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y zip unzip vim curl wget less \
                       python python-software-properties \
                       software-properties-common
    echo "*****************************************************"
    echo "********* Basic environment setup completed *********"
    echo "*****************************************************"
    echo

    apt-add-repository ppa:ansible/ansible
    apt-get update
    apt-get install -y ansible
    echo "*****************************************************"
    echo "****************** Ansible installed ****************"
    echo "*****************************************************"
    echo

    wget --no-verbose -O /tmp/packer.zip https://releases.hashicorp.com/packer/0.12.3/packer_0.12.3_linux_amd64.zip
    cd /tmp
    unzip /tmp/packer.zip
    mv packer /usr/local/sbin/
    rm /tmp/packer.zip
    chmod 755 /usr/local/sbin/packer
    echo "*****************************************************"
    echo "**************** Packer installed *******************"
    echo "*****************************************************"
    echo

  SHELL

  config.vm.provision "docker"
end
