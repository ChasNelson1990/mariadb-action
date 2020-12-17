#!/bin/sh

docker_run="docker run"

echo "$INPUT_ROOT_PASSWORD"
echo "$INPUT_PRIMARY_DATABASE"
echo "$INPUT_SECONDARY_DATABASE"

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

sh -c "$docker_run --name mariadb"

# echo "Wait for mariadb to be up and running"
# while ! nc -z 0.0.0.0 3306 </dev/null; do
#   sh -c "docker ps"
#   sleep 1 # wait for 1 of the second before check again
# done

sleep 10

echo "before"
if [ -n "$INPUT_SECONDARY_DATABASE" ]; then
    echo "Use specified secondary database"

    database_add="docker exec mariadb -e mariadb_name=$INPUT_SECONDARY_DATABASE"
    if [ -n "$INPUT_ROOT_PASSWORD" ]; then
        echo "...with root user and root password"

        database_add="$database_add -e mariadb_user=root -e mariadb_pass=$INPUT_ROOT_PASSWORD"
    elif [ -n "$INPUT_MYSQL_USER" ]; then
        echo "...with specified user and password"

        database_add="$database_add -e mariadb_user=$INPUT_MYSQL_USER -e mariadb_pass=$INPUT_MYSQL_PASSWORD"
    fi
    
    echo $database_add
    sh -c $database_add
fi

echo "after"
