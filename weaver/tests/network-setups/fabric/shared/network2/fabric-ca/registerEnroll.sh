# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0



function createOrg {

  NW_CFG_PATH="$1"
  CA_PORT="$2"
  ORG_ID="$3"
  echo "NW_CFG_PATH = $NW_CFG_PATH"
	echo "Enroll the CA admin"
	mkdir -p $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/

	export FABRIC_CA_CLIENT_HOME=$NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:${CA_PORT} --caname ca.org${ORG_ID}.network2.com --tls.certfiles $NW_CFG_PATH/fabric-ca/org${ORG_ID}/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-'${CA_PORT}'-ca-org'${ORG_ID}'-network2-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-'${CA_PORT}'-ca-org'${ORG_ID}'-network2-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-'${CA_PORT}'-ca-org'${ORG_ID}'-network2-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-'${CA_PORT}'-ca-org'${ORG_ID}'-network2-com.pem
    OrganizationalUnitIdentifier: orderer' > $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/msp/config.yaml

  echo
	echo "Register peer0"
  echo
  set -x
	fabric-ca-client register --caname ca.org${ORG_ID}.network2.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles $NW_CFG_PATH/fabric-ca/org${ORG_ID}/tls-cert.pem
  set +x

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca.org${ORG_ID}.network2.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles $NW_CFG_PATH/fabric-ca/org${ORG_ID}/tls-cert.pem
  set +x

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca.org${ORG_ID}.network2.com --id.name org${ORG_ID}admin --id.secret org${ORG_ID}adminpw --id.type admin --tls.certfiles $NW_CFG_PATH/fabric-ca/org${ORG_ID}/tls-cert.pem
  set +x

	mkdir -p $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/peers
  mkdir -p $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/peers/peer0.org${ORG_ID}.network2.com

  echo
  echo "## Generate the peer0 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:${CA_PORT} --caname ca.org${ORG_ID}.network2.com -M $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/peers/peer0.org${ORG_ID}.network2.com/msp --csr.hosts peer0.org${ORG_ID}.network2.com --tls.certfiles $NW_CFG_PATH/fabric-ca/org${ORG_ID}/tls-cert.pem
  set +x

  cp $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/msp/config.yaml $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/peers/peer0.org${ORG_ID}.network2.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:${CA_PORT} --caname ca.org${ORG_ID}.network2.com -M $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/peers/peer0.org${ORG_ID}.network2.com/tls --enrollment.profile tls --csr.hosts peer0.org${ORG_ID}.network2.com --csr.hosts localhost --tls.certfiles $NW_CFG_PATH/fabric-ca/org${ORG_ID}/tls-cert.pem
  set +x


  cp $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/peers/peer0.org${ORG_ID}.network2.com/tls/tlscacerts/* $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/peers/peer0.org${ORG_ID}.network2.com/tls/ca.crt
  cp $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/peers/peer0.org${ORG_ID}.network2.com/tls/signcerts/* $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/peers/peer0.org${ORG_ID}.network2.com/tls/server.crt
  cp $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/peers/peer0.org${ORG_ID}.network2.com/tls/keystore/* $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/peers/peer0.org${ORG_ID}.network2.com/tls/server.key

  mkdir $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/msp/tlscacerts
  cp $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/peers/peer0.org${ORG_ID}.network2.com/tls/tlscacerts/* $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/msp/tlscacerts/ca.crt

  mkdir $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/tlsca
  cp $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/peers/peer0.org${ORG_ID}.network2.com/tls/tlscacerts/* $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/tlsca/tlsca.org${ORG_ID}.network2.com-cert.pem

  mkdir $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/ca
  cp $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/peers/peer0.org${ORG_ID}.network2.com/msp/cacerts/* $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/ca/ca.org${ORG_ID}.network2.com-cert.pem

  mkdir -p $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/users
  mkdir -p $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/users/User1@org${ORG_ID}.network2.com

  echo
  echo "## Generate the user msp"
  echo
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:${CA_PORT} --caname ca.org${ORG_ID}.network2.com -M $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/users/User1@org${ORG_ID}.network2.com/msp --tls.certfiles $NW_CFG_PATH/fabric-ca/org${ORG_ID}/tls-cert.pem
  set +x

  mkdir -p $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/users/Admin@org${ORG_ID}.network2.com

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://org${ORG_ID}admin:org${ORG_ID}adminpw@localhost:${CA_PORT} --caname ca.org${ORG_ID}.network2.com -M $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/users/Admin@org${ORG_ID}.network2.com/msp --tls.certfiles $NW_CFG_PATH/fabric-ca/org${ORG_ID}/tls-cert.pem
  set +x

  cp $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/msp/config.yaml $NW_CFG_PATH/peerOrganizations/org${ORG_ID}.network2.com/users/Admin@org${ORG_ID}.network2.com/msp/config.yaml

}

function createOrderer {

  NW_CFG_PATH="$1"
  echo "NW_CFG_PATH = $NW_CFG_PATH"
	echo "Enroll the CA admin"
  echo
	mkdir -p $NW_CFG_PATH/ordererOrganizations/network2.com

	export FABRIC_CA_CLIENT_HOME=$NW_CFG_PATH/ordererOrganizations/network2.com
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca.orderer.network2.com --tls.certfiles $NW_CFG_PATH/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-orderer-network2-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-orderer-network2-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-orderer-network2-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-orderer-network2-com.pem
    OrganizationalUnitIdentifier: orderer' > $NW_CFG_PATH/ordererOrganizations/network2.com/msp/config.yaml


  echo
	echo "Register orderer"
  echo
  set -x
	fabric-ca-client register --caname ca.orderer.network2.com --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles $NW_CFG_PATH/fabric-ca/ordererOrg/tls-cert.pem
    set +x

  echo
  echo "Register the orderer admin"
  echo
  set -x
  fabric-ca-client register --caname ca.orderer.network2.com --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles $NW_CFG_PATH/fabric-ca/ordererOrg/tls-cert.pem
  set +x

	mkdir -p $NW_CFG_PATH/ordererOrganizations/network2.com/orderers
  mkdir -p $NW_CFG_PATH/ordererOrganizations/network2.com/orderers/network2.com

  mkdir -p $NW_CFG_PATH/ordererOrganizations/network2.com/orderers/orderer.network2.com

  echo
  echo "## Generate the orderer msp"
  echo
  set -x
	fabric-ca-client enroll -u https://orderer:ordererpw@localhost:8054 --caname ca.orderer.network2.com -M $NW_CFG_PATH/ordererOrganizations/network2.com/orderers/orderer.network2.com/msp --csr.hosts orderer.network2.com --csr.hosts localhost --tls.certfiles $NW_CFG_PATH/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp $NW_CFG_PATH/ordererOrganizations/network2.com/msp/config.yaml $NW_CFG_PATH/ordererOrganizations/network2.com/orderers/orderer.network2.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:8054 --caname ca.orderer.network2.com -M $NW_CFG_PATH/ordererOrganizations/network2.com/orderers/orderer.network2.com/tls --enrollment.profile tls --csr.hosts orderer.network2.com --csr.hosts localhost --tls.certfiles $NW_CFG_PATH/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp $NW_CFG_PATH/ordererOrganizations/network2.com/orderers/orderer.network2.com/tls/tlscacerts/* $NW_CFG_PATH/ordererOrganizations/network2.com/orderers/orderer.network2.com/tls/ca.crt
  cp $NW_CFG_PATH/ordererOrganizations/network2.com/orderers/orderer.network2.com/tls/signcerts/* $NW_CFG_PATH/ordererOrganizations/network2.com/orderers/orderer.network2.com/tls/server.crt
  cp $NW_CFG_PATH/ordererOrganizations/network2.com/orderers/orderer.network2.com/tls/keystore/* $NW_CFG_PATH/ordererOrganizations/network2.com/orderers/orderer.network2.com/tls/server.key

  mkdir $NW_CFG_PATH/ordererOrganizations/network2.com/orderers/orderer.network2.com/msp/tlscacerts
  cp $NW_CFG_PATH/ordererOrganizations/network2.com/orderers/orderer.network2.com/tls/tlscacerts/* $NW_CFG_PATH/ordererOrganizations/network2.com/orderers/orderer.network2.com/msp/tlscacerts/tlsca.network2.com-cert.pem

  mkdir $NW_CFG_PATH/ordererOrganizations/network2.com/msp/tlscacerts
  cp $NW_CFG_PATH/ordererOrganizations/network2.com/orderers/orderer.network2.com/tls/tlscacerts/* $NW_CFG_PATH/ordererOrganizations/network2.com/msp/tlscacerts/tlsca.network2.com-cert.pem

  mkdir -p $NW_CFG_PATH/ordererOrganizations/network2.com/users
  mkdir -p $NW_CFG_PATH/ordererOrganizations/network2.com/users/Admin@network2.com

  echo
  echo "## Generate the admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:8054 --caname ca.orderer.network2.com -M $NW_CFG_PATH/ordererOrganizations/network2.com/users/Admin@network2.com/msp --tls.certfiles $NW_CFG_PATH/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp $NW_CFG_PATH/ordererOrganizations/network2.com/msp/config.yaml $NW_CFG_PATH/ordererOrganizations/network2.com/users/Admin@network2.com/msp/config.yaml

}
