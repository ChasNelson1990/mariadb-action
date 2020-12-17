#!/bin/sh

docker_run="docker run"

if [ -n "$INPUT_MYSQL_ROOT_PASSWORD" ]; then
  echo "Root password not empty, use root superuser"

  docker_run="$docker_run -e MYSQL_ROOT_PASSWORD=$INPUT_MYSQL_ROOT_PASSWORD"
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

echo "Wait for mariadb to be up and running"
nc -z localhost 3306
while ! nc -z localhost 3306; do
  nc -z localhost 3306
  sleep 0.25 # wait for 1/4 of the second before check again
done

sh -c "docker ps"

if [ -n "$INPUT_SECONDARY_DATABASE" ]; then
    if [ -n "$INPUT_MYSQL_USER" ]; then
        echo "Use specified secondary database with specified user and password"
        sh -c docker exec -t mariadb:$INPUT_MARIADB_VERSION sh -c "mysql -u $INPUT_MYSQL_USER -p$INPUT_MYSQL_PASSWORD<<<\"CREATE DATABASE IF NOT EXISTS \`$INPUT_SECONDARY_DATABASE\` ;GRANT ALL ON \`$INPUT_SECONDARY_DATABASE\`.* TO '$INPUT_MYSQL_USER'@'%' ;\""
    fi
fi
