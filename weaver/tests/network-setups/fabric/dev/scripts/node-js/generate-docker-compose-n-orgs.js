/*
SPDX-License-Identifier: Apache-2.0
*/
const cp = require('child_process');
const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

const COMPOSE_FILE_PEERS='docker-compose-test-net.yaml';
const COMPOSE_FILE_CAS='docker-compose-ca.yaml';

function generateDockerComposePeersYamlFile(baseDir, numOrgs) {
	const composeObj = {};
	if (!fs.existsSync(baseDir)){
		fs.mkdirSync(baseDir, { recursive: true });
	}
	const outputFile = path.join(baseDir, COMPOSE_FILE_PEERS);
	composeObj['version'] = '3';
	composeObj['volumes'] = { 'orderer.${COMPOSE_PROJECT_NAME}.com': null };
	for(let i = 1 ; i <= numOrgs ; i++) {
		const peerKey = 'peer0.org' + i + '.${COMPOSE_PROJECT_NAME}.com';
		composeObj['volumes'][peerKey] = null;
	}
	composeObj['networks'] = { 'net': null };
	composeObj['services'] = {};
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com'] = {};
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['container_name'] = 'orderer.${COMPOSE_PROJECT_NAME}.com';
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['image'] = 'hyperledger/fabric-orderer:$IMAGE_TAG';
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['environment'] = [];
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['environment'].push('FABRIC_LOGGING_SPEC=INFO');
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['environment'].push('ORDERER_GENERAL_LISTENADDRESS=0.0.0.0');
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['environment'].push('ORDERER_GENERAL_LISTENPORT=${ORDERER_PORT}');
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['environment'].push('ORDERER_GENERAL_GENESISMETHOD=file');
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['environment'].push('ORDERER_GENERAL_GENESISFILE=/var/hyperledger/orderer/orderer.genesis.block');
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['environment'].push('ORDERER_GENERAL_LOCALMSPID=OrdererMSP');
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['environment'].push('ORDERER_GENERAL_LOCALMSPDIR=/var/hyperledger/orderer/msp');
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['environment'].push('ORDERER_GENERAL_TLS_ENABLED=true');
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['environment'].push('ORDERER_GENERAL_TLS_PRIVATEKEY=/var/hyperledger/orderer/tls/server.key');
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['environment'].push('ORDERER_GENERAL_TLS_CERTIFICATE=/var/hyperledger/orderer/tls/server.crt');
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['environment'].push('ORDERER_GENERAL_TLS_ROOTCAS=[/var/hyperledger/orderer/tls/ca.crt]');
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['environment'].push('ORDERER_KAFKA_TOPIC_REPLICATIONFACTOR=1');
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['environment'].push('ORDERER_KAFKA_VERBOSE=true');
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['environment'].push('ORDERER_GENERAL_CLUSTER_CLIENTCERTIFICATE=/var/hyperledger/orderer/tls/server.crt');
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['environment'].push('ORDERER_GENERAL_CLUSTER_CLIENTPRIVATEKEY=/var/hyperledger/orderer/tls/server.key');
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['environment'].push('ORDERER_GENERAL_CLUSTER_ROOTCAS=[/var/hyperledger/orderer/tls/ca.crt]');
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['working_dir'] = '/opt/gopath/src/github.com/hyperledger/fabric';
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['command'] = 'orderer';
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['volumes'] = [];
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['volumes'].push('$NW_CFG_PATH/system-genesis-block/genesis.block:/var/hyperledger/orderer/orderer.genesis.block');
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['volumes'].push('$NW_CFG_PATH/ordererOrganizations/${COMPOSE_PROJECT_NAME}.com/orderers/orderer.${COMPOSE_PROJECT_NAME}.com/msp/:/var/hyperledger/orderer/msp');
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['volumes'].push('$NW_CFG_PATH/ordererOrganizations/${COMPOSE_PROJECT_NAME}.com/orderers/orderer.${COMPOSE_PROJECT_NAME}.com/tls/:/var/hyperledger/orderer/tls');
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['volumes'].push('orderer.${COMPOSE_PROJECT_NAME}.com:/var/hyperledger/production/orderer');
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['ports'] = [];
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['ports'].push('${ORDERER_PORT}:${ORDERER_PORT}');
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['networks'] = [];
	composeObj['services']['orderer.${COMPOSE_PROJECT_NAME}.com']['networks'].push('net');

	for(let i = 1 ; i <= numOrgs ; i++) {
		const peerKey = 'peer0.org' + i + '.${COMPOSE_PROJECT_NAME}.com';
		composeObj['services'][peerKey] = {};
		composeObj['services'][peerKey]['profiles'] = [];
		for(let j = i ; j <= numOrgs ; j++) {
			if (j == 1) {
				composeObj['services'][peerKey]['profiles'].push('1-node');
			} else {
				composeObj['services'][peerKey]['profiles'].push('' + j + '-nodes');
			}
		}
		composeObj['services'][peerKey]['container_name'] = peerKey;
		composeObj['services'][peerKey]['image'] = 'hyperledger/fabric-peer:$IMAGE_TAG';
		composeObj['services'][peerKey]['environment'] = [];
		composeObj['services'][peerKey]['environment'].push('CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock');
		composeObj['services'][peerKey]['environment'].push('CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=${COMPOSE_PROJECT_NAME}_net');
		composeObj['services'][peerKey]['environment'].push('FABRIC_LOGGING_SPEC=INFO');
		composeObj['services'][peerKey]['environment'].push('CORE_PEER_TLS_ENABLED=true');
		composeObj['services'][peerKey]['environment'].push('CORE_PEER_GOSSIP_USELEADERELECTION=true');
		composeObj['services'][peerKey]['environment'].push('CORE_PEER_GOSSIP_ORGLEADER=false');
		composeObj['services'][peerKey]['environment'].push('CORE_PEER_PROFILE_ENABLED=false');
		composeObj['services'][peerKey]['environment'].push('CORE_PEER_TLS_CERT_FILE=/etc/hyperledger/fabric/tls/server.crt');
		composeObj['services'][peerKey]['environment'].push('CORE_PEER_TLS_KEY_FILE=/etc/hyperledger/fabric/tls/server.key');
		composeObj['services'][peerKey]['environment'].push('CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/tls/ca.crt');
		composeObj['services'][peerKey]['environment'].push('CORE_PEER_ID=peer0.org' + i + '.${COMPOSE_PROJECT_NAME}.com');
		composeObj['services'][peerKey]['environment'].push('CORE_PEER_ADDRESS=peer0.org' + i + '.${COMPOSE_PROJECT_NAME}.com:$PEER_ORG' + i + '_PORT');
		composeObj['services'][peerKey]['environment'].push('CORE_PEER_LISTENADDRESS=0.0.0.0:$PEER_ORG' + i + '_PORT');
		composeObj['services'][peerKey]['environment'].push('CORE_PEER_CHAINCODEADDRESS=peer0.org' + i + '.${COMPOSE_PROJECT_NAME}.com:$CHAINCODELISTENADDRESS');
		composeObj['services'][peerKey]['environment'].push('CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:$CHAINCODELISTENADDRESS');
		composeObj['services'][peerKey]['environment'].push('CORE_PEER_GOSSIP_BOOTSTRAP=peer0.org' + i + '.${COMPOSE_PROJECT_NAME}.com:$PEER_ORG' + i + '_PORT');
		composeObj['services'][peerKey]['environment'].push('CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.org' + i + '.${COMPOSE_PROJECT_NAME}.com:$PEER_ORG' + i + '_PORT');
		composeObj['services'][peerKey]['environment'].push('CORE_PEER_LOCALMSPID=Org' + i + 'MSP');
		composeObj['services'][peerKey]['environment'].push('CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp');
		composeObj['services'][peerKey]['volumes'] = [];
		composeObj['services'][peerKey]['volumes'].push('/var/run/docker.sock:/host/var/run/docker.sock');
		composeObj['services'][peerKey]['volumes'].push('$NW_CFG_PATH/peerOrganizations/org' + i + '.${COMPOSE_PROJECT_NAME}.com/peers/peer0.org' + i + '.${COMPOSE_PROJECT_NAME}.com/msp:/etc/hyperledger/fabric/msp');
		composeObj['services'][peerKey]['volumes'].push('$NW_CFG_PATH/peerOrganizations/org' + i + '.${COMPOSE_PROJECT_NAME}.com/peers/peer0.org' + i + '.${COMPOSE_PROJECT_NAME}.com/tls:/etc/hyperledger/fabric/tls');
		composeObj['services'][peerKey]['volumes'].push('peer0.org' + i + '.${COMPOSE_PROJECT_NAME}.com:/var/hyperledger/production');
		composeObj['services'][peerKey]['working_dir'] = '/opt/gopath/src/github.com/hyperledger/fabric/peer';
		composeObj['services'][peerKey]['command'] = 'peer node start';
		composeObj['services'][peerKey]['ports'] = [];
		composeObj['services'][peerKey]['ports'].push('${PEER_ORG' + i + '_PORT}:${PEER_ORG' + i + '_PORT}');
		composeObj['services'][peerKey]['networks'] = [];
		composeObj['services'][peerKey]['networks'].push('net');
	}

	fs.writeFileSync(outputFile, yaml.dump(composeObj));

	// Replace 'null' references with blanks
	cp.execSync("sed -i 's/null//g' " + outputFile);
}

