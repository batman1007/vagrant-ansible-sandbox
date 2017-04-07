# Ansible Vagrant Build
The idea of this repo, is to provide an ansible server and linux client that you can test ansible commands on or code against, in a completely sandboxed environment on your Windows desktop/laptop.  
It's not intended to be used for interaction with AWS, however I have installed python2-boto and awscli rpm's for potential support.
  
  
There are two parts to this setup:
* Packer Build - typically run once to setup your VM Template (server.box)
* Vagrant Build - can be built/destroyed how many times you like (should always be consistent!), uses the packer template created (server.box)
  
  
**INFO: Ansible v2.2 used in this Build.**
  
  
## Pre-Req's
* At least 8GB free space on C: Drive
* Install VirtualBox - https://www.virtualbox.org/wiki/Downloads
* Install PuTTy - https://the.earth.li/~sgtatham/putty/latest/w64/putty-64bit-0.68-installer.msi
* Install Git Bash for Windows - https://git-for-windows.github.io/
* Download Packer - https://www.packer.io/downloads.html
* Install Vagrant - https://www.vagrantup.com/downloads.html
  
  
  
## Packer Build
Packer build creates your box image file (server.box), for Vagrant to use as a VM Template.
  
### Pre-requisites
* Create a C:\Packer directory
* Git clone this repo into C:\Packer (i.e. open GIT Bash session and change directory to C:\Packer first)
* Place packer.exe into C:\Packer\vagrant-ansible-sandbox or ensure its in your Windows PATH.
* Place CentOS 7 x86_64 Base ISO ( http://isoredirect.centos.org/centos/7/isos/x86_64/CentOS-7-x86_64-DVD-1611.iso ) in C:\Packer\vagrant-ansible-sandbox  
I'm using v1611 in my packer build, but feel free to change this to whichever version you want, remember to update centos7.json though.  
**NOTE:** centos7.json will look in your base folder for the ISO
  
### Running Packer
* Open a GIT Bash session and change directory to C:\Packer\vagrant-ansible-sandbox
* To create the server.box file run the following:
```
./packer.exe build centos7.json
```
After this completes, you should have a server.box file in your C:\Packer\vagrant-ansible-sandbox folder. If so, you can run the vagrant steps.
  
## Vagrant Build
The vagrant build creates two VM's:
* Ansible Controller  
This has ansible installed, via RPM, as well as a few other helpful packages for ansible development:
  - git
  - ansible-inventory-grapher - https://github.com/willthames/ansible-inventory-grapher
  - ansible-lint - https://github.com/willthames/ansible-lint
  - ansible-review - https://github.com/willthames/ansible-review
  - awscli - https://aws.amazon.com/cli/ 
  - boto - https://github.com/boto/boto
  
* Ansible Client  
This is a basic server, with an ansible user on. It's for testing your ansible code against from the controller.
  
### Private Key
Part of the build creates a user, based on your username/password combination you set. If you want to add your own ssh key for some reason (I have a git ssh key so I normally add this) you can place your private key (id_rsa) in the C:\Packer\vagrant-ansible-sandbox\scripts folder.
When you 'vagrant up' it will look for the id_rsa file and place it in your ~/.ssh/ directory.
  
  
### Pre-requisites
* Before running vagrant, open a GIT Bash session and set the following env variables to ensure proxy config gets picked up correctly during Vagrant, i.e.
```
  export username=myusername
  export password='mypassword'			# The single quotes here ARE important
```
This could be any username/password. I'm actually behind an authenicated proxy, so I have to add my proxy auth username/password. These will be stored for the GIT Bash session ONLY, but will also remain in the .bash_history file.  
**Ideally you should run 'history -c' after running 'vagrant up' to stop your password being stored anywhere. I haven't figured out a way to prompt for password during 'vagrant up'.**
  
* Install vagrant plugins, in the same GIT Bash session opened above, run:  
(if you've already installed these, you don't need to do it again)
```
vagrant plugin install vagrant-proxyconf
vagrant plugin install vagrant-hosts
```
  
* Proxy config. If you happen to be behind a proxy, edit the 'controller.sh' script and uncomment the 'export http...' lines and modify the url to suit your configuration. Part of the controller.sh relies on internet access for yum installs from EPEL. I 'could' set some environment variable up to trap this at the Vagrantfile but haven't bothered just yet.
  
  
### Running
  
To create the ansible environment, you can **run the following from the same GIT Bash session opened in the pre-req's above** while inside the C:\Packer\vagrant-ansible-sandbox directory:
```
  vagrant up
```
1. **NOTE:** Once this process is complete, you should clear your bash history as your password is stored in .bash_profile, do this by typing 'history -c'.
2. **NOTE:** Before you close the GIT Bash Window, look for the root password that's been auto-generated in the Vagrant output, it'll be the red text.
  
After 'vagrant up' completes, the following VM's will be created:
  
| VM            | SSH Port Forwards      |
|---------------|---------------------|
| ansible_controller  | 2225=>22      |
| ansible_client | 2226=>22  |
  
If you only want to create just an individual VM, you can just run 'vagrant up vmname' instead, i.e.:
```
  vagrant up ansible_controller
```
  
### Logging in
If all went to plan, you should be able to ssh via Putty to the localhost on the forwarded ports above, using your username/password entered earlier:
```
myuser@localhost:2225
```
**NOTE:** For ansible_controller, the root password will be output on the GIT Bash window, as it's set during the build process. Your user has full sudo rights anyway, but if it failed to create, you might want to get in and check /var/log/vagrant.log for the gory details.
  
  
#### Running ansible
You should be able to run ansible as your own user.
  
Run ansible against the client (/etc/ansible/hosts and /etc/ansible/ansible.cfg have been pre-configured):
```
ansible virtualbox -m ping
```
'virtualbox' is a group in /etc/ansible/hosts that ansible_client is a member of so you should get a response of pong. You can now create some ansible playbooks and roles to test against your client. You could add more clients to you VagrantFile (or a loop) so you can setup multiple clients to run ansible commands against.
  
  
### Suspending/Resuming
Once you've built your VM's, it's unlikely you will need to rebuild them everytime, therefore it's easier to use:
```
vagrant suspend or resume
````
...to manage the VM's.
  
### Destroying
To destroy the VM's you can run:
```
vagrant destroy
```
  
This will try destroying all. If you don't want to destroy all, you can 'vagrant destroy vmname', i.e.:
```
vagrant destroy ansible_client
```
  
### Rebuilding
This is just a questions of running 'vagrant up', assuming you've destroyed them first.  
Remember to set your username/password environment variables for the GIT Bash session and clear your history afterwards!!!
  
### Proxy
The ansible_controller has the functionality to set a proxy. Two bash command available to your user are:
* proxyon
* proxyoff  
  I won't explain what they stand for....
