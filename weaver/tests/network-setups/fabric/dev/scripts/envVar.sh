#!/bin/bash

#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts
#NWPATH="$1"
#P_ADD="$1"

export NW_NAME="$3"
export NUM_ORGS="$4"
export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=$NW_PATH/ordererOrganizations/${NW_NAME}.com/orderers/orderer.${NW_NAME}.com/msp/tlscacerts/tlsca.${NW_NAME}.com-cert.pem
for ii in $(seq 1 ${NUM_ORGS}); do
    export "PEER0_ORG${ii}_CA"=$NW_PATH/peerOrganizations/org${ii}.${NW_NAME}.com/peers/peer0.org${ii}.${NW_NAME}.com/tls/ca.crt
done

# Set OrdererOrg.Admin globals
setOrdererGlobals() {
  export CORE_PEER_LOCALMSPID="OrdererMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$NW_PATH/ordererOrganizations/${NW_NAME}.com/orderers/orderer.${NW_NAME}.com/msp/tlscacerts/tlsca.network1.com-cert.pem
  export CORE_PEER_MSPCONFIGPATH=$NW_PATH/ordererOrganizations/${NW_NAME}.com/users/Admin@${NW_NAME}.com/msp
}

# Set environment variables for the peer org
setGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  echo "Using organization ${USING_ORG}  NW - $3"
  export CORE_PEER_LOCALMSPID="Org${USING_ORG}MSP"
  ca_path=$(bash -c "echo \$PEER0_ORG${USING_ORG}_CA")
  export CORE_PEER_TLS_ROOTCERT_FILE=$ca_path
  export CORE_PEER_MSPCONFIGPATH=$NW_PATH/peerOrganizations/org"${USING_ORG}"."$3".com/users/Admin@org"${USING_ORG}"."$3".com/msp
  export CORE_PEER_ADDRESS="localhost:"${2}

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {

  PEER_CONN_PARMS=""
  PEERS=""
  #echo "In parsePeerConnectionParameters : "$CORE_PEER_ADDRESS
  while [ "$#" -gt 0 ]; do
    setGlobals $1 $2 $3
    PEER="peer0.org$1"
    ## Set peer adresses
    PEERS="$PEERS $PEER"
    PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $CORE_PEER_ADDRESS"
    ## Set path to TLS certificate
    TLSINFO=$(eval echo "--tlsRootCertFiles \$PEER0_ORG$1_CA")
    PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
    echo "PEER_CONN_PARMS: $PEER_CONN_PARMS"
    # shift by 3 to get to the next organization
    shift 3
  done
  # remove leading space for output
  PEERS="$(echo -e "$PEERS" | sed -e 's/^[[:space:]]*//')"
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo
    exit 1
  fi
}
