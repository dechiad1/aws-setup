#!/bin/bash
apt-get update
apt-get install -y curl openssh-server ca-certificates

cd /tmp
curl -LO https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh
bash /tmp/script.deb.sh
apt-get install -y gitlab-ce

SRC="gitlab.example.com"
DST=$(hostname -i)
sed -i "s/$SRC/$DST/g" /etc/gitlab/gitlab.rb

gitlab-ctl reconfigure

#add method to wait for gitlab setup to complete
#execute python script on localhost
