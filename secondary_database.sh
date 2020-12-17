#!/bin/bash

# Creates a custom database and user if specified
if [ -n "$INPUT_SECONDARY_DATABASE" ]; then
    mysql_note "Use specified secondary database"

    if [ -n "$INPUT_ROOT_PASSWORD" ]; then
        mysql_note "...with root user and root password"

        docker_process_sql --database=mysql <<<"CREATE DATABASE IF NOT EXISTS \`$INPUT_SECONDARY_DATABASE\` ;"
        docker_process_sql --database=mysql <<<"GRANT ALL ON \`${INPUT_SECONDARY_DATABASE}\`.* TO 'root'@'%' ;"
    elif [ -n "$INPUT_MYSQL_USER" ]; then
        mysql_note "...with specified user and password"

        docker_process_sql --database=mysql <<<"CREATE DATABASE IF NOT EXISTS \`$INPUT_SECONDARY_DATABASE\` ;"
        docker_process_sql --database=mysql <<<"GRANT ALL ON \`${INPUT_SECONDARY_DATABASE}\`.* TO 'INPUT_MYSQL_USER'@'%' ;"
    fi
fi
