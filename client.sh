# Setup Ansible user
useradd -u 1001 ansible
mkdir /home/ansible/.ssh
cp /vagrant/scripts/authorized_keys /home/ansible/.ssh/
chmod 700 /home/ansible/.ssh
chmod 640 /home/ansible/.ssh/authorized_keys
chown ansible. /home/ansible/.ssh -R
echo "## Ansible is a DJ
ansible  ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/ansible

cp /vagrant/scripts/client_hostkeys/* /etc/ssh
chmod 640 /etc/ssh/*key
chmod 644 /etc/ssh/*pub
systemctl restart sshd