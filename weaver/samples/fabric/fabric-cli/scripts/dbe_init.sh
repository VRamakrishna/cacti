./bin/fabric-cli configure dbe init --target-network=network1 --seed="seed123"
./bin/fabric-cli configure dbe validate --init --target-network=network1
./bin/fabric-cli configure dbe update --target-network=network1 --entity-id=1 --org=Org1MSP
./bin/fabric-cli configure dbe validate --update --target-network=network1 --org=Org1MSP
./bin/fabric-cli configure dbe update --target-network=network1 --entity-id=2 --org=Org2MSP --user=iin-agent
./bin/fabric-cli configure dbe validate --update --target-network=network1 --org=Org2MSP
