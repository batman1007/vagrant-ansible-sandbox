#!/bin/bash
(
username=${1-null}
password=${2-null}

# Setup proxy for this session - uncomment below if you are behind a proxy and modify the url appropriately
#export http_proxy="http://DOMAIN_NAME\\${username}:${password}@my_proxy_host:80"
#export https_proxy="http://DOMAIN_NAME\\${username}:${password}@my_proxy_host:80"

# Install packages
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
yum install ansible git gitflow ansible-inventory-grapher ansible-lint ansible-review awscli cowsay libselinux vim pwgen python2-boto -y

# Setup git prompt
cp /vagrant/scripts/.git-prompt.sh /etc/skel
chmod 754 /etc/skel/.git-prompt.sh
echo "source ~/.git-prompt.sh" >> /etc/skel/.bashrc
echo "PS1='[\\u@\\h \\W\$(__git_ps1 \" (%s)\")]\\$ '" >> /etc/skel/.bashrc

# Setup bashrc proxyon / proxyoff 
cat >>/etc/skel/.bashrc <<EOF
if [ -f ~/.proxy_conf ] && [ ! -z ~/.proxy_conf ]
then
  echo "Using http proxy found in .proxy_conf"
  proxy=\`cat ~/.proxy_conf\`
  export {http,https}_proxy="\$proxy"
fi


function proxyon() {
  if [ ! -f ~/.username ] || [ -z ~/.username ]
  then
    echo -n "Enter DOMAIN_NAME Username: "
    read username
    echo \$username > ~/.username
  else
    echo "Using \$HOME/.username for DOMAIN_NAME Username"
    username=\`cat ~/.username\`
  fi
  echo -n "Password for \$username (remember to escape and special chars): "
  read -s password
  echo ""
  if [ ! -z \$password ] && [ ! -z \$username ]
  then
    proxy="http://DOMAIN_NAME\\\${username}:\${password}@my_proxy_host:80"
    #echo "Writing .proxy_conf for future sessions"
    #echo "\$proxy" > ~/.proxy_conf
    export {http,https}_proxy="\$proxy"
  else
    echo "Either username or password was blank - doing nothing"
  fi 
}

function proxyoff() {
  unset {http,https}_proxy
}
EOF


# Setup Ansible
useradd -u 1001 ansible
mkdir /home/ansible/.ssh
cp /vagrant/scripts/known_hosts /home/ansible/.ssh
cp /vagrant/scripts/id_rsa.ansible /etc/ansible
cat > /etc/ansible/ansible.cfg <<EOF
[defaults]
remote_user = ansible
log_path = /etc/ansible/ansible.log
private_key_file = /etc/ansible/id_rsa.ansible
[privilege_escalation]
become=True
become_method=sudo
become_user=root
become_ask_pass=False
[paramiko_connection]
[ssh_connection]
[accelerate]
[selinux]
[colors]
EOF

echo "[virtualbox]
ansible-client" > /etc/ansible/hosts

chmod 700 /home/ansible/.ssh
chmod 400 /home/ansible/.ssh/*
chmod 440 /etc/ansible/id_rsa.ansible
chown ansible. /home/ansible -R
chown ansible. /etc/ansible -R
chmod g+rw /etc/ansible -R

# Setup User (based on DOMAIN_NAME input of command line)
if [ $username != "null" ]
then
  useradd $username
  echo $username > /home/${username}/.username
  #echo "http://DOMAIN_NAME\\${username}:${password}@my_proxy_host:80" > /home/${username}/.proxy_conf
  echo "${username}:${password}" | chpasswd
  echo "## I am root
  $username  ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/users
  chown ${username}. /home/${username}/{.username,.proxy_conf}
  mkdir /home/${username}/.ssh
  if [ -f /vagrant/scripts/id_rsa ]
  then
    cp /vagrant/scripts/id_rsa /home/${username}/.ssh/id_rsa
  fi
  cp /vagrant/scripts/known_hosts /home/${username}/.ssh
  chmod 750 /home/${username}/.ssh
  chmod 660 /home/${username}/.ssh/known_hosts
  chmod 400 /home/${username}/.ssh/id_rsa
  mkdir /home/${username}/.aws
  echo "[default]
aws_access_key_id = PUT_AWSID_HERE
aws_secret_access_key = PUT_AWSSECRETACCESSKEY_HERE" > /home/${username}/.aws/credentials
  echo "[default]
output = text
region = eu-west-1" > /home/${username}/.aws/config
  usermod -G ${username},ansible -g ansible ${username}
  chown ${username}:ansible /home/${username} -R
  #usermod -p ! root
fi

# Reset vagrant user password
usermod -p ! vagrant




# Running list-instances

) > /var/log/vagrant.log 2>&1

# Rest Root password and output
if [ -f /bin/pwgen ]
then
  RED='\033[0;31m'
  NC='\033[0m'
  rootpass=`pwgen -s -1`
  echo "root:$rootpass" | chpasswd
  echo -e "${RED}Take note - root password is now: $rootpass ${NC}"
fi


