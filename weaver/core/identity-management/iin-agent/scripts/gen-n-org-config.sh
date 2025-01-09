#!/bin/bash

# Default values
MODE="deploy"
NUM_NW=2
NUM_ORGS=1
PATH_TO_WEAVER="../../.."
#IMAGE="ghcr.io/hyperledger/cacti-weaver-iin-agent"
IMAGE="cacti-weaver-iin-agent"
DLT_TYPE="fabric"
TLS="false"


while [[ $# -gt 0 ]]; do
  case $1 in
    -m|--mode)
      MODE="$2"
      shift # past argument
      shift # past value
      ;;
    -nw|--num_nw)
      NUM_NW="$2"
      shift # past argument
      shift # past value
      ;;
    -no|--num_orgs)
      shift # past argument
      NUM_ORGS="$1"
      for ii in $(seq 2 $NUM_NW); do
          NUM_ORGS+=" $1"
      done
      shift # past value
      ;;
    -nol|--num_orgs_list)
      shift # past argument
      NUM_ORGS="$1"
      shift # past value
      for ii in $(seq 2 $NUM_NW); do
          NUM_ORGS+=" $1"
          shift # past value
      done
      ;;
    -p|--path-to-weaver)
      PATH_TO_WEAVER="$2"
      shift # past argument
      shift # past value
      ;;
    -o|--options)
      shift # past argument
      IMAGE=${2:-"$IMAGE"}
      DLT_TYPE=${3:-"$DLT_TYPE"}
      TLS=${4:-"$TLS"}
      break
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

echo "ARGS PARSED:"
echo "MODE: $MODE"
echo "NUM NETWORKS: $NUM_NW"
echo "ORGS in each network: $NUM_ORGS"
echo "PATH TO WEAVER: ${PATH_TO_WEAVER}"
echo "IIN Agent IMAGE: $IMAGE"
echo "DLT TYPE: $DLT_TYPE"
echo "TLS Enabled: $TLS"

ROOT_DIR=${PATH_TO_WEAVER}/core/identity-management/iin-agent/docker-testnet

function clean() {
    echo $ROOT_DIR/configs-n
    rm -rf $ROOT_DIR/configs-n
    rm -rf $ROOT_DIR/envs-n
}
function makedirs() {
    mkdir -p $ROOT_DIR/envs-n
    mkdir -p $ROOT_DIR/configs-n
}

function gen_config() {
    NW=$1
    ORG=$2
    TEMPLATE_PATH="${ROOT_DIR}/../src/${DLT_TYPE}-ledger/config.json.template"
    cat $TEMPLATE_PATH \
        | sed "s#Org1#Org${ORG}#g" \
        | sed "s#org1#org${ORG}#g" \
        | sed "s#<path-to-connection-profile>#/opt/iinagent/extra/connection-org${ORG}.docker.json#g" \
        | sed "s#\"walletPath\": \"\"#\"walletPath\": \"/opt/iinagent/extra/wallet-iin-agent\"#g" \
        | sed "s#\"local\": \"true\"#\"local\": \"false\"#g" \
        > $ROOT_DIR/configs-n/config-org${ORG}-n${NW}.json
}

function gen_dnsconfig() {
    echo -e "{" > $ROOT_DIR/configs-n/dnsconfig.json
    nw_id=1
    for n_org in ${NUM_ORGS}; do
        echo -e "\t\"network${nw_id}\": {" >> $ROOT_DIR/configs-n/dnsconfig.json
        for org in $(seq 1 $n_org); do
            gen_org_dns $nw_id $org $n_org | sed "s/^/\t\t/g" >> $ROOT_DIR/configs-n/dnsconfig.json
        done
        sfx=""
        if [ "$nw_id" -ne "$NUM_NW" ]; then sfx=","; fi
        echo -e "\t}$sfx" >> $ROOT_DIR/configs-n/dnsconfig.json
        ((nw_id++))
    done
    echo -e "}" >> $ROOT_DIR/configs-n/dnsconfig.json
}
function gen_org_dns() {
    NW=$1
    ORG=$2
    NW_NUM_ORGS=$3
    TLS_CERT_PATH=${4:-""}
    PORT=$(bash -c "echo \$D_IIN_AGENT_ORG${ORG}_N${NW}_PORT")
    endpoint="iin-agent-Org${ORG}MSP-network${NW}:${PORT}"
    dnsconfig=\
'"Org'$ORG'MSP": {
\t"endpoint": "'$endpoint'",
\t"tls": "'$TLS'",
\t"tlsCACertPath": "'$TLS_CERT_PATH'"
}'
    sfx=""
    if [ "$ORG" -ne "$NW_NUM_ORGS" ]; then sfx=","; fi
    echo -e "$dnsconfig$sfx"
}

