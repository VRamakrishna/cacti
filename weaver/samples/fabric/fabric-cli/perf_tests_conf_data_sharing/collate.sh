if [ $# -lt 1 ];
then
    echo "Need 1 argument: collate.sh <num_orgs>."
    exit 1
fi

cat latency.plaintext.${1}orgs.* > latency.plaintext.${1}orgs.all
cat latency.plaintext.her.${1}orgs.* > latency.plaintext.her.${1}orgs.all
cat latency.plaintext.vg.${1}orgs.* > latency.plaintext.vg.${1}orgs.all
cat latency.plaintext.wes.${1}orgs.* > latency.plaintext.wes.${1}orgs.all
cat latency.plaintext.ees.${1}orgs.* > latency.plaintext.ees.${1}orgs.all
cat latency.plaintext.vev.${1}orgs.* > latency.plaintext.vev.${1}orgs.all
cat latency.plaintext.vv.${1}orgs.* > latency.plaintext.vv.${1}orgs.all

cat latency.conf_ecies.${1}orgs.* > latency.conf_ecies.${1}orgs.all
cat latency.conf_ecies.her.${1}orgs.* > latency.conf_ecies.her.${1}orgs.all
cat latency.conf_ecies.vg.${1}orgs.* > latency.conf_ecies.vg.${1}orgs.all
cat latency.conf_ecies.wes.${1}orgs.* > latency.conf_ecies.wes.${1}orgs.all
cat latency.conf_ecies.ees.${1}orgs.* > latency.conf_ecies.ees.${1}orgs.all
cat latency.conf_ecies.vev.${1}orgs.* > latency.conf_ecies.vev.${1}orgs.all
cat latency.conf_ecies.vv.${1}orgs.* > latency.conf_ecies.vv.${1}orgs.all

cat latency.conf_dbe.${1}orgs.* > latency.conf_dbe.${1}orgs.all
cat latency.conf_dbe.her.${1}orgs.* > latency.conf_dbe.her.${1}orgs.all
cat latency.conf_dbe.vg.${1}orgs.* > latency.conf_dbe.vg.${1}orgs.all
cat latency.conf_dbe.wes.${1}orgs.* > latency.conf_dbe.wes.${1}orgs.all
cat latency.conf_dbe.ees.${1}orgs.* > latency.conf_dbe.ees.${1}orgs.all
cat latency.conf_dbe.vev.${1}orgs.* > latency.conf_dbe.vev.${1}orgs.all
cat latency.conf_dbe.vv.${1}orgs.* > latency.conf_dbe.vv.${1}orgs.all
