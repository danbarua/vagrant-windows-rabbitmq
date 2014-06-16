vagrant-windows-rabbitmq
========================

A Windows Server 2012 VagrantBox running RabbitMQ

Box
---
Though this Vagrantbox has been developed against VMWare Fusion using a custom Windows Server base box, it should work against any Windows2012 VM which has been set up to work with Vagrant, ie. has SSH and Powershell 3.0+ installed.

A Windows Server 2012 box for VirtualBox has been [contributed by OpenTable to VagrantCloud](https://vagrantcloud.com/opentable/win-2012r2-standard-amd64-nocm) and can be installed via the command-line:

```bash
    $vagrant box add opentable/win-2012r2-standard-amd64-nocm
```

Update the Vagrantfile to indicate your box of choice:
```ruby
    config.vm.box = "opentable/win-2012r2-standard-amd64-nocm"
```

Installation
------------
* Requires an Internet Connection!
* Downloads and Installs Erlang OTP 17.0 to C:\Tools\Erlang
* Downloads and Installs RabbitMQ 3.3.2 to C:\Tools\RabbitMQ
* Sets RabbitMQ base directory to C:\Tools\RabbitMQ*
* Installs plugins
 * rabbitmq_management
 * rabbitmq_federation
 * rabbitmq_federation_management
 * rabbitmq_shovel
 * rabbitmq_shovel_management
* Forwards ports 5672, 5671 and 15672 from host to guest.
* Adds Rabbitmq\sbin folder to the system PATH

*a quirk of running RabbitMQ on Windows is that the config, logs and mnesia database are by default installed to the %APPDATA% folder of the user who installed RabbitMQ - this Box overrides that rather annoying convention.


Override installation location and rabbitmq version by passing arguments to install_rabbitmq.ps1:

```ruby
    config.vm.provision "shell" do|s|
      s.path = "./scripts/install_rabbitmq1.ps1"
      s.upload_path="c:/windows/temp/install_rabbitmq1.ps1"
      s.privileged = true,
      s.args = "'c:/test' '17.0' '3.3.2'" #installdir, erlang version, rabbitmq version
    end
```

Todo
----
* Install OpenSSL and generate certificates
* Test with multiple nodes (federation, shovel, clustering etc)
