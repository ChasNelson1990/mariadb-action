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

if [ -n "$INPUT_MYSQL_DATABASE" ]; then
  echo "Use specified primary database"

  docker_run="$docker_run -e MYSQL_DATABASE=$INPUT_MYSQL_DATABASE"
fi

echo "Use specified versiob and ports"
docker_run="$docker_run -d -p $INPUT_HOST_PORT:$INPUT_CONTAINER_PORT mariadb:$INPUT_MARIADB_VERSION --port=$INPUT_CONTAINER_PORT"

echo "Use specified character set and collation"
docker_run="$docker_run --character-set-server=$INPUT_CHARACTER_SET_SERVER --collation-server=$INPUT_COLLATION_SERVER"

if [ -n "$INPUT_MYSQL_DATABASE" ]; then
    echo "Use specified secondary database"
    docker_run = "$docker_run <<<\"CREATE DATABASE IF NOT EXISTS \`test_$INPUT_MYSQL_DATABASE\` ;"
    if [ -n "$INPUT_MYSQL_USER" ]; then
        echo "And asign to specified user"
        docker_run = "$docker_run GRANT ALL ON \`test_${INPUT_MYSQL_DATABASE//_/\\_}\`.* TO '$INPUT_MYSQL_USER'@'%' ;\""
    else
        docker_run = "$docker_run\""
    fi
fi

echo docker_run

sh -c "$docker_run"
