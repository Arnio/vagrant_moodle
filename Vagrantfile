# -*- mode: ruby -*-
# vi: set ft=ruby :
MAINDB="moodledb"
USERDB="moodleus"
PASSWDDB="moodle123"
BASEHOST="192.168.56.10" #1-99
BALHOST="192.168.56.100" #1-99
NETWORK="192.168.56." # xxx.xxx.xxx.
NODE_COUNT = 2

BOX_IMAGE = "centos/7"

Vagrant.configure("2") do |config|
  
  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  # config.vm.network "forwarded_port", guest: 22, host: 2222

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
  
  config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
     vb.memory = "2048"
  end
     
  config.vm.define "db" do |dbconfig|
    dbconfig.vm.box = BOX_IMAGE
    dbconfig.vm.hostname = "moodledb"
    dbconfig.vm.network :private_network, ip: BASEHOST
    dbconfig.vm.provision "shell", path: "scenarioMDB.sh", :args => [MAINDB, USERDB, PASSWDDB, NETWORK, BASEHOST]
    dbconfig.vm.provision "shell", path: "scenarioRedis.sh", :args => [PASSWDDB, BASEHOST]
  end
 
  (1..NODE_COUNT).each do |i|
    config.vm.define "node#{i}" do |webconfig|
      webconfig.vm.box = BOX_IMAGE
      webconfig.vm.hostname = "node#{i}"
      webconfig.vm.network :private_network, ip: "#{NETWORK}"+"#{i + 100}"
      webconfig.vm.provision "shell", path: "scenarioAWEB.sh", :args => [PASSWDDB, BASEHOST]
      WWWHOST="#{NETWORK}"+"#{i + 100}"
      if i==1
        webconfig.vm.provision "shell", path: "scenarioINST.sh", :args => [MAINDB, USERDB, PASSWDDB, BASEHOST, BALHOST, WWWHOST]
      else
        webconfig.vm.provision "shell", path: "scenarioCFG.sh", :args => [MAINDB, USERDB, PASSWDDB, BASEHOST, BALHOST, WWWHOST]
      end
            
    end
  end
  
  config.vm.define "bal" do |balconfig|
    balconfig.vm.box = BOX_IMAGE
    balconfig.vm.hostname = "moodlebal"
    balconfig.vm.network :private_network, ip: BALHOST
    balconfig.vm.provision "shell", path: "scenarioBAL.sh", :args => [BALHOST]
    (1..NODE_COUNT).each do |n|
      WEBHOST="#{NETWORK}"+"#{n + 100}"
      balconfig.vm.provision "shell", path: "scenarioAddWeb.sh", :args => [WEBHOST]
    end
  end 
 
  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
  

end