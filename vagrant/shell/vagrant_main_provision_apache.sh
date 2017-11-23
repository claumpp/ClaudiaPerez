#!/usr/bin/env bash

# Update Centos 6.7
sudo yum update -y
sudo yum install libselinux
sudo yum install libselinux-python -y

if ! ansible --version | grep ansible;
then
    echo "-> Installing Ansible"
    # Add Ansible Repository & Install Ansible
    cd /tmp
    # RHEL/CentOS 6.7 64-Bit ##
    wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
    wget http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6
    rpm --import /temp/RPM-GPG-KEY-EPEL-6
    rpm -ivh /tmp/epel-release-6-8.noarch.rpm
    yum repolist
    # Update Centos 6.7
    sudo yum update -y
    
    # Install Ansible
    sudo yum install ansible -y
else
        echo "-> Ansible already Installed!"
fi

# Config Lang Centos 6.7
    echo 'LANG=en_US.utf-8' > /etc/environment
    echo 'LC_ALL=en_US.utf-8' > /etc/environment

# Install Ansible Galaxy modules
# To review in furure: http://docs.ansible.com/ansible/galaxy.html#id12
echo "-> Installing Ansibe Galaxy Modules"

roles_list[0]='geerlingguy.ntp'
roles_list[1]='geerlingguy.apache'
roles_list[2]='geerlingguy.php'
roles_list[3]='geerlingguy.firewall'
roles_list[4]='geerlingguy.composer'
roles_list[5]='geerlingguy.repo-remi'
roles_list[6]='geerlingguy.php-versions'


for role_and_version in "${roles_list[@]}"
do
    role_and_version_for_grep="${role_and_version/,/, }"

    if ! sudo ansible-galaxy list | grep -qw "$role_and_version_for_grep";
    then
            echo "Installing ${role_and_version}"
            sudo ansible-galaxy -f install $role_and_version
   else
        echo "Already installed ${role_and_version}"
    fi
done

echo "Disable permanently SE Linux in apache"
sudo setenforce 0;

sed -i --follow-symlinks 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux && cat /etc/sysconfig/selinux

# Execute Ansible
echo "-> Execute Ansible"
ansible-playbook /ansible/playbook_apache.yml -i /ansible/inventories/hosts --connection=local
