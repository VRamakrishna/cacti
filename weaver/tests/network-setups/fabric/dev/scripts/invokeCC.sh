#!/bin/bash

# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0

CHANNEL_NAME="$1"
CC_SRC_LANGUAGE="$2"
VERSION="$3"
DELAY="$4"
MAX_RETRY="$5"
VERBOSE="$6"
CC_CHAIN_CODE="$7"
NW_PATH="$8"
NUM_ORGS="$9"
ORD_P=${10}
APP_R=${11}
NW_NAME=${12}
PROFILE="${13}"
TX_MODE="${14}"
TX_TARGET_ORG="${15}"

: ${CHANNEL_NAME:="mychannel"}
: ${CC_SRC_LANGUAGE:="golang"}
: ${VERSION:="1"}
: ${DELAY:="3"}
: ${MAX_RETRY:="5"}
: ${VERBOSE:="false"}

CC_SRC_LANGUAGE=`echo "$CC_SRC_LANGUAGE" | tr [:upper:] [:lower:]`
CC_CHAIN_CODE=`echo "$CC_CHAIN_CODE" | tr [:upper:] [:lower:]`

CC_END_POLICY="--signature-policy AND('Org1MSP.member')"
if [ "$PROFILE" != "1-node" ]; then
	OrgsMSPMembers="("
	for ii in $(seq 1 ${NUM_ORGS}); do
		OrgsMSPMembers+="'Org${ii}MSP.member'"
		if [ $ii -ne $NUM_ORGS ]; then
			OrgsMSPMembers+=","
		fi
	done
	OrgsMSPMembers+=")"

	echo "Chaincode = "$CC_CHAIN_CODE
	if [ "$CC_CHAIN_CODE" = "interop" -o "$CC_CHAIN_CODE" = "privateassettransfer" ]; then
		echo "In OR"
		CC_END_POLICY="--signature-policy OR${OrgsMSPMembers}"
	else
		echo "In AND"
		CC_END_POLICY="--signature-policy AND${OrgsMSPMembers}"
	fi
fi
echo "Endorsement policy = "$CC_END_POLICY

echo " - CHANNEL_NAME           :      ${CHANNEL_NAME}"
echo " - CC_SRC_LANGUAGE        :      ${CC_SRC_LANGUAGE}"
echo " - DELAY                  :      ${DELAY}"
echo " - MAX_RETRY              :      ${MAX_RETRY}"
echo " - VERBOSE                :      ${VERBOSE}"
echo " - CC_CHAIN_CODE          :      ${CC_CHAIN_CODE}"
echo " - NW_PATH                :      ${NW_PATH}"
echo " - NUM_ORGS               :      ${NUM_ORGS}"
echo " - ORD_PORT               :      ${ORD_P}"
echo " - APP_ROOT               :      ${APP_R}"
echo " - NW_NAME                :      ${NW_NAME}"

FABRIC_CFG_PATH=$NW_PATH/config/
export NW_NAME=${NW_NAME}

if [ "$CC_SRC_LANGUAGE" = "go" -o "$CC_SRC_LANGUAGE" = "golang" ] ; then
    CC_RUNTIME_LANGUAGE=golang
    #CC_SRC_PATH="./chaincode/fabcar/go/"
    CC_SRC_PATH="$APP_R/fabric/shared/chaincode/$CC_CHAIN_CODE"
    echo "Preparing for deployment of :" $CC_SRC_PATH
    sleep 1

elif [ "$CC_SRC_LANGUAGE" = "javascript" ]; then
    CC_RUNTIME_LANGUAGE=node # chaincode runtime language is node.js
    CC_SRC_PATH="./chaincode/fabcar/javascript/"

elif [ "$CC_SRC_LANGUAGE" = "java" ]; then
    CC_RUNTIME_LANGUAGE=java
    CC_SRC_PATH="./chaincode/fabcar/java/build/install/fabcar"

    echo Compiling Java code ...
    pushd ../chaincode/fabcar/java
    ./gradlew installDist
    popd
    echo Finished compiling Java code

elif [ "$CC_SRC_LANGUAGE" = "typescript" ]; then
    CC_RUNTIME_LANGUAGE=node # chaincode runtime language is node.js
    CC_SRC_PATH="./chaincode/fabcar/typescript/"

    echo Compiling TypeScript code into JavaScript ...
    pushd ./chaincode/fabcar/typescript
    npm install
    npm run build
    popd
    echo Finished compiling TypeScript code into JavaScript

else
    echo The chaincode language ${CC_SRC_LANGUAGE} is not supported by this script
    echo Supported chaincode languages are: go, java, javascript, and typescript
    exit 1
fi

# import utils
. scripts/envVar.sh $NW_PATH $PEER_ORG1_PORT $NW_NAME $NUM_ORGS


chaincodeInvokeInit() {
	parsePeerConnectionParameters $@
	res=$?
	verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

	# while 'peer chaincode' command can get the orderer endpoint from the
	# peer (if join was successful), let's supply it directly as we know
	# it using the "-o" option
	set -x
        peer chaincode invoke -o localhost:${ORD_P} --ordererTLSHostnameOverride orderer.$NW_NAME.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CC_CHAIN_CODE --isInit $PEER_CONN_PARMS -c '{"function":"init","Args":[]}' >&log.txt
	res=$?
	set +x
	cat log.txt
	verifyResult $res "Invoke execution on $PEERS failed "
	echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME' ===================== "
	echo
    sleep 1
}

