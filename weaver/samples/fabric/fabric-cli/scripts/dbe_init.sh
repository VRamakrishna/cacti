SCRIPT_PATH=$(dirname $(realpath "$0"))
if [ $# -eq 0 ];
then
    echo "No arguments supplied. Need non-zero participant count: dbe_init.sh <num-participants>."
    exit 1
fi
if [ $1 -le 0 ];
then
    echo "Invalid participant count "$1". Must be greater than 0."
    exit 1
fi
echo "Generating DBE Init Request"
./bin/fabric-cli configure dbe init --target-network=network1 --seed="seed123"
echo "Generating DBE Init Request.......DONE"
echo "Validating DBE Init Request"
./bin/fabric-cli configure dbe validate --init --target-network=network1
echo "Validating DBE Init Request.......DONE"
for count in $(seq 1 $1);
do
    echo "Copying iin-agent wallet ID for org "$count" to fabric-cli wallet"
    cp $SCRIPT_PATH/../../../../tests/network-setups/fabric/shared/network1/peerOrganizations/org$count.network1.com/wallet-iin-agent/iin-agent.id $SCRIPT_PATH/../src/wallet-network1/
    echo "Generating DBE Update Request for participant "$count
    ./bin/fabric-cli configure dbe update --target-network=network1 --entity-id=${count} --org=Org${count}MSP --user=iin-agent
    echo "Generating DBE Update Request for participant "$count".......DONE"
    echo "Validating DBE Update Request for participant "$count
    ./bin/fabric-cli configure dbe validate --update --target-network=network1 --org=Org${count}MSP
    echo "Validating DBE Update Request for participant "$count".......DONE"
done
