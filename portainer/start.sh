#!/usr/bin/zsh

########################################################################################################################

# [Requirement : RSA keys folder]
rsaKeysPath=$(printenv RSA_KEYS_FILEPATH)
if [ -z "$rsaKeysPath" ]
then
  echo "Please set the environment variable RSA_KEYS_FILEPATH with the RSA keys filepath"
  exit 1
fi
if [ ! -d "$rsaKeysPath" ]; then
  echo "$rsaKeysPath does not exist, please set the path to the environment variable RSA_KEYS_FILEPATH"
  exit 1
fi

# [Requirement : Public RSA key filename]
rsaPublicKeyFilename=$(printenv RSA_PUBLIC_KEY_FILENAME)
if [ -z "$rsaPublicKeyFilename" ]
then
  echo "Please set the environment variable RSA_PUBLIC_KEY_FILENAME with the public RSA key filename"
  exit 1
fi
if [ ! -f "$rsaKeysPath/$rsaPublicKeyFilename" ]; then
  echo "$rsaKeysPath/$rsaPublicKeyFilename does not exist, please set the filename to the environment variable RSA_PUBLIC_KEY_FILENAME"
  exit 1
fi

# [Requirement : Private RSA key filename]
rsaPrivateKeyFilename=$(printenv RSA_PRIVATE_KEY_FILENAME)
if [ -z "$rsaPrivateKeyFilename" ]
then
  echo "Please set the environment variable RSA_PRIVATE_KEY_FILENAME with the private RSA key filename"
  exit 1
fi
if [ ! -f "$rsaKeysPath/$rsaPrivateKeyFilename" ]; then
  echo "$rsaKeysPath/$rsaPrivateKeyFilename does not exist, please set the filename to the environment variable RSA_PRIVATE_KEY_FILENAME"
  exit 1
fi

########################################################################################################################

# Stop the (potential) existing Portainer container :
docker stop portainer

# Remove this obsolete and useless Portainer container :
docker container prune -f

# Clean up a lot of useless stuff related to Docker :
docker system prune -a --volumes -f

# Run Portainer in a new container (volume will be created automatically) :
docker-compose -f "$(dirname "$0")/docker-compose-portainer.yml" up -d

# Perform health check to make sure we can access Portainer from the local network :
http_status=$(curl --max-time 5 -s -o /dev/null -I -w "%{http_code}" "http://localhost:9000/")
if [ "$http_status" != "200" ]; then
    echo "For some reasons, Portainer is not up and accessible. Please verify the container logs by running the command : docker logs portainer"
    exit 1
fi

# Provide useful information :
echo "Portainer is accessible from your local network with http://truenas_private_ip:9000"
echo "Please open/forward 9443 if you want to get access to Portainer from the outside through HTTPS"

# All good!
exit 0