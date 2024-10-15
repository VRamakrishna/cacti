#!/bin/bash

# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0


CHANNEL_NAME="$1"
CHANNEL_PROFILE_ARG="$2"
DELAY="$3"
MAX_RETRY="$4"
VERBOSE="$5"
NW_PATH="$6"
ORDERER_PORT="$7"
NUM_ORGS="$8"
NW_NAME="$9"
PROFILE="${10}"

: ${CHANNEL_NAME:="mychannel"}
: ${DELAY:="3"}
: ${MAX_RETRY:="5"}
: ${VERBOSE:="false"}

# import utils
. scripts/envVar.sh $NW_PATH $PEER_ORG1_PORT $NW_NAME $NUM_ORGS


if [ ! -d "$NW_PATH/channel-artifacts" ]; then
    echo "Creating channel-artifacts at $NW_PATH"
    mkdir $NW_PATH/channel-artifacts
fi

createChannelTx() {
    CHANNEL_PROFILE=$1
    echo "Generating channel-artifacts at : $NW_PATH/channel-artifacts: $CHANNEL_PROFILE"
    set -x
    configtxgen -profile $CHANNEL_PROFILE -outputCreateChannelTx $NW_PATH/channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
    res=$?
    set +x
    if [ $res -ne 0 ]; then
        echo "Failed to generate channel configuration transaction..."
        exit 1
    fi
    echo

}

createAnchorPeerTx() {
    NUM_ORGS=$1
    CHANNEL_PROFILE=$2
    for orgId in $(seq 1 ${NUM_ORGS}); do
        orgmsp="Org${orgId}MSP"
        echo "#######    Generating anchor peer update for ${orgmsp}  ##########"
        set -x
        configtxgen -profile $CHANNEL_PROFILE -outputAnchorPeersUpdate $NW_PATH/channel-artifacts/${orgmsp}anchors.tx -channelID $CHANNEL_NAME -asOrg ${orgmsp}
        res=$?
        set +x
        if [ $res -ne 0 ]; then
            echo "Failed to generate anchor peer update for ${orgmsp}..."
            exit 1
        fi
    echo
    done
}

createChannel() {
    setGlobals 1 $PEER_ORG1_PORT $NW_NAME
    # Poll in case the raft leader is not set yet
    echo "Create channel NW_NAME = ${NW_NAME}   ORDERER_CA = $ORDERER_CA"
    local rc=1
    local COUNTER=1
    while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
        sleep $DELAY
        set -x
        peer channel create -o localhost:$ORDERER_PORT -c $CHANNEL_NAME --ordererTLSHostnameOverride orderer.${NW_NAME}.com -f $NW_PATH/channel-artifacts/${CHANNEL_NAME}.tx --outputBlock $NW_PATH/channel-artifacts/${CHANNEL_NAME}.block --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
        res=$?
        set +x
        let rc=$res
        COUNTER=$(expr $COUNTER + 1)
    done
    cat log.txt
    verifyResult $res "Channel creation failed"
    echo
    echo "===================== Channel '$CHANNEL_NAME' created ===================== "
    echo
}

# queryCommitted ORG
joinChannel() {
    ORG=$1
    PEER_PORT=$2
    setGlobals $ORG $PEER_PORT $NW_NAME
    local rc=1
    local COUNTER=1
    ## Sometimes Join takes time, hence retry
    while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
        sleep $DELAY
        set -x
        peer channel join -b $NW_PATH/channel-artifacts/$CHANNEL_NAME.block >&log.txt
        res=$?
        set +x
        let rc=$res
        COUNTER=$(expr $COUNTER + 1)
    done
    cat log.txt
    echo
    verifyResult $res "After $MAX_RETRY attempts, peer0.org${ORG} has failed to join channel '$CHANNEL_NAME' "
}

updateAnchorPeers() {
    ORG=$1
    PEER_PORT=$2
    setGlobals $ORG $PEER_PORT $NW_NAME
    local rc=1
    local COUNTER=1
    ## Sometimes Join takes time, hence retry
    while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
        sleep $DELAY
        set -x
        peer channel update -o localhost:$ORDERER_PORT --ordererTLSHostnameOverride orderer.${NW_NAME}.com -c $CHANNEL_NAME -f $NW_PATH/channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
        res=$?
        set +x
        let rc=$res
        COUNTER=$(expr $COUNTER + 1)
    done
    cat log.txt
    verifyResult $res "Anchor peer update failed"
    echo "===================== Anchor peers updated for org '$CORE_PEER_LOCALMSPID' on channel '$CHANNEL_NAME' ===================== "
    sleep $DELAY
    echo
}

verifyResult() {
    if [ $1 -ne 0 ]; then
        echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
        echo
        exit 1
    fi
}

FABRIC_CFG_PATH=$NW_PATH/configtx
echo "Fabric Config path :"$FABRIC_CFG_PATH

## Create channeltx
echo "### Generating channel configuration transaction '${CHANNEL_NAME}.tx' ###"
createChannelTx $CHANNEL_PROFILE_ARG

## Create anchorpeertx
echo "### Generating channel configuration transaction '${CHANNEL_NAME}.tx' ###"
createAnchorPeerTx $NUM_ORGS $CHANNEL_PROFILE_ARG

FABRIC_CFG_PATH=$NW_PATH/config/
echo "Fabric Config path for channel creation: "$FABRIC_CFG_PATH

## Create channel
echo "Creating channel "$CHANNEL_NAME
createChannel

## Join all the peers to the channel
for ii in $(seq 1 ${NUM_ORGS}); do
    PEER_ORG_PORT=$(bash -c "echo \$PEER_ORG${ii}_PORT")
    echo "Join Org${ii} peers to the channel..."
    joinChannel ${ii} $PEER_ORG_PORT
done

## Set the anchor peers for each org in the channel
for ii in $(seq 1 ${NUM_ORGS}); do
    PEER_ORG_PORT=$(bash -c "echo \$PEER_ORG${ii}_PORT")
    echo "Updating anchor peers for Org${ii}..."
    updateAnchorPeers ${ii} $PEER_ORG_PORT
done

echo "========= Channel successfully joined =========== "

exit 0
