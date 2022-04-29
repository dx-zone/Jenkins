# -*- mode: ruby -*-
# vi: set ft=ruby :

# VARIABLES TO BRIDGE MY LOCAL NETWORK INTERFACE (en0) WITH THE VAGRANT BOX
# AND SET A STATIC IP TO ACCESS THE BOX 

# Variables to bridge my local network interface (en0) with this Vagrant box
# and to set a static IP (192.168.0.216) to access this box from my local network (192.168.0.0/24)
# Example: config.vm.network NETWORK_TYPE, bridge: BRIDGED_INTERFACE, ip: LOCAL_IP_ADDRESS

NETWORK_TYPE = "public_network"
BRIDGED_INTERFACE = "en0: Wi-Fi (Wireless)"
HOSTNAME = "jenkins-01"
LOCAL_IP_ADDRESS = "192.168.0.216"

# Instruction to tell Vagrant to use "centos/stream8" as OS
# when constructing the box
BOX_IMAGE = "centos/stream8"

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = BOX_IMAGE
  #config.vm.box_version = "20210210.0"

  # Define a hostname for the box
  config.vm.hostname = HOSTNAME

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"
  config.vm.network NETWORK_TYPE, bridge: BRIDGED_INTERFACE, ip: LOCAL_IP_ADDRESS

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

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

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
  config.vm.provision "shell", inline: <<-SHELL
    # Inline script to install Jenkins and dependencies on Red Hat / CentOS 8 Stream
    # Update the system and install wget dnf
    yum update -y
    yum install wget net-tools dnf -y
    # Enable and configure firewalld rules
    systemctl enable firewalld
    systemctl restart firewalld
    YOURPORT=8080
    PERM="--permanent"
    SERV="$PERM --service=jenkins"
    firewall-cmd $PERM --new-service=jenkins
    firewall-cmd $SERV --set-short="Jenkins ports"
    firewall-cmd $SERV --set-description="Jenkins port exceptions"
    firewall-cmd $SERV --add-port=$YOURPORT/tcp
    firewall-cmd $PERM --add-service=jenkins
    firewall-cmd --zone=public --add-service=http --permanent
    firewall-cmd --reload
    systemctl restart firewalld
    # Setup Jenkins repo
    sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
    sleep 5
    sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
    # Install Java
    yum install fontconfig java-11-openjdk -y
    # Install Jenkins
    yum install jenkins -y
    # Enable and start Jenkins service
    systemctl enable jenkins.service
    systemctl start jenkins.service
    # SELINUX
    yum install policyoreutils-devl settroubleshoot-server -y
    semanage port -a -t http_port_t -p tcp 8080
    # Installing and setting nginx as proxy to redirect traffic from port 80 to 8080 (Jenkins's default port)
    yum install nginx -y
    if [[ ! -f /etc/nginx/nginx.conf.orig ]]
      then
      cp -a /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig
    fi
    grep -v '#' /etc/nginx/nginx.conf.orig > /etc/nginx/nginx.conf
    sed -i 's/        location \/ {/        location \/ {\n        proxy_pass http:\/\/127.0.0.1:8080;/g' /etc/nginx/nginx.conf
    systemctl enable nginx
    systemctl restart nginx
    setsebool -P httpd_can_network_connect 1&
    setsebool -P httpd_can_network_relay 1&

  SHELL

end
