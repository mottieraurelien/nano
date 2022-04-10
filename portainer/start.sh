#!/usr/bin/zsh

########################################################################################################################

# [Requirement : Folder that contains the RSA keys]
rsaKeysPath=$(printenv RSA_KEYS_PATH)
if [ -z "$rsaKeysPath" ]
then
  echo "Please set the environment variable RSA_KEYS_PATH with the path of the folder that contains the RSA keys"
  exit 1
fi
if [ ! -f "$rsaKeysPath" ]; then
  echo "$rsaKeysPath does not exist. Please set the right folder path to the environment variable RSA_KEYS_PATH"
  exit 1
fi

# [Requirement : Public RSA key]
rsaPublicKeyFilename=$(printenv RSA_PUBLIC_KEY_FILENAME)
if [ -z "$rsaPublicKeyFilename" ]
then
  echo "Please set the environment variable RSA_PUBLIC_KEY_FILENAME with the public RSA key filename"
  exit 1
fi
rsaPublicKeyFilepath="${rsaKeysPath}${rsaPublicKeyFilename}"
if [ ! -f "$rsaPublicKeyFilepath" ]; then
  echo "$rsaPublicKeyFilepath does not exist. Please set the filename path to the environment variable RSA_PUBLIC_KEY_FILENAME"
  exit 1
fi

# [Requirement : Private RSA key]
rsaPrivateKeyFilename=$(printenv RSA_PRIVATE_KEY_FILENAME)
if [ -z "$rsaPrivateKeyFilename" ]
then
  echo "Please set the environment variable RSA_PRIVATE_KEY_FILENAME with the private RSA key filename"
  exit 1
fi
rsaPrivateKeyFilepath="${rsaKeysPath}${rsaPrivateKeyFilename}"
if [ ! -f "$rsaPrivateKeyFilepath" ]; then
  echo "$rsaPrivateKeyFilepath does not exist. Please set the filename path to the environment variable RSA_PRIVATE_KEY_FILENAME"
  exit 1
fi

########################################################################################################################

# Stop the (potential) existing Portainer container :
docker stop portainer

# Remove this obsolete and useless Portainer container :
docker container prune -f

# Clean up a lot of useless stuff related to Docker :
docker system prune -a --volumes -f

# Defines the RSA keys paths so that Portainer can automatically use them when firing up :
#     command: --ssl --sslcert=/certs/portainer.crt --sslkey=/certs/portainer.key
docker secret create portainer.sslcert "$rsaPublicKeyFilepath"
docker secret create portainer.sslkey "$rsaPrivateKeyFilepath"

# Run Portainer in a new container (volume will be created automatically) :
docker compose -f ./docker-compose-portainer.yml

# Perform health check to make sure we can access Portainer from the local network :
http_status=$(curl --max-time 0.5 -s -o /dev/null -I -w "%{http_code}" "http://localhost:9000/")
if [ "$http_status" != "200" ]; then
    echo "For some reasons, Portainer is not up and accessible. Please verify the container logs by running the command : docker logs portainer"
    exit 1
fi

# Provide useful information :
echo "Portainer is accessible from your local network with http://truenas_private_ip:9000"
echo "Please open/forward 9443 if you want to get access to Portainer from the outside through HTTPS"

# All good!
exit 0