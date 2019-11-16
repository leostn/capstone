
curl -sS -o /etc/yum.repos.d/docker-ce.repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

# 安装一些常用软件
yum install -y net-tools tree telnet vim wget

# 禁用 SELinux
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# 禁用服务器 swap 分区
swapoff -a
sed -i '/swap/s/^/#/g' /etc/fstab

# 将桥接的 IPv4 流量传递到 iptables 的链
cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

# 关闭网络防火墙
systemctl stop firewalld
systemctl disable firewalld

# 安装 docker 服务
yum install --nogpgcheck -y yum-utils device-mapper-persistent-data lvm2
yum install --nogpgcheck -y docker-ce
systemctl enable docker && systemctl start docker

# 安装 kubelet 和 kubeadm
yum install -y kubelet-1.13.5 kubeadm-1.13.5 kubectl-1.13.5 --nogpgcheck
systemctl enable kubelet