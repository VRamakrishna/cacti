#!/bin/bash

# function to compute average from a data file containing a mix of milliseconds and milliseconds numbers
computeAverage() {
    AGG1=$(cat $1 | grep -v ms | cut -d ' ' -f 2 | awk '{ total += $1 } END { print total, NR }')
    AGG2=$(cat $1 | grep ms | cut -d ' ' -f 2 | awk '{ total += $1 } END { print total, NR }')
    AVG1=$(echo $AGG1 | cut -d ' ' -f 1)
    CNT1=$(echo $AGG1 | cut -d ' ' -f 2)
    AVG2=$(echo $AGG2 | cut -d ' ' -f 1)
    CNT2=$(echo $AGG2 | cut -d ' ' -f 2)
    AVG=$(echo $AVG1 $CNT1 $AVG2 $CNT2 | awk '{ avg = (($1 * 1000) + $3)/($2 + $4) } END { print avg }')
    echo $AVG
}

if [ $# -lt 1 ];
then
    echo "Need 1 argument: get_mean_latency.sh <file_extension>."
    exit 1
fi
PT_L_FILE=latency.plaintext.$1
PT_VG_FILE=latency.plaintext.vg.$1
PT_VV_FILE=latency.plaintext.vv.$1
PT_HER_FILE=latency.plaintext.her.$1
PT_WES_FILE=latency.plaintext.wes.$1
CD_L_FILE=latency.conf_dbe.$1
CD_VG_FILE=latency.conf_dbe.vg.$1
CD_VV_FILE=latency.conf_dbe.vv.$1
CD_HER_FILE=latency.conf_dbe.her.$1
CD_WES_FILE=latency.conf_dbe.wes.$1
CE_L_FILE=latency.conf_ecies.$1
CE_VG_FILE=latency.conf_ecies.vg.$1
CE_VV_FILE=latency.conf_ecies.vv.$1
CE_HER_FILE=latency.conf_ecies.her.$1
CE_WES_FILE=latency.conf_ecies.wes.$1
PLAINTEXT_LATENCY=$(computeAverage $PT_L_FILE)
echo "MEAN latency for end-to-end plaintext data sharing: "$PLAINTEXT_LATENCY" milliseconds"
PLAINTEXT_VIEW_GEN_LATENCY=$(computeAverage $PT_VG_FILE)
echo "MEAN view generation latency for end-to-end plaintext data sharing: "$PLAINTEXT_VIEW_GEN_LATENCY" milliseconds"
PLAINTEXT_VIEW_VAL_LATENCY=$(computeAverage $PT_VV_FILE)
echo "MEAN view validation latency for end-to-end plaintext data sharing: "$PLAINTEXT_VIEW_VAL_LATENCY" milliseconds"
PLAINTEXT_HANDLE_EXTERNAL_REQUEST_LATENCY=$(computeAverage $PT_HER_FILE)
echo "MEAN handle_external_request latency for end-to-end plaintext data sharing: "$PLAINTEXT_HANDLE_EXTERNAL_REQUEST_LATENCY" milliseconds"
PLAINTEXT_WRITE_EXTERNAL_STATE_LATENCY=$(computeAverage $PT_WES_FILE)
echo "MEAN write_external_state latency for end-to-end plaintext data sharing: "$PLAINTEXT_WRITE_EXTERNAL_STATE_LATENCY" milliseconds"
CONF_DBE_LATENCY=$(computeAverage $CD_L_FILE)
echo "MEAN latency for end-to-end confidential data sharing with DBE: "$CONF_DBE_LATENCY" milliseconds"
CONF_DBE_VIEW_GEN_LATENCY=$(computeAverage $CD_VG_FILE)
echo "MEAN view generation latency for end-to-end confidential data sharing with DBE: "$CONF_DBE_VIEW_GEN_LATENCY" milliseconds"
CONF_DBE_VIEW_VAL_LATENCY=$(computeAverage $CD_VV_FILE)
echo "MEAN view validation latency for end-to-end confidential data sharing with DBE: "$CONF_DBE_VIEW_VAL_LATENCY" milliseconds"
CONF_DBE_HANDLE_EXTERNAL_REQUEST_LATENCY=$(computeAverage $CD_HER_FILE)
echo "MEAN handle_external_request latency for end-to-end confidential data sharing with DBE: "$CONF_DBE_HANDLE_EXTERNAL_REQUEST_LATENCY" milliseconds"
CONF_DBE_WRITE_EXTERNAL_STATE_LATENCY=$(computeAverage $CD_WES_FILE)
echo "MEAN write_external_state latency for end-to-end confidential data sharing with DBE: "$CONF_DBE_WRITE_EXTERNAL_STATE_LATENCY" milliseconds"
CONF_ECIES_LATENCY=$(computeAverage $CE_L_FILE)
echo "MEAN latency for end-to-end confidential data sharing with ECIES: "$CONF_ECIES_LATENCY" milliseconds"
CONF_ECIES_VIEW_GEN_LATENCY=$(computeAverage $CE_VG_FILE)
echo "MEAN view generation latency for end-to-end confidential data sharing with ECIES: "$CONF_ECIES_VIEW_GEN_LATENCY" milliseconds"
CONF_ECIES_VIEW_VAL_LATENCY=$(computeAverage $CE_VV_FILE)
echo "MEAN view validation latency for end-to-end confidential data sharing with ECIES: "$CONF_ECIES_VIEW_VAL_LATENCY" milliseconds"
CONF_ECIES_HANDLE_EXTERNAL_REQUEST_LATENCY=$(computeAverage $CE_HER_FILE)
echo "MEAN handle_external_request latency for end-to-end confidential data sharing with ECIES: "$CONF_ECIES_HANDLE_EXTERNAL_REQUEST_LATENCY" milliseconds"
CONF_ECIES_WRITE_EXTERNAL_STATE_LATENCY=$(computeAverage $CE_WES_FILE)
echo "MEAN write_external_state latency for end-to-end confidential data sharing with ECIES: "$CONF_ECIES_WRITE_EXTERNAL_STATE_LATENCY" milliseconds"

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
echo "========================================================================================="
echo " Handle Ext (PT) | Handle Ext (DBE) | Handle Ext (ECIES) | DBE Overhead | ECIES Overhead"
echo "-----------------|------------------|--------------------|--------------|----------------"
OVERHEAD_DBE_HER=$(jq -n $CONF_DBE_HANDLE_EXTERNAL_REQUEST_LATENCY-$PLAINTEXT_HANDLE_EXTERNAL_REQUEST_LATENCY)
OVERHEAD_DBE_HER=${OVERHEAD_DBE_HER:0:7}
OVERHEAD_ECIES_HER=$(jq -n $CONF_ECIES_HANDLE_EXTERNAL_REQUEST_LATENCY-$PLAINTEXT_HANDLE_EXTERNAL_REQUEST_LATENCY)
OVERHEAD_ECIES_HER=${OVERHEAD_ECIES_HER:0:7}
echo "     "$PLAINTEXT_HANDLE_EXTERNAL_REQUEST_LATENCY"     |      "$CONF_DBE_HANDLE_EXTERNAL_REQUEST_LATENCY"     |      "$CONF_ECIES_HANDLE_EXTERNAL_REQUEST_LATENCY"       |   "$OVERHEAD_DBE_HER"    |     "$OVERHEAD_ECIES_HER

echo "======================================================================================"
echo " Write Ext (PT) | Write Ext (DBE) | Write Ext (ECIES) | DBE Overhead | ECIES Overhead"
echo "----------------|-----------------|-------------------|--------------|----------------"
OVERHEAD_DBE_WES=$(jq -n $CONF_DBE_WRITE_EXTERNAL_STATE_LATENCY-$PLAINTEXT_WRITE_EXTERNAL_STATE_LATENCY)
OVERHEAD_DBE_WES=${OVERHEAD_DBE_WES:0:7}
OVERHEAD_ECIES_WES=$(jq -n $CONF_ECIES_WRITE_EXTERNAL_STATE_LATENCY-$PLAINTEXT_WRITE_EXTERNAL_STATE_LATENCY)
OVERHEAD_ECIES_WES=${OVERHEAD_ECIES_WES:0:7}
echo "     "$PLAINTEXT_WRITE_EXTERNAL_STATE_LATENCY"     |      "$CONF_DBE_WRITE_EXTERNAL_STATE_LATENCY"     |       "$CONF_ECIES_WRITE_EXTERNAL_STATE_LATENCY"      |    "$OVERHEAD_DBE_WES"   |    "$OVERHEAD_ECIES_WES
echo "==================================================================================="
