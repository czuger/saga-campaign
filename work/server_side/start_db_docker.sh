#!/usr/bin/env bash

if [[ -z "$1" ]]
  then
    echo 'Provide the database password as an argument'
    exit
fi

docker run --name postgres10 -e POSTGRES_PASSWORD=$1 -v /tmp/pg_10_socket/:/var/run/postgresql -d postgres:10.12-alpine