chaincodeInvoke() {
	parsePeerConnectionParameters $@
	res=$?
	verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

	# while 'peer chaincode' command can get the orderer endpoint from the
	# peer (if join was successful), let's supply it directly as we know
	# it using the "-o" option
	set -x
	ASSET_PROPERTIES=$(echo -n "{\"objectType\":\"asset\",\"assetID\":\"asset1\",\"color\":\"green\",\"size\":20,\"appraisedValue\":100}" | base64 | tr -d \\n)
	ASSET_VALUE=$(echo -n "{\"assetID\":\"asset1\",\"appraisedValue\":100}" | base64 | tr -d \\n)
	ASSET_OWNER=$(echo -n "{\"assetID\":\"asset1\",\"buyerMSP\":\"Org2MSP\"}" | base64 | tr -d \\n)

        #peer chaincode invoke -o localhost:${ORD_P} --ordererTLSHostnameOverride orderer.$NW_NAME.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CC_CHAIN_CODE $PEER_CONN_PARMS -c '{"function":"CreateAsset","Args":[]}' --transient "{\"asset_properties\":\"$ASSET_PROPERTIES\"}" >&log.txt
        #peer chaincode invoke -o localhost:${ORD_P} --ordererTLSHostnameOverride orderer.$NW_NAME.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CC_CHAIN_CODE $PEER_CONN_PARMS -c '{"function":"AgreeToTransfer","Args":[]}' --transient "{\"asset_value\":\"$ASSET_VALUE\"}" >&log.txt
        peer chaincode invoke -o localhost:${ORD_P} --ordererTLSHostnameOverride orderer.$NW_NAME.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CC_CHAIN_CODE $PEER_CONN_PARMS -c '{"function":"TransferAsset","Args":[]}' --transient "{\"asset_owner\":\"$ASSET_OWNER\"}" >&log.txt
	res=$?
	set +x
	cat log.txt
	verifyResult $res "Invoke execution on $PEERS failed "
	echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME' ===================== "
	echo
    sleep 1
}

chaincodeQuery() {
	ORG=$1
	setGlobals $1 $2 $3
	echo "===================== Querying on peer0.org${ORG} on channel '$CHANNEL_NAME'... ===================== "
    local rc=1
    local COUNTER=1
    # continue to poll
	# we either get a successful response, or reach MAX RETRY
    #while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    echo "Attempting to Query peer0.org${ORG} ...$(($(date +%s) - starttime)) secs"
    set -x
    #peer channel fetch newest ${CHANNEL_NAME}.block -c $CHANNEL_NAME --connTimeout 120s >&log.txt
    #peer chaincode query -C $CHANNEL_NAME -n $CC_CHAIN_CODE -c '{"function":"ReadAsset","Args":["asset1"]}' >&log.txt
    peer chaincode query -C $CHANNEL_NAME -n $CC_CHAIN_CODE -c '{"function":"ReadAssetPrivateDetails","Args":["Org1MSPPrivateCollection","asset1"]}' >&log.txt
    #peer chaincode query -C $CHANNEL_NAME -n $CC_CHAIN_CODE -c '{"function":"ReadAssetPrivateDetails","Args":["Org2MSPPrivateCollection","asset1"]}' >&log.txt
    #peer chaincode query -C $CHANNEL_NAME -n $CC_CHAIN_CODE -c '{"function":"ReadTransferAgreement","Args":["asset1"]}' >&log.txt
    res=$?
    set +x
        let rc=$res
        #COUNTER=$(expr $COUNTER + 1)
    #done
	echo
	cat log.txt
	if test $rc -eq 0; then
		echo "===================== Query successful on peer0.org${ORG} on channel '$CHANNEL_NAME' ===================== "
		echo
	else
		echo "!!!!!!!!!!!!!!! After $MAX_RETRY attempts, Query result on peer0.org${ORG} is INVALID !!!!!!!!!!!!!!!!"
		echo
		exit 1
	fi
}

# Create list of args required for parsePeerConnectionParameters for all orgs
PEER_ORGS_NW_LIST=()
for ii in $(seq 1 ${NUM_ORGS}); do
  PEER_ORG_PORT=$(bash -c "echo \$PEER_ORG${ii}_PORT")
	PEER_ORGS_NW_LIST+=(${ii} ${PEER_ORG_PORT} ${NW_NAME})
done

if [ "$TX_MODE" = "init" ]; then
	# Initialize the chaincode
	chaincodeInvokeInit ${PEER_ORGS_NW_LIST[@]}
elif [ "$TX_MODE" = "invoke" ]; then
	# Invoke the chaincode
	PEER_ORG_PORT=$(bash -c "echo \$PEER_ORG${TX_TARGET_ORG}_PORT")
	chaincodeInvoke $TX_TARGET_ORG $PEER_ORG_PORT $NW_NAME
elif [ "$TX_MODE" = "query" ]; then
	# Query chaincode on specific peer
	PEER_ORG_PORT=$(bash -c "echo \$PEER_ORG${TX_TARGET_ORG}_PORT")
	chaincodeQuery $TX_TARGET_ORG $PEER_ORG_PORT $NW_NAME
else
	echo "Unknown transaction mode: "$TX_MODE
	exit 1
fi

exit 0
