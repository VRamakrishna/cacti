#!/bin/bash

MODE=${1:-"up"}
PROFILES=${2:-"1-node"}
NUM_NW=${3:-"2"}

NUM_ORGS=${PROFILES:0:1}

if [ "$MODE" = "up" ]; then
    docker network create iin || true
    for ii in $(seq 1 $NUM_NW); do
        for org in $(seq 1 $NUM_ORGS); do
            . docker-testnet/envs-n/.env.n${ii}.org${org}
        	chmod 777 ${DLT_SPECIFIC_DIR}
            docker compose --env-file docker-testnet/envs-n/.env.n${ii}.org${org} up -d
        done
    done
else
    for ii in $(seq 1 $NUM_NW); do
        for org in $(seq 1 $NUM_ORGS); do
            docker compose --env-file docker-testnet/envs-n/.env.n${ii}.org${org} down
        done
    done
    docker network rm iin || true
fi