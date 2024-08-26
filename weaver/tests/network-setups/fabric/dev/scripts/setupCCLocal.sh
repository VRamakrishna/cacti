# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0

directory=$(dirname $0)

CHAINCODE_PATH=$directory/../../../fabric/shared/chaincode
INTEROP_CC_PATH=$PWD/../../../../core/network/fabric-interop-cc

echo "Setting up Interop CC..."

if [ -d "${CHAINCODE_PATH}/interop" ]; then
    echo "Deleting previously built interop cc folder"
    rm -rf ${CHAINCODE_PATH}/interop
fi
(cd $INTEROP_CC_PATH/contracts/interop && make run-vendor)
cp -r $INTEROP_CC_PATH/contracts/interop $CHAINCODE_PATH/interop
cp $INTEROP_CC_PATH/scripts/generate_collections_config.js $CHAINCODE_PATH/interop/
if [ "$PROFILE" = "2-nodes" ]; then
    echo "Creating collections configuration for 2 orgs"
    cd $CHAINCODE_PATH/interop/ && node generate_collections_config.js collections_config.json Org1MSP Org2MSP
else
    echo "Creating collections configuration for 1 org"
    cd $CHAINCODE_PATH/interop/ && node generate_collections_config.js collections_config.json Org1MSP
fi
(cd $INTEROP_CC_PATH/contracts/interop && make undo-vendor)
echo "Done."

