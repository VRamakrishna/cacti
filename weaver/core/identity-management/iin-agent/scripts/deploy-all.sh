#!/bin/bash

MODE=${1:-"up"}
PROFILES=${2:-"1-node"}
NUM_NW=${3:-"2"}

NUM_ORGS="$( echo $PROFILES | sed -E 's/^([^-]*).*$/\1/g' )"
echo "Starting iin-agents with $NUM_ORGS nodes in 2 secs..."

env_dir="envs"
if [ "$NUM_ORGS" -gt 2 ]; then
    env_dir="envs-n"
elif [ "$NUM_ORGS" = "2" ]; then
    sed -i'.scriptbak' -e "s#^DNS_CONFIG_PATH=.*#DNS_CONFIG_PATH=./docker-testnet/configs/dnsconfig-2-nodes.json#g" docker-testnet/envs/.env.n?.org?
    rm -rf docker-testnet/envs/.*.scriptbak
else
    sed -i'.scriptbak' -e "s#^DNS_CONFIG_PATH=.*#DNS_CONFIG_PATH=./docker-testnet/configs/dnsconfig.json#g" docker-testnet/envs/.env.n?.org?
    rm -rf docker-testnet/envs/.*.scriptbak
fi

if [ "$MODE" = "up" ]; then
    docker network create iin || true
    for ii in $(seq 1 $NUM_NW); do
        for org in $(seq 1 $NUM_ORGS); do
            . docker-testnet/${env_dir}/.env.n${ii}.org${org}
            chmod 777 ${DLT_SPECIFIC_DIR}
            docker compose --env-file docker-testnet/${env_dir}/.env.n${ii}.org${org} up -d
        done
    done
else
    for ii in $(seq 1 $NUM_NW); do
        for org in $(seq 1 $NUM_ORGS); do
            docker compose --env-file docker-testnet/${env_dir}/.env.n${ii}.org${org} down
        done
    done
    docker network rm iin || true
fi
