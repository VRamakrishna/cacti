if [ $# -lt 3 ];
then
    echo "Need 3 arguments: run_perf_tests_all.sh <num_orgs> <num_tries> <file_extension>."
    exit 1
fi

./scripts/run_perf_tests_plaintext.sh ${1}orgs $2 $3
./scripts/run_perf_tests_ecies.sh ${1}orgs $2 $3
./scripts/run_perf_tests_dbe.sh ${1}orgs $2 $3