function gen_env() {
    NW=$1
    ORG=$2
    TLS_CERT_PATH=${3:-""}
    TLS_KEY_PATH=${4:-""}
    TLS_CRED_DIR=${5:-"../../relay/credentials"}
    PORT=$((9500 + ($ORG-1)*10 + ($NW-1)))
    export "D_IIN_AGENT_ORG${ORG}_N${NW}_PORT"=$PORT
    
    cat $ROOT_DIR/../.env.docker.template \
        | sed "s#^IIN_AGENT_PORT=.*#IIN_AGENT_PORT=${PORT}#g" \
        | sed "s#^IIN_AGENT_TLS=.*#IIN_AGENT_TLS=${TLS}#g" \
        | sed "s#^IIN_AGENT_TLS_CERT_PATH=.*#IIN_AGENT_TLS_CERT_PATH=${TLS_CERT_PATH}#g" \
        | sed "s#^IIN_AGENT_TLS_KEY_PATH=.*#IIN_AGENT_TLS_KEY_PATH=${IIN_AGENT_TLS_KEY_PATH}#g" \
        | sed "s#^MEMBER_ID=.*#MEMBER_ID=Org${ORG}MSP#g" \
        | sed "s#^SECURITY_DOMAIN=.*#SECURITY_DOMAIN=network${NW}#g" \
        | sed "s#^DLT_TYPE=.*#DLT_TYPE=${DLT_TYPE}#g" \
        | sed "s#^CONFIG_PATH=.*#CONFIG_PATH=./docker-testnet/configs-n/config-org${ORG}-n${NW}.json#g" \
        | sed "s#^DNS_CONFIG_PATH=.*#DNS_CONFIG_PATH=./docker-testnet/configs-n/dnsconfig.json#g" \
        | sed "s#^SECURITY_DOMAIN_CONFIG_PATH=.*#SECURITY_DOMAIN_CONFIG_PATH=./docker-testnet/configs-n/security-domain-config.json#g" \
        | sed "s#^DLT_SPECIFIC_DIR=.*#DLT_SPECIFIC_DIR=${PATH_TO_WEAVER}/tests/network-setups/fabric/shared/network${NW}/peerOrganizations/org${ORG}.network${NW}.com#g" \
        | sed "s#^WEAVER_CONTRACT_ID=.*#WEAVER_CONTRACT_ID=interop#g" \
        | sed "s#^SYNC_PERIOD=.*#SYNC_PERIOD=300#g" \
        | sed "s#^AUTO_SYNC=.*#AUTO_SYNC=true#g" \
        | sed "s#^TLS_CREDENTIALS_DIR=.*#TLS_CREDENTIALS_DIR=${TLS_CRED_DIR}#g" \
        | sed "s#^DOCKER_IMAGE_NAME=.*#DOCKER_IMAGE_NAME=${IMAGE}#g" \
        | sed "s#^EXTERNAL_NETWORK=.*#EXTERNAL_NETWORK=network${NW}_net#g" \
        | sed "s#^COMPOSE_PROJECT_NAME=.*#COMPOSE_PROJECT_NAME=network${NW}_org${ORG}#g" \
        | sed "s#^COMPOSE_PROJECT_NETWORK=.*#COMPOSE_PROJECT_NETWORK=net#g" \
        > $ROOT_DIR/envs-n/.env.n${NW}.org${ORG}
}

if [ "$MODE" = "clean" ]; then
    clean
else
    clean
    makedirs

    ## ENV & CONFIG
    nw_id=1
    for n_org in ${NUM_ORGS}; do
        for org in $(seq 1 $n_org); do
        echo Network ID: $nw_id, num orgs: $n_org, org_id: $org
            gen_config $nw_id $org
            gen_env $nw_id $org
        done
        ((nw_id++))
    done

    ## DNS CONFIG
    gen_dnsconfig

    ## SECURITY_DOMAIN_CONFIG
    cp $ROOT_DIR/configs/security-domain-config.json $ROOT_DIR/configs-n/
fi
