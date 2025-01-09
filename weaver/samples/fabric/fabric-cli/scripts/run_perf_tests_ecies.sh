if [ $# -lt 3 ];
then
    echo "Need 4 arguments: run_perf_tests_ecies.sh <file_extension> <num_tries> <set_no>."
    exit 1
fi

OUTDIR=perf_tests_conf_data_sharing/$1
mkdir -p $OUTDIR 
for i in $(seq 1 $2);
do
    echo "$i"
    ./bin/fabric-cli interop --local-network=network1 --requesting-org=Org1MSP --e2e-confidentiality=ecies relay-network2:9083/network2/mychannel:simplestate:Read:Arcturus > fcli_log.txt 2> ferr_log.txt
    if [ $(grep rror ferr_log.txt | wc -l) -eq 0 ]
    then
        grep INTEROP_CALL fcli_log.txt >> $OUTDIR/latency.conf_ecies.$1.$3
        grep VIEW_VALIDATION fcli_log.txt >> $OUTDIR/latency.conf_ecies.vv.$1.$3
        grep VIEW_EXTRACTION_AND_VALIDATION fcli_log.txt >> $OUTDIR/latency.conf_ecies.vev.$1.$3
        docker logs driver-fabric-network2 | grep -a VIEW_GENERATION | tail -n 1 >> $OUTDIR/latency.conf_ecies.vg.$1.$3
        for j in $(docker ps | grep interop | awk '{print $1}'); do docker logs $j | grep HANDLE_EXTERNAL_REQUEST | tail -n 1; done >> $OUTDIR/latency.conf_ecies.her.$1.$3
        for j in $(docker ps | grep interop | awk '{print $1}'); do docker logs $j | grep WRITE_EXTERNAL_STATE | tail -n 1; done >> $OUTDIR/latency.conf_ecies.wes.$1.$3
        for j in $(docker ps | grep interop | awk '{print $1}'); do docker logs $j | grep EXTRACT_EXTERNAL_STATE | tail -n 1; done >> $OUTDIR/latency.conf_ecies.ees.$1.$3
    fi
    rm -f fcli_log.txt
    rm -f ferr_log.txt
done
