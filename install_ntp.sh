#!/bin/bash
ntp_install() {
  yum install chrony -y
cat > /etc/chrony.conf << EOF 
pool ntp.aliyun.com iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
keyfile /etc/chrony.keys
leapsectz right/UTC
logdir /var/log/chrony
EOF

  systemctl restart chronyd ; systemctl enable chronyd
  chronyc sources -v
}