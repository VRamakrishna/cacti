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
    hostname=$7
    ca_hostname=$8
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        -e "s#\${HOSTNAME}#$hostname#" \
        -e "s#\${CA_HOSTNAME}#$ca_hostname#" \
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
    ORDERER_PORT=9050
    ORDERER_PEM=$1/ordererOrganizations/network2.com/msp/tlscacerts/tlsca.network2.com-cert.pem
    ORG=${ii}
    P0PORT=$(bash -c "echo \$N2_PEER_ORG${ii}_PORT")
    CAPORT=$(bash -c "echo \$N2_CA_ORG${ii}_PORT")
    PEERPEM=$1/peerOrganizations/org${ii}.network2.com/tlsca/tlsca.org${ii}.network2.com-cert.pem
    CAPEM=$1/peerOrganizations/org${ii}.network2.com/ca/ca.org${ii}.network2.com-cert.pem
    hostname="peer0.org${ii}.network2.com"
    ca_hostname="ca.org${ii}.network2.com"
    echo "PEER PEM:" $PEERPEM
    echo "CA PEM:" $CAPEM

    echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $1 localhost localhost)" > $1/peerOrganizations/org${ii}.network2.com/connection-org${ii}.json
    echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $1 $hostname $ca_hostname)" > $1/peerOrganizations/org${ii}.network2.com/connection-org${ii}.docker.json
    echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORDERER_PORT $ORDERER_PEM $1)" > $1/peerOrganizations/org${ii}.network2.com/connection-org${ii}.yaml
done
