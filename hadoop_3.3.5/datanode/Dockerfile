FROM ubuntu:latest
ENV container=docker

# Updates e instalações
RUN \
  apt-get update && apt-get install -y \
  openssh-server \
  python3 \
  rsync \
  sudo \
  arp-scan \
  net-tools \
  iputils-ping \
  vim \
  && apt-get clean

# Cria grupo hadoop
RUN groupadd hadoop
# Cria usuário para a instalação do Hadoop
RUN useradd -m hduser && echo "hduser:hadoop" | chpasswd && adduser hduser sudo && echo "hduser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && cd /usr/bin/ && sudo ln -s python3 python

# Adcionando usuários de serviços
RUN useradd hdfs -g hadoop
RUN useradd yarn -g hadoop
RUN useradd jhs -g hadoop
RUN useradd HTTP -g hadoop
RUN useradd hive -g hadoop
RUN useradd mapred -g hadoop

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
