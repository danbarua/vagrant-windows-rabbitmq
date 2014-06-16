# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.vm.box = "opentable/win-2012r2-standard-amd64-nocm"

    config.vm.provider :vmware_fusion do |v, override|
          v.gui = true
          v.vmx["memsize"] = "2048"
          v.vmx["numvcpus"] = "2"
      end

    #download and install rabbitmq
    config.vm.provision "shell" do|s|
      s.path = "./scripts/install_rabbitmq1.ps1"
      s.upload_path="c:/windows/temp/install_rabbitmq1.ps1"
      s.privileged = true,
      s.args = "'c:/tools' '17.0' '3.3.2'" #installdir, erlang version, rabbitmq version
    end

    #install rabbitmq service
    #enable rabbitmq management, federation and shovel plugins
    #start rabbitmq service
    config.vm.provision "shell" do|s|
      s.path = "./scripts/install_rabbitmq2.bat"
      s.upload_path = "c:/windows/temp/install_rabbitmq2.bat"
      s.privileged = true
    end

    #copy .erlang.cookie to vagrant user to enable rabbitmqctl
    #open windows firewall ports
    config.vm.provision "shell" do|s|
      s.path = "./scripts/install_rabbitmq3.ps1"
      s.upload_path = "c:/windows/temp/install_rabbitmq3.ps1"
      s.privileged = true
    end

    #forward rabbitmq ports to host
    config.vm.network "forwarded_port", guest: 15672, host: 15672
    config.vm.network "forwarded_port", guest: 5672, host: 5672
    config.vm.network "forwarded_port", guest: 5671, host: 5761
  end