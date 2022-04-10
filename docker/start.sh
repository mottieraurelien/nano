#!/bin/bash

########################################################################################################################

# [Requirement : sudo]
loggedUser=$(sudo whoami)
if [ "$loggedUser" != "root" ]; then
    echo "Please log in as root"
    exit 1
else
  unset "$loggedUser"
fi

# [Requirement : docker]
dockerCommand=$(command -v docker)
if [ -z "$dockerCommand" ]
then
  echo "Please install docker"
  exit 1
else
  unset "$dockerCommand"
fi

# [Requirement : docker-compose]
dockerComposeCommand=$(command -v docker-compose)
if [ -z "$dockerComposeCommand" ]
then
  echo "Please install docker-compose"
  exit 1
else
  unset "$dockerComposeCommand"
fi

########################################################################################################################

# Backup the default docker service configuration :
cp /etc/docker/daemon.json /etc/docker/daemon.json.backup."$(date +"%Y-%m-%d")"

# Update the docker service configuration /etc/docker/daemon.json :
echo "{\"data-root\": \"/mnt/SSD/ix-applications/docker\", \"exec-opts\": [\"native.cgroupdriver=cgroupfs\"]}" > /etc/docker/daemon.json

# Reload the docker service configuration :
systemctl daemon-reload

# Restart the docker service :
systemctl restart docker

# Grant execution rights on docker-compose (root cannot execute any docker-compose by default on Truenas SCALE) :
chmod +x /usr/bin/docker-compose

# Set a few environment variables with default values (the RSA keys that constitutes our SSL certificate) :
environmentSettings=~/.zshrc
if [ ! -f "$environmentSettings" ]; then
  touch $environmentSettings
else
  cp $environmentSettings $environmentSettings.backup."$(date +"%Y-%m-%d")"
fi
chmod +x $environmentSettings
echo "# SSL certificate :" >> $environmentSettings
rsaKeysPath=/etc/certificates
echo "export RSA_KEYS_PATH=$rsaKeysPath" >> $environmentSettings
echo "export PATH=\$PATH:\$RSA_KEYS_PATH" >> $environmentSettings
rsaPublicKeyFilename=$(ls $rsaKeysPath/*.crt)
echo "export RSA_PUBLIC_KEY_FILENAME=$rsaPublicKeyFilename" >> $environmentSettings
echo "export PATH=\$PATH:\$RSA_PUBLIC_KEY_FILENAME" >> $environmentSettings
rsaPrivateKeyFilename=$(ls $rsaKeysPath/*.key)
echo "export RSA_PRIVATE_KEY_FILENAME=$rsaPrivateKeyFilename" >> $environmentSettings
echo "export PATH=\$PATH:\$RSA_PRIVATE_KEY_FILENAME" >> $environmentSettings
$environmentSettings
# These values may be wrong, please update them if needed (these are the default ones for Truenas SCALE).

# All good!
exit 0