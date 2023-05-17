#!/bin/bash

# Ajuste dos privilégios
sudo chown -R hduser:hduser /home/hduser/jdk
sudo chown -R hduser:hduser /home/hduser/hadoop

# Restart do serviço ssh
#sudo service ssh restart
#sudo systemctl restart sshd