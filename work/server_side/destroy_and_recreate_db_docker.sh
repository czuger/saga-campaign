#!/usr/bin/env bash

docker pull postgres:10.12-alpine

docker stop postgres10
docker rm postgres10