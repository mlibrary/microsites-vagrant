# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "debian/jessie64"
  config.vm.hostname = "microsites"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "10.255.21.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
  config.vm.synced_folder '.', '/vagrant', disabled: true

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end
  config.vm.provision "ansible" do |ansible|
    ansible.verbose = 'v'
    ansible.groups = {
      'vagrant' => ['default']
    }
    ansible.playbook = 'playbook.yml'
  end

  config.trigger.after [:provision] do |trigger|
    trigger.name = "Clone microsites code"
    trigger.exit_codes = [0, 128]
    trigger.run = { inline: "git clone https://github.com/mlibrary/microsites" }
  end

  config.trigger.after [:provision] do |trigger|
    trigger.name = "Provisioning configuration"
    trigger.ruby do |env, machine|
      system("bin/wp-config")
      system("bin/unison setup")
      system("bash -c '(cd rb && bundle install --path .bundle)'")
      unless File.exist?('credentials/box-config.yml')
        puts
        puts "Configuring box."
        cfg = {}
        cfg['client_id'] = ask "client_id: "
        cfg['client_secret'] = ask "client_secret: "
        IO.write('credentials/box-config.yml', YAML.dump(cfg))
      end
      system("bin/box setup")
    end
  end

  config.trigger.before [:halt, :reload, :suspend, :destroy] do |trigger|
    trigger.name = "Stop Unison"
    trigger.run = { inline: "bin/unison stop" }
  end

  config.trigger.after [:up, :resume, :reload] do |trigger|
    trigger.name = "Start Unison"
    trigger.run = { inline: "bin/unison start" }
  end

  # The triggers plugin doesn't trigger on `vagrant status` calls.
  if ARGV[0] == 'status'
    puts "Unison status:"
    puts
    puts `bin/unison status`
    puts
  end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   sudo apt-get update
  #   sudo apt-get install -y apache2
  # SHELL

end
