# Configura acesso a internet
sudo echo 'DNS1=8.8.8.8' >> /etc/sysconfig/network-scripts/ifcfg-eth1
sudo echo 'DNS2=8.8.4.4' >> /etc/sysconfig/network-scripts/ifcfg-eth1
sudo systemctl restart NetworkManager
# Desativando firewall
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo systemctl mask --now firewalld
# Desativando Selinux
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
sudo setenforce 0
# Instalação do memcached. É utilizado pelo kubectl
sudo yum install memcached -y
# Instalação do Docker
curl -fsSL https://get.docker.com/ | sh
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker vagrant
newgrp docker
sudo curl https://raw.githubusercontent.com/docker/machine/v0.16.0/contrib/completion/bash/docker-machine.bash -o /etc/bash_completion.d/docker-machine
# Tirando limitador do SO para execução do Docker sem erro durante criação dos containers
sudo sed -i 's/dockerd -H/dockerd --default-ulimit nofile=65536:65536 -H/g' /usr/lib/systemd/system/docker.service
sudo systemctl daemon-reload
sudo systemctl restart docker