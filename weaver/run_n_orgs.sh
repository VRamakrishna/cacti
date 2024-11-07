for i in $(seq 10 10); do
    echo $i
    pushd tests/network-setups/fabric/dev
    make start-interop-local PROFILE="$i-nodes"
    popd

    pushd core/identity-management/iin-agent
    ./scripts/gen-n-org-config.sh $i /mnt/oldubuntu/opt/gopath/src/github.com/VRamakrishna/cacti/weaver 
    make deploy-all PROFILE="$i-nodes"
    popd

    pushd core/drivers/fabric-driver
    rm -rf wallet-network1 wallet-network2
    make deploy COMPOSE_ARG='--env-file docker-testnet-envs/.env.n1' NETWORK_NAME=$(grep NETWORK_NAME docker-testnet-envs/.env.n1 | cut -d '=' -f 2)
    make deploy COMPOSE_ARG='--env-file docker-testnet-envs/.env.n2' NETWORK_NAME=$(grep NETWORK_NAME docker-testnet-envs/.env.n2 | cut -d '=' -f 2)
    popd

    pushd core/relay
    make convert-compose-method2
    make start-server COMPOSE_ARG='--env-file docker/testnet-envs/.env.n1' && make start-server COMPOSE_ARG='--env-file docker/testnet-envs/.env.n2'
    make convert-compose-method1
    popd

    pushd samples/fabric/fabric-cli
    rm -rf src/wallet-network1 src/wallet-network2
    sed -i'.bak' -e "s#\"numOrgs\": .*#\"numOrgs\": $i#g" config.json
    rm -rf config.json.bak
    ./bin/fabric-cli configure all network1 network2 --num-orgs=$i
    bash scripts/dbe_init.sh $i
    sleep 310
    bash scripts/run_perf_tests.sh "${i}orgs" 100
    popd

    # CLEAN
    pushd core/identity-management/iin-agent
    make stop-all PROFILE="$i-nodes"
    make clean
    popd

    pushd tests/network-setups/fabric/dev
    make clean PROFILE="$i-nodes" && sh ~/dockerClean.sh
    popd
done

