if [ $# -lt 2 ];
then
    echo "Need 2 arguments: run_perf_tests.sh <file_extension> <num_tries>."
    exit 1
fi

OUTDIR=perf_tests_conf_data_sharing/$1
mkdir -p 
for i in $(seq 1 $2);
do
    echo "$i"
    ./bin/fabric-cli interop --local-network=network1 --requesting-org=Org1MSP relay-network2:9083/network2/mychannel:simplestate:Read:Arcturus > fcli_log.txt
    grep INTEROP_CALL fcli_log.txt >> $OUTDIR/latency.plaintext.$1
    grep VIEW_VALIDATION fcli_log.txt >> $OUTDIR/latency.plaintext.vv.$1
    rm fcli_log.txt
    ./bin/fabric-cli interop --local-network=network1 --requesting-org=Org1MSP --e2e-confidentiality=dbe relay-network2:9083/network2/mychannel:simplestate:Read:Arcturus > fcli_log.txt
    grep INTEROP_CALL fcli_log.txt >> $OUTDIR/latency.conf_dbe.$1
    grep VIEW_VALIDATION fcli_log.txt >> $OUTDIR/latency.conf_dbe.vv.$1
    rm fcli_log.txt
    ./bin/fabric-cli interop --local-network=network1 --requesting-org=Org1MSP --e2e-confidentiality=ecies relay-network2:9083/network2/mychannel:simplestate:Read:Arcturus > fcli_log.txt
    grep INTEROP_CALL fcli_log.txt >> $OUTDIR/latency.conf_ecies.$1
    grep VIEW_VALIDATION fcli_log.txt >> $OUTDIR/latency.conf_ecies.vv.$1
    rm fcli_log.txt
done
docker logs driver-fabric-network2 | grep -a VIEW_GENERATION | awk ' NR % 3 == 1 ' > $OUTDIR/latency.plaintext.vg.$1
docker logs driver-fabric-network2 | grep -a VIEW_GENERATION | awk ' NR % 3 == 2 ' > $OUTDIR/latency.conf_dbe.vg.$1
docker logs driver-fabric-network2 | grep -a VIEW_GENERATION | awk ' NR % 3 == 0 ' > $OUTDIR/latency.conf_ecies.vg.$1