function generateDockerComposeCAsYamlFile(baseDir, numOrgs) {
	const composeObj = {};
	if (!fs.existsSync(baseDir)){
		fs.mkdirSync(baseDir, { recursive: true });
	}
	const outputFile = path.join(baseDir, COMPOSE_FILE_CAS);
	composeObj['version'] = '3';
	composeObj['networks'] = { 'net': null };
	composeObj['services'] = {};

	for(let i = 1 ; i <= numOrgs ; i++) {
		const caKey = 'ca_org' + i;
		composeObj['services'][caKey] = {};
		composeObj['services'][caKey]['profiles'] = [];
		for(let j = i ; j <= numOrgs ; j++) {
			if (j == 1) {
				composeObj['services'][caKey]['profiles'].push('1-node');
			} else {
				composeObj['services'][caKey]['profiles'].push('' + j + '-nodes');
			}
		}
		composeObj['services'][caKey]['image'] = 'hyperledger/fabric-ca:${CA_IMAGE_TAG}';
		composeObj['services'][caKey]['environment'] = [];
		composeObj['services'][caKey]['environment'].push('FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server');
		composeObj['services'][caKey]['environment'].push('FABRIC_CA_SERVER_CA_NAME=ca.org' + i + '.${COMPOSE_PROJECT_NAME}.com');
		composeObj['services'][caKey]['environment'].push('FABRIC_CA_SERVER_TLS_ENABLED=true');
		composeObj['services'][caKey]['environment'].push('FABRIC_CA_SERVER_PORT=${CA_ORG' + i + '_PORT}');
		composeObj['services'][caKey]['ports'] = [];
		composeObj['services'][caKey]['ports'].push('${CA_ORG' + i + '_PORT}:${CA_ORG' + i + '_PORT}');
		composeObj['services'][caKey]['command'] = 'sh -c \'fabric-ca-server start -b admin:adminpw -d\'';
		composeObj['services'][caKey]['volumes'] = [];
		composeObj['services'][caKey]['volumes'].push('${NW_CFG_PATH}/fabric-ca/org' + i + ':/etc/hyperledger/fabric-ca-server');
		composeObj['services'][caKey]['container_name'] = 'ca.org' + i + '.${COMPOSE_PROJECT_NAME}.com';
		composeObj['services'][caKey]['networks'] = [];
		composeObj['services'][caKey]['networks'].push('net');
	}

	composeObj['services']['ca_orderer'] = {};
	composeObj['services']['ca_orderer']['image'] = 'hyperledger/fabric-ca:${CA_IMAGE_TAG}';
	composeObj['services']['ca_orderer']['environment'] = [];
	composeObj['services']['ca_orderer']['environment'].push('FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server');
	composeObj['services']['ca_orderer']['environment'].push('FABRIC_CA_SERVER_CA_NAME=ca.orderer.${COMPOSE_PROJECT_NAME}.com');
	composeObj['services']['ca_orderer']['environment'].push('FABRIC_CA_SERVER_TLS_ENABLED=true');
	composeObj['services']['ca_orderer']['environment'].push('FABRIC_CA_SERVER_PORT=${CA_ORDERER_PORT}');
	composeObj['services']['ca_orderer']['ports'] = [];
	composeObj['services']['ca_orderer']['ports'].push('${CA_ORDERER_PORT}:${CA_ORDERER_PORT}');
	composeObj['services']['ca_orderer']['command'] = 'sh -c \'fabric-ca-server start -b admin:adminpw -d\'';
	composeObj['services']['ca_orderer']['volumes'] = [];
	composeObj['services']['ca_orderer']['volumes'].push('${NW_CFG_PATH}/fabric-ca/ordererOrg:/etc/hyperledger/fabric-ca-server');
	composeObj['services']['ca_orderer']['container_name'] = 'ca.orderer.${COMPOSE_PROJECT_NAME}.com';
	composeObj['services']['ca_orderer']['networks'] = [];
	composeObj['services']['ca_orderer']['networks'].push('net');

	fs.writeFileSync(outputFile, yaml.dump(composeObj));

	// Replace 'null' references with blanks
	cp.execSync("sed -i 's/null//g' " + outputFile);
}

if (process.argv.length < 3) {
	console.log('To generate docker-compose YAML files:');
	console.log('   node generate-docker-compose-n-orgs.js number-of-orgs');
	process.exit(1);
}

const numOrgs = Number.parseInt(process.argv[2].split("-")[0]);
if (isNaN(numOrgs)) {
	console.log('Invalid argument: <number-of-orgs>:', process.argv[2]);
	process.exit(1);
}
console.log("Num of Orgs:", numOrgs);

generateDockerComposePeersYamlFile('../../docker', numOrgs);
generateDockerComposeCAsYamlFile('../../docker', numOrgs);
