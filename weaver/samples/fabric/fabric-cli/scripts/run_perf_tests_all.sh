if [ $# -lt 1 ];
then
    echo "Need 4 arguments: run_perf_tests_all.sh <num_orgs>."
    exit 1
fi

./scripts/run_perf_tests_plaintext.sh ${1}orgs 100 0
./scripts/run_perf_tests_ecies.sh ${1}orgs 100 0
./scripts/run_perf_tests_dbe.sh ${1}orgs 100 0
