# Certified Jenkins Engineer



This is my quick reference of commands, configuations and procedures to work with Jenkins  during my learning process to become Certified Jenkins Engineer.



**Books and Resources I'm Learning From**

[Certified Jenkins Engineer](https://www.whizlabs.com/learn/course/certified-jenkins-engineer/306/video), by Whizlabs.com

[What is Jenkins - Jenkins Overview, Definition of Jenkins Master & Slave](https://www.toolsqa.com/jenkins/what-is-jenkins/)

[Learn Ruby The Hard Way, 3rd Edition](https://learnrubythehardway.org/book/), by Zed A. Shaw (come handy when working with Vagrantfile or with any other Hashi Corp software)

[Vagrant: Machine Settings](https://www.vagrantup.com/docs/vagrantfile/machine_settings)



**Jenkins Documentation**

* [Jenkins](https://www.jenkins.io)
* [Installing Jenkins: Red Hat / CentOS](https://www.jenkins.io/doc/book/installing/linux/#red-hat-centos)





**Requirements**

* Linux, Mac OS X or Windows with Vagrant and VirtualBox installed
* 2+ GB RAM free to be consumed by VMs
* 5+ GB of disk space to be consumed by VMs

**Notes on Vagrant**

By default, Vagrant depends on VirtualBox as a provider to create VMs (also known as boxes). Both, VirtualBox and Vagrant are free to download and use without paying anything. Vagrant depends on a configuration file, named as Vagrantfile, a configuration file that defines a VM as a code.  Vagrant creates a box out of the instructions defined in the code inside the Vagrantfile.  A  base image, which holds the operating system, also needs to be specified in the Vagrantfile, for Vagrant to be able to download or look for that image and create a box with the rest of the parameters and definitions found in the Vagrantfile. The Vagrant box image being used in this instructions is "centos/stream8".  This image was prepared and uploaded by someone else and uploaded to Vagrant Cloud repository. Vagrant will try to locate that image locally, if is not found locally, it will be downloaded from the Vagrant Cloud, and stored in your computer locally.

As mentioned before, Vagrant depends on VirtualBox by default, to create boxes, but is no limted to VirtualBox. Vagrant also supports VMware Workstation (for Windows & Linux) as well as VMware Fusion (for Mac OS X) as virtualization software to create the VMs/boxes. Should you decide to use VMware software instead of VirtualBox as a virtualization software, you need to purchase a **vmware_desktop** **plugin** (also known as a provider plugin) from Vagrant, configure it, and setup a license.lic file send to you by [HashiCorp, Vagrant.](https://www.vagrantup.com/docs/providers/vmware)

Since the Vagrantfile referenced in the following instructions is based on an image that was packed as a box without support for **vmware_desktop provider,** a new VM can be created with VMware, packed, and converted into a Vagrant box with support for both, VirtualBox and VMware. 

After that, all it takes, is to make reference to that newly created box and tell Vagrant to launch the box using VMware as a provider.  That is if you decide to go with VMware Workstation/Fusion as a virtualization software with Vagrant.



This section is not intended to describe how to create your custom Vagrant box. Just to make a distinction of what to do different in case you prefer to use Vagrant with VMware as provider to follow along.



Once a custom Vagrant box has been created and added to your local Vagrant boxes, find the  `BOX_IMAGE = "centos/stream8"` variable in the Vagrantfile and replace the value with the name of your custom box. Then launch the box with Vagrant specifying Vmware as a provider. I.E.

```bash
$ cd ./working_dir

$ cat Vagrantfile
### OUTPUT OMMITED ###
BOX_IMAGE = "the_name_of_my_custom_box_goes_here"
### OUTPUT OMMITED ###

$ vagrant up --provider vmware_desktop
```



### Getting Started: Deploying a Vagrant Box with Jenkins

* Create a working directory on your local machine and change into it

  ```bash
  mkdir Jenkins
  cd Jenkins
  ```

  

* Create a Vagrant file that contains the instruction to build a box (virtual machine) with instructions (inline shell script) to download packages, setup dependencies, selinux, firewalld, install nginx to proxy traffic from port 80 to 8080 (Jenkins uses 8080 as default) and then install Jenkins.

```bash
cat << EOF > Vagrantfile
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

EOF
```



**Spin up (creating) a Jenkins box with Vagrant**

```bash
vagrant up
```



If Vagrant get stuck in one of the process, reissue the initial script provisioning

```bash
vagrant provision
```



Alternatively, destroy the Vagrant box and rebuild it again

```bash
vagrant destroy -f
vagrant up
```



Log into the box, check the initial Jenkins password, and copy it

```bash
vagrant ssh
cat /var/lib/jenkins/secrets/initialAdminPassword
```



Log into the web interface using the static IP defined in the Vagrantfile. I.E. 192.168.0.216.

`http://192.168.0.216:8080` or `http://192.168.0.216`

Paste the password copied from `/var/lib/jenkins/secrets/initialAdminPassword` and continue the setup over the web interface.

![image-20220427122139846](/Users/danielcruz/Library/Application Support/typora-user-images/image-20220427122139846.png)



**Setting Linux shell password and bash access for the jenkins user**

Display entries from name service switch type AKA databases supported

```bash
getent passwd jenkins
```

Set Jenkins username to have login shell access

```bash
getent passwd jenkins # Display name service switch entries for the user (for comparison)
usermod -s /bin/bash jenkins # grants shell (bash) access to the user
getent passwd jenkins # Display name service switch entries for the user (for comparison)
sudo passwd jenkins

```



Jenkins user needs to run a build on a remote system using SSH key and the user is in lock down mode as default. In the event Jenkins needs to run a build locally, ssh key is required, and sudo access as well. These are the steps to generate an ssh key, copy the key to Jenkins home directory's ./ssh, and set the user with sudo privileges as root.

```bash
sudo su - jenkins # Switch user as jenkins
ssh-keygen # Generate SSH key for jenkins user
ssh-copy-id jenkins@localhost # Copy the SSH key to the server itself
sudo -s # Switch user as root
if [ ! -f /etc/sudoers ] # Make a copy of the sudoer file if it doesn't exist
then
    cp -a /etc/sudoers /etc/sudoers.orig
fi
cat << EOF >> /etc/sudoers # Add jenkins to the sudoer file for root privileges
## Allow Jenkins to run any command without a password promt.
## Modify according the commands the Jenkins user will need access to in your environment.Tailor this part to your specific needs.
jenkins    ALL=(ALL:ALL) NOPASSWD
EOF

```




**Setup a new Jenkins user on a remote system**

A new Jenkins user is required on a remote system that will run the builds for the Jenkins server. The Jenkins server will utilize this remote system account to run slave builds.

```bash
sudo useradd jenkins # Creating an user for Jenkins on a remote system
sudo passwd jenkins # Setting the password for the newly created user
sudo -s # Switch user as root
if [ ! -f /etc/sudoers ] # Make a copy of the sudoer file if it doesn't exist
then
    cp -a /etc/sudoers /etc/sudoers.orig
fi
cat << EOF >> /etc/sudoers # Add jenkins to the sudoer file for root privileges
## Allow Jenkins to run any command without a password promt.
## Modify according the commands the Jenkins user will need access to in your environment.Tailor this part to your specific needs.
jenkins    ALL=(ALL:ALL) NOPASSWD
EOF

```



Going back to the primary system, the Jenkins server, we need to copy the SSH key to the remote system for SSH key password-less access from the Jenkins server into the Jenkins remote system. Then test the ssh access to the remote system from Jenkins server.

```bash
ssh-copy-id jenkins@<remote_system_ip>
ssh jenkins@<remote_system_ip>
```



To be continued...
