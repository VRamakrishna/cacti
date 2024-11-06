if [ $# -lt 1 ];
then
    echo "Need 1 argument: get_mean_latency.sh <file_extension>."
    exit 1
fi
PT_L_FILE=latency.plaintext.$1
PT_VG_FILE=latency.plaintext.vg.$1
PT_VV_FILE=latency.plaintext.vv.$1
CD_L_FILE=latency.conf_dbe.$1
CD_VG_FILE=latency.conf_dbe.vg.$1
CD_VV_FILE=latency.conf_dbe.vv.$1
CE_L_FILE=latency.conf_ecies.$1
CE_VG_FILE=latency.conf_ecies.vg.$1
CE_VV_FILE=latency.conf_ecies.vv.$1
PLAINTEXT_LATENCY=$(cat $PT_L_FILE | cut -d ' ' -f 2 | awk '{ total += $1 } END { print total/NR }')
echo "MEAN latency for end-to-end plaintext data sharing: "$PLAINTEXT_LATENCY" seconds"
PLAINTEXT_VIEW_GEN_LATENCY=$(cat $PT_VG_FILE | cut -d ' ' -f 2 | awk '{ total += $1 } END { print total/NR }')
echo "MEAN view generation latency for end-to-end plaintext data sharing: "$PLAINTEXT_VIEW_GEN_LATENCY" seconds"
PLAINTEXT_VIEW_VAL_LATENCY=$(cat $PT_VV_FILE | grep -v ms | grep -v "\ 0\." | cut -d ' ' -f 2 | awk '{ total += $1 } END { print total/NR }')
echo "MEAN view validation latency for end-to-end plaintext data sharing: "$PLAINTEXT_VIEW_VAL_LATENCY" seconds"
CONF_DBE_LATENCY=$(cat $CD_L_FILE | cut -d ' ' -f 2 | awk '{ total += $1 } END { print total/NR }')
echo "MEAN latency for end-to-end confidential data sharing with DBE: "$CONF_DBE_LATENCY" seconds"
CONF_DBE_VIEW_GEN_LATENCY=$(cat $CD_VG_FILE | cut -d ' ' -f 2 | awk '{ total += $1 } END { print total/NR }')
echo "MEAN view generation latency for end-to-end confidential data sharing with DBE: "$CONF_DBE_VIEW_GEN_LATENCY" seconds"
CONF_DBE_VIEW_VAL_LATENCY=$(cat $CD_VV_FILE | grep -v ms | grep -v "\ 0\." | cut -d ' ' -f 2 | awk '{ total += $1 } END { print total/NR }')
echo "MEAN view validation latency for end-to-end confidential data sharing with DBE: "$CONF_DBE_VIEW_VAL_LATENCY" seconds"
CONF_ECIES_LATENCY=$(cat $CE_L_FILE | cut -d ' ' -f 2 | awk '{ total += $1 } END { print total/NR }')
echo "MEAN latency for end-to-end confidential data sharing with ECIES: "$CONF_ECIES_LATENCY" seconds"
CONF_ECIES_VIEW_GEN_LATENCY=$(cat $CE_VG_FILE | cut -d ' ' -f 2 | awk '{ total += $1 } END { print total/NR }')
echo "MEAN view generation latency for end-to-end confidential data sharing with ECIES: "$CONF_ECIES_VIEW_GEN_LATENCY" seconds"
CONF_ECIES_VIEW_VAL_LATENCY=$(cat $CE_VV_FILE | grep -v ms | grep -v "\ 0\." | cut -d ' ' -f 2 | awk '{ total += $1 } END { print total/NR }')
echo "MEAN view validation latency for end-to-end confidential data sharing with ECIES: "$CONF_ECIES_VIEW_VAL_LATENCY" seconds"

echo "================================================================================"
echo " Latency (PT) | Latency (DBE) | Latency (ECIES) | DBE Overhead | ECIES Overhead"
echo "--------------|---------------|-----------------|--------------|----------------"
OVERHEAD_DBE=$(jq -n $CONF_DBE_LATENCY-$PLAINTEXT_LATENCY)
OVERHEAD_DBE=${OVERHEAD_DBE:0:7}
OVERHEAD_ECIES=$(jq -n $CONF_ECIES_LATENCY-$PLAINTEXT_LATENCY)
OVERHEAD_ECIES=${OVERHEAD_ECIES:0:7}
echo "    "$PLAINTEXT_LATENCY"   |    "$CONF_DBE_LATENCY"    |     "$CONF_ECIES_LATENCY"     |   "$OVERHEAD_DBE"    |     "$OVERHEAD_ECIES

echo "==================================================================================="
echo " View Gen (PT) | View Gen (DBE) | View Gen (ECIES) | DBE Overhead | ECIES Overhead"
echo "---------------|----------------|------------------|--------------|----------------"
OVERHEAD_DBE_VG=$(jq -n $CONF_DBE_VIEW_GEN_LATENCY-$PLAINTEXT_VIEW_GEN_LATENCY)
OVERHEAD_DBE_VG=${OVERHEAD_DBE_VG:0:7}
OVERHEAD_ECIES_VG=$(jq -n $CONF_ECIES_VIEW_GEN_LATENCY-$PLAINTEXT_VIEW_GEN_LATENCY)
OVERHEAD_ECIES_VG=${OVERHEAD_ECIES_VG:0:7}
echo "    "$PLAINTEXT_VIEW_GEN_LATENCY"    |     "$CONF_DBE_VIEW_GEN_LATENCY"    |     "$CONF_ECIES_VIEW_GEN_LATENCY"      |   "$OVERHEAD_DBE_VG"    |     "$OVERHEAD_ECIES_VG

echo "==================================================================================="
echo " View Val (PT) | View Val (DBE) | View Val (ECIES) | DBE Overhead | ECIES Overhead"
echo "---------------|----------------|------------------|--------------|----------------"
OVERHEAD_DBE_VV=$(jq -n $CONF_DBE_VIEW_VAL_LATENCY-$PLAINTEXT_VIEW_VAL_LATENCY)
OVERHEAD_DBE_VV=${OVERHEAD_DBE_VV:0:7}
OVERHEAD_ECIES_VV=$(jq -n $CONF_ECIES_VIEW_VAL_LATENCY-$PLAINTEXT_VIEW_VAL_LATENCY)
OVERHEAD_ECIES_VV=${OVERHEAD_ECIES_VV:0:7}
echo "    "$PLAINTEXT_VIEW_VAL_LATENCY"    |     "$CONF_DBE_VIEW_VAL_LATENCY"    |      "$CONF_ECIES_VIEW_VAL_LATENCY"     |    "$OVERHEAD_DBE_VV"   |    "$OVERHEAD_ECIES_VV
echo "==================================================================================="
