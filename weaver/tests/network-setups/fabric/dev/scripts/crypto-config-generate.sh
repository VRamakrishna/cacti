#!/bin/bash

# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0

echo $1
NUM_ORGS=$2
NETWORK=$3

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function gen_crypto_config_yaml {
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${NETWORK}/$2/" \
        scripts/templates/crypto-config-org.template.yaml | sed -e $'s/\\\\n/\\\n        /g'
}

function gen_fabric_ca_server_config_yaml {
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${NETWORK}/$2/" \
        scripts/templates/fabric-ca-server-config.template.yaml | sed -e $'s/\\\\n/\\\n        /g'
}

function gen_configtx {
    template_org=""
    NETWORK=$1
    for ORG in $(seq 1 ${NUM_ORGS}); do
      PORT=$(bash -c "echo \$PEER_ORG${ORG}_PORT")
      template_org+="
    - &Org${ORG}
        # DefaultOrg defines the organization which is used in the sampleconfig
        # of the fabric.git development environment
        Name: Org${ORG}MSP

        # ID to load the MSP definition as
        ID: Org${ORG}MSP

        MSPDir: ../peerOrganizations/org${ORG}.${NETWORK}.com/msp

        # Policies defines the set of policies at this level of the config tree
        # For organization policies, their canonical path is usually
        #   /Channel/<Application|Orderer>/<OrgName>/<PolicyName>
        Policies:
            Readers:
                Type: Signature
                Rule: \"OR('Org${ORG}MSP.admin', 'Org${ORG}MSP.peer', 'Org${ORG}MSP.client')\"
            Writers:
                Type: Signature
                Rule: \"OR('Org${ORG}MSP.admin', 'Org${ORG}MSP.client')\"
            Admins:
                Type: Signature
                Rule: \"OR('Org${ORG}MSP.admin')\"
            Endorsement:
                Type: Signature
                Rule: \"OR('Org${ORG}MSP.peer')\"

        # leave this flag set to true.
        AnchorPeers:
            # AnchorPeers defines the location of peers which can be used
            # for cross org gossip communication.  Note, this value is only
            # encoded in the genesis block in the Application section context
            - Host: peer0.org${ORG}.${NETWORK}.com
              Port: ${PORT}
"
    done
    echo "$template_org">add.txt
    sed '/    ## Orgs/r add.txt' \
        scripts/templates/configtx.template.yaml \
        | sed -e "s/\${NETWORK}/$NETWORK/g" \
        | sed -e "s/\${ORDERER_PORT}/${ORDERER_PORT}/g" \
        | sed -e $'s/\\\\n/\\\n        /g'
    rm add.txt
}

function gen_configtx2 {
  NUM_ORGS=$1
  if [ "$NUM_ORGS" -gt "2" ]; then
    ALL_ORGS_LIST=""
    ALL_ORGS_LIST2=""
    for ii in $(seq 1 ${NUM_ORGS}); do
        ALL_ORGS_LIST+="
                    - *Org${ii}"
        ALL_ORGS_LIST2+="
                - *Org${ii}"
    done
    template_profile="
    NOrgsOrdererGenesis:
        <<: *ChannelDefaults
        Orderer:
            <<: *OrdererDefaults
            Organizations:
                - *OrdererOrg
            Capabilities: *OrdererCapabilities
        Consortiums:
            SampleConsortium:
                Organizations:${ALL_ORGS_LIST}

    NOrgsChannel:
        Consortium: SampleConsortium
        <<: *ChannelDefaults
        Application:
            <<: *ApplicationDefaults
            Organizations:${ALL_ORGS_LIST2}

            Capabilities: *ApplicationCapabilities
"
    echo "$template_profile"
  fi
}

function clean_old {
  ROOT_DIR=$1
  rm -rf $ROOT_DIR/configtx/configtx.yaml
  rm -rf $ROOT_DIR/fabric-ca/org*
  rm -rf $ROOT_DIR/cryptogen/crypto-config-org?.yaml
  rm -rf $ROOT_DIR/cryptogen/crypto-config-org??.yaml
}

echo -e "CRYPTO GENERATE ARGS: APP_ROOT: $1, NUM_ORGS: $NUM_ORGS, NETWORK: $3"

clean_old $1

for ii in $(seq 1 ${NUM_ORGS}); do
    ORG=${ii}
    echo "$(gen_crypto_config_yaml $ORG $NETWORK)" > $1/cryptogen/crypto-config-org${ORG}.yaml
    mkdir -p $1/fabric-ca/org${ORG}
    echo "$(gen_fabric_ca_server_config_yaml $ORG $NETWORK)" > $1/fabric-ca/org${ORG}/fabric-ca-server-config.yaml
done

echo "$(gen_configtx ${NETWORK})" > $1/configtx/configtx.yaml
gen_configtx2 ${NUM_ORGS} >> $1/configtx/configtx.yaml
