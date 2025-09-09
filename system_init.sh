#!/bin/bash
base_dir=`pwd`;cd $base_dir
source env.sh
yum tar install bash-completion wget ipvsadm ipset sysstat conntrack libseccomp -y
DEFAULT_INTERFACE=$(ip route show default | awk '/default/ {print $5}')
IP_ADDRESS=$(ip addr show "$DEFAULT_INTERFACE" | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
HOSTNAME="k8s-$(echo "$IP_ADDRESS" | tr '.' '-')"
hostnamectl set-hostname "$HOSTNAME"
wget -4 "https://private-box.oss-cn-hangzhou.aliyuncs.com/tool/kubernetes/kubernetes-v${k8s_version}-${ARCH}.tar.gz"

tar -zxvf kubernetes-v${k8s_version}-${ARCH}.tar.gz

systemctl disable --now firewalld
setenforce 0
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config
sed -ri 's/.*swap.*/#&/' /etc/fstab
swapoff -a && sysctl -w vm.swappiness=0



ulimit -SHn 65535
cat > /etc/security/limits.conf <<EOF
* soft nofile 655360
* hard nofile 131072
* soft nproc 655350
* hard nproc 655350
* soft memlock unlimited
* hard memlock unlimitedd
EOF

cat > /etc/modules-load.d/ipvs.conf <<EOF 
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
nf_conntrack
ip_tables
ip_set
xt_set
ipt_set
ipt_rpfilter
ipt_REJECT
ipip
overlay
br_netfilter
EOF

systemctl restart systemd-modules-load.service
lsmod | grep -e ip_vs -e nf_conntrack
cat <<EOF > /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
fs.may_detach_mounts = 1
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_watches=89100
fs.file-max=52706963
fs.nr_open=52706963
net.netfilter.nf_conntrack_max=2310720

net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_intvl =15
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_max_orphans = 327680
net.ipv4.tcp_orphan_retries = 3
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.ip_conntrack_max = 65536
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_timestamps = 0
net.core.somaxconn = 16384

net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0
net.ipv6.conf.all.forwarding = 1
EOF

sysctl --system