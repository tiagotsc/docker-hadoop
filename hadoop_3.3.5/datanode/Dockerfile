FROM centos:7
ENV container docker

# Remover alguns arquivos para ativar o systemd
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]

RUN yum clean all && \
    yum update -y && yum install -y \
    python3 \
    rsync \
    net-tools \
    vim \
    nano \
    sudo \
    sshpass \
    wget \
    make \
    yum install -y autoconf automake libtool \
    yum install -y gcc gcc-c++ cmake \
    yum install -y zlib-devel \
    yum install -y openssl-devel \
    yum install -y snappy snappy-devel \
    yum install -y bzip2 bzip2-devel \
    yum -y install openssh-server openssh-clients initscripts

# Cria grupo hadoop
RUN groupadd hadoop
# Cria usuário para a instalação do Hadoop e define a senha
RUN useradd -m hduser && echo "hduser:hduser" | chpasswd
# Adiciona o usuário criado ao grupo padrão wheel do super usuário do CentOS
RUN usermod -aG wheel hduser
# Adiciona usuário ao grupo hadoop
RUN usermod -aG hadoop hduser
# Transforma o usuário criado em um super usuário
RUN echo "hduser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Copia o arquivo de configuração do ssh
# StrictHostKeyChecking no = Desabilita pergunta / checagem de confiança de chave
# UserKnownHostsFile /dev/null = Não salva o nome do host, assim caso mude não corre o risco de fazer a pergunta de checagem
RUN echo '        StrictHostKeyChecking no' >> /etc/ssh/ssh_config
RUN echo '        UserKnownHostsFile=/dev/null' >> /etc/ssh/ssh_config
#ADD ./config-files/ssh_config /etc/ssh/ssh_config

# Muda o usuário
USER hduser

# SSH - Configuração
RUN mkdir /home/hduser/.ssh && touch /home/hduser/.ssh/authorized_keys && chmod 600 /home/hduser/.ssh/authorized_keys

# Usuário de trabalho
ENV HDFS_NAMENODE_USER=hduser
ENV HDFS_DATANODE_USER=hduser
ENV HDFS_SECONDARYNAMENODE_USER=hduser
ENV YARN_RESOURCEMANAGER_USER=hduser
ENV YARN_NODEMANAGER_USER=hduser

######### JAVA JDK 1.8 (BINÁRIOS E VARIÁVEIS DE AMBIENTE) - INÍCIO #########

# Copia os binários do JDK
ADD ./binarios/jdk /home/hduser/jdk

# Variáveis de ambiente JDK
ENV JAVA_HOME=/home/hduser/jdk
ENV PATH=$PATH:$JAVA_HOME:$JAVA_HOME/bin

# Variáveis de ambiente
RUN echo "PATH=$PATH:$JAVA_HOME/bin" >> ~/.bash_profile

######### JAVA JDK 1.8 (BINÁRIOS E VARIÁVEIS DE AMBIENTE) - FIM #########

######### HADOOP 3.3.5 (BINÁRIOS E VARIÁVEIS DE AMBIENTE) - INÍCIO #########

# Copia os binários do Hadoop
ADD ./binarios/hadoop /home/hduser/hadoop

# Variáveis de ambiente do Hadoop
ENV HADOOP_HOME=/home/hduser/hadoop
ENV PATH=$PATH:$HADOOP_HOME
ENV PATH=$PATH:$HADOOP_HOME/bin
ENV PATH=$PATH:$HADOOP_HOME/sbin

# Variáveis de ambiente
RUN echo "PATH=$PATH:$HADOOP_HOME/bin" >> ~/.bash_profile
RUN echo "PATH=$PATH:$HADOOP_HOME/sbin" >> ~/.bash_profile

######### HADOOP 3.3.5 (BINÁRIOS E VARIÁVEIS DE AMBIENTE) - FIM #########

RUN mkdir /home/hduser/hdfs
RUN mkdir /home/hduser/hdfs/datanode

# Copia os arquivos de configuração
ADD ./config-files/hadoop-env.sh $HADOOP_HOME/etc/hadoop/
ADD ./config-files/core-site.xml $HADOOP_HOME/etc/hadoop/
ADD ./config-files/hdfs-site.xml $HADOOP_HOME/etc/hadoop/
ADD ./config-files/yarn-site.xml $HADOOP_HOME/etc/hadoop/
ADD ./config-files/mapred-site.xml $HADOOP_HOME/etc/hadoop/
ADD ./config-files/workers $HADOOP_HOME/etc/hadoop/

# Adiciona scripts
COPY script.sh /home/hduser
RUN sudo chmod +x /home/hduser/script.sh
# Executa script
RUN /bin/bash -c '/home/hduser/script.sh'

# Portas que poderão ser usadas
EXPOSE 22 9864 2181 8485 2888-3888 1019 1022 88 8032 8042

# Volta para usuário root, pois alguns processos são iniciados através dele
USER root
# setup new root password
RUN echo root:root | chpasswd

# Muda configuração do sistema
RUN echo '* soft nofile 102400' >> /etc/security/limits.conf
RUN echo '* hard nofile 409600' >> /etc/security/limits.conf
RUN echo 'session    required     /lib64/security/pam_limits.so' >> /etc/pam.d/login

# Instalação openssl version 1.1.1 (É utilizado pelo Yarn e MapReduce)
RUN wget https://www.openssl.org/source/openssl-1.1.1h.tar.gz 
RUN tar -zxf openssl-1.1.1h.tar.gz
RUN cd openssl-1.1.1h && ./config && make && make install
RUN ln -s /usr/local/lib64/libssl.so.1.1 /usr/lib64/libssl.so.1.1
RUN ln -s /usr/local/lib64/libcrypto.so.1.1 /usr/lib64/libcrypto.so.1.1
RUN rm -Rf openssl-1.1.1h
RUN rm -f openssl-1.1.1h.tar.gz
# Teste openssl 1.1.1 com comando: openssl version

CMD ["/usr/sbin/init"]
