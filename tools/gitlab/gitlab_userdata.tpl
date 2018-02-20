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
#gitlab-ctl start

#apt-get install python
#apt-get install pip
#pip install requests

#call python script to setup user & create token
#TOKEN="stuff"
#URL="http://127.0.0.1/api/v4"

#PROJECT="test-project"

#curl -X POST --header "Private-Token: $TOKEN" $URL/projects?name=$PROJECT
