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
    yum -y install openssh-server openssh-clients initscripts

# Cria usuário para a instalação do Hadoop e define a senha
RUN useradd -m hduser && echo "hduser:hduser" | chpasswd
# Adiciona o usuário criado ao grupo padrão wheel do super usuário do CentOS
RUN usermod -aG wheel hduser
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
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && chmod 0600 ~/.ssh/authorized_keys

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

# Pastas para os arquivos do NameNode
RUN mkdir /home/hduser/hdfs
RUN mkdir /home/hduser/hdfs/namenode

# Variáveis de ambiente
RUN echo "PATH=$PATH:$HADOOP_HOME/bin" >> ~/.bash_profile
RUN echo "PATH=$PATH:$HADOOP_HOME/sbin" >> ~/.bash_profile

######### HADOOP 3.3.5 (BINÁRIOS E VARIÁVEIS DE AMBIENTE) - FIM #########

# Copia os arquivos de configuração
ADD ./config-files/hadoop-env.sh $HADOOP_HOME/etc/hadoop/
ADD ./config-files/core-site.xml $HADOOP_HOME/etc/hadoop/
ADD ./config-files/hdfs-site.xml $HADOOP_HOME/etc/hadoop/
ADD ./config-files/workers $HADOOP_HOME/etc/hadoop/

# Adiciona scripts
COPY script.sh /home/hduser
RUN sudo chmod +x /home/hduser/script.sh
# Executa script
RUN /bin/bash -c '/home/hduser/script.sh'

# Portas que poderão ser usadas
EXPOSE 50070 50075 50010 50020 50090 8020 9000 9864 9870 8030 8031 8032 8033 8040 8042 22

# Volta para usuário root, pois alguns processos são iniciados através dele
USER root
# setup new root password
RUN echo root:root | chpasswd

# Permite usar systemctl dentro do container
CMD ["/usr/sbin/init"]