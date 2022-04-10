#!/usr/bin/zsh

########################################################################################################################

# [Requirement : sudo]
if [ "$(sudo whoami)" != "root" ]; then
    echo "Please log in as root"
    exit 1
fi

# [Requirement : docker]
if [ -z "$(command -v docker)" ]
then
  echo "Please install docker"
  exit 1
fi

# [Requirement : docker-compose]
if [ -z "$(command -v docker-compose)" ]
then
  echo "Please install docker-compose"
  exit 1
fi

# [Requirement : unique SSL certificate]
# TODO : make sure there is only one file *.crt et only one file *.key in /etc/certificates (the one used by Truenas)

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
chmod +x ~/.zshrc
echo "# SSL certificate :" >> ~/.zshrc
rsaKeysPath=/etc/certificates
echo "export RSA_KEYS_FILEPATH=$rsaKeysPath" >> ~/.zshrc
rsaPublicKeyFilepath=$(ls $rsaKeysPath/*.crt)
rsaPublicKeyFilename=$(basename "$rsaPublicKeyFilepath")
echo "export RSA_PUBLIC_KEY_FILENAME=$rsaPublicKeyFilename" >> ~/.zshrc
rsaPrivateKeyFilepath=$(ls $rsaKeysPath/*.key)
rsaPrivateKeyFilename=$(basename "$rsaPrivateKeyFilepath")
echo "export RSA_PRIVATE_KEY_FILENAME=$rsaPrivateKeyFilename" >> ~/.zshrc

# Reload the session properties :
exec zsh && exec bash

# All good!
exit 0