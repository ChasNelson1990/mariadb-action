#!/bin/sh

docker_run="docker run"

echo "$MYSQL_ROOT_PASSWORD"
echo "$MYSQL_USER"
echo "$MYSQL_PASSWORD"
echo "$PRIMARY_DATABASE"
echo "$SECONDARY_DATABASE"

if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
  echo "Root password not empty, use root superuser"

  docker_run="$docker_run -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD"
elif [ -n "$MYSQL_USER" ]; then
  if [ -z "$MYSQL_PASSWORD" ]; then
    echo "The mysql password must not be empty when mysql user exists"
    exit 1
  fi

  echo "Use specified user and password"

  docker_run="$docker_run -e MYSQL_RANDOM_ROOT_PASSWORD=true -e MYSQL_USER=$MYSQL_USER -e MYSQL_PASSWORD=$MYSQL_PASSWORD"
else
  echo "Using empty password for root"

  docker_run="$docker_run -e MYSQL_ALLOW_EMPTY_PASSWORD=true"
fi

if [ -n "$PRIMARY_DATABASE" ]; then
  echo "Use specified primary database"

  docker_run="$docker_run -e MYSQL_DATABASE=$PRIMARY_DATABASE"
fi

echo "Use specified version and ports"
docker_run="$docker_run -d -p $HOST_PORT:$CONTAINER_PORT mariadb:$MARIADB_VERSION --port=$CONTAINER_PORT"

echo "Use specified character set and collation"
docker_run="$docker_run --character-set-server=$CHARACTER_SET_SERVER --collation-server=$COLLATION_SERVER"

sh -c "$docker_run"

# echo "Wait for mariadb to be up and running"
# while ! nc -z 0.0.0.0 3306 </dev/null; do
#   sh -c "docker ps"
#   sleep 1 # wait for 1 of the second before check again
# done

sleep 10

echo "before"
if [ -n "$SECONDARY_DATABASE" ]; then
    if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
        echo "Use specified secondary database with root user and root password"

        sh -c docker exec -t mariadb:$MARIADB_VERSION sh -c "mysql -u root -p$MYSQL_ROOT_PASSWORD<<<\"CREATE DATABASE IF NOT EXISTS \`$SECONDARY_DATABASE\` ;GRANT ALL ON \`$SECONDARY_DATABASE\`.* TO 'root'@'%' ;\""
    elif [ -n "$MYSQL_USER" ]; then
        echo "Use specified secondary database with specified user and password"

        sh -c docker exec -t mariadb:$MARIADB_VERSION sh -c "mysql -u $MYSQL_USER -p$MYSQL_PASSWORD<<<\"CREATE DATABASE IF NOT EXISTS \`$SECONDARY_DATABASE\` ;GRANT ALL ON \`$SECONDARY_DATABASE\`.* TO '$MYSQL_USER'@'%' ;\""
    fi
fi

echo "after"
