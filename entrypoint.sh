#!/bin/sh

docker_run="docker run -v secondary_database.sh:/docker-entrypoint-initdb.d/secondary_database.sh"

if [ -n "$INPUT_ROOT_PASSWORD" ]; then
  echo "Root password not empty, use root superuser"

  docker_run="$docker_run -e ROOT_PASSWORD=$INPUT_ROOT_PASSWORD"
elif [ -n "$INPUT_MYSQL_USER" ]; then
  if [ -z "$INPUT_MYSQL_PASSWORD" ]; then
    echo "The mysql password must not be empty when mysql user exists"
    exit 1
  fi

  echo "Use specified user and password"

  docker_run="$docker_run -e MYSQL_RANDOM_ROOT_PASSWORD=true -e MYSQL_USER=$INPUT_MYSQL_USER -e MYSQL_PASSWORD=$INPUT_MYSQL_PASSWORD"
else
  echo "Using empty password for root"

  docker_run="$docker_run -e MYSQL_ALLOW_EMPTY_PASSWORD=true"
fi

if [ -n "$INPUT_PRIMARY_DATABASE" ]; then
  echo "Use specified primary database"

  docker_run="$docker_run -e MYSQL_DATABASE=$INPUT_PRIMARY_DATABASE"
fi

echo "Use specified version and ports"
docker_run="$docker_run -d -p $INPUT_HOST_PORT:$INPUT_CONTAINER_PORT mariadb:$INPUT_MARIADB_VERSION --port=$INPUT_CONTAINER_PORT"

echo "Use specified character set and collation"
docker_run="$docker_run --character-set-server=$INPUT_CHARACTER_SET_SERVER --collation-server=$INPUT_COLLATION_SERVER"

sh -c "$docker_run"

sleep 60
sh -c "docker ps"  # useful for debugging
