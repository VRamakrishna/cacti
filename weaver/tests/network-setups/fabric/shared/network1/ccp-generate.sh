#!/bin/bash

# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0

echo $1
NUM_ORGS=$2

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        $6/ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    local OP=$(one_line_pem $7)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        -e "s#\${ORDERER_PORT}#$6#" \
        -e "s#\${ORDERER_PEM}#$OP#" \
        $8/ccp-template.yaml | sed -e $'s/\\\\n/\\\n        /g'
}

for ii in $(seq 1 ${NUM_ORGS}); do
    ORDERER_PORT=7050
    ORDERER_PEM=$1/ordererOrganizations/network1.com/msp/tlscacerts/tlsca.network1.com-cert.pem
    ORG=${ii}
    P0PORT=$(bash -c "echo \$N1_PEER_ORG${ii}_PORT")
    CAPORT=$(bash -c "echo \$N1_CA_ORG${ii}_PORT")
    PEERPEM=$1/peerOrganizations/org${ii}.network1.com/tlsca/tlsca.org${ii}.network1.com-cert.pem
    CAPEM=$1/peerOrganizations/org${ii}.network1.com/ca/ca.org${ii}.network1.com-cert.pem

    echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $1)" > $1/peerOrganizations/org${ii}.network1.com/connection-org${ii}.json
    echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORDERER_PORT $ORDERER_PEM $1)" > $1/peerOrganizations/org${ii}.network1.com/connection-org${ii}.yaml
    echo "PEER PEM:" $PEERPEM
    echo "CA PEM:" $CAPEM
done
