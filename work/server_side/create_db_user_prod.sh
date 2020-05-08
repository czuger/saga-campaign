#!/usr/bin/env bash

if [[ -z "$1" ]]
  then
    echo 'Provide the saga_campaign password as an argument'
    exit
fi

psql -p 5434 -h localhost -U postgres -c "CREATE ROLE saga_campaign WITH LOGIN NOSUPERUSER NOCREATEROLE INHERIT NOREPLICATION CONNECTION LIMIT -1 PASSWORD '$1'";
psql -p 5434 -h localhost -U postgres -c "CREATE DATABASE saga_campaign_prod OWNER saga_campaign;"