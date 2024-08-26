/*
 * SPDX-License-Identifier: Apache-2.0
*/

const fs = require('fs');


if (process.argv.length < 4) {
    console.log("Need a filename and at least oen org MSP Id:");
    console.log("    node generate_collections_config.js <output_filename> <org_1_msp> [<org_2_msp> .....]");
    process.exit(1);
}

let filename = process.argv[2];
let collections_config = [];

for (let i = 3 ; i < process.argv.length ; i++) {
    let collection_org_config = {};
    collection_org_config["name"] = process.argv[i] + "PrivateCollection";
    collection_org_config["policy"] = "OR('" + process.argv[i] + ".member')";
    collection_org_config["requiredPeerCount"] = 0;
    collection_org_config["maxPeerCount"] = 1;
    collection_org_config["blockToLive"] = 0;	// Never delete
    collection_org_config["memberOnlyRead"] = true;
    collection_org_config["memberOnlyWrite"] = true;
    let endorsement_policy = {};
    endorsement_policy["signaturePolicy"] = "OR('" + process.argv[i] + ".member')";
    collection_org_config["endorsementPolicy"] = endorsement_policy;
    collections_config.push(collection_org_config);
}

if (!filename.endsWith(".json")) {
    filename = filename + ".json";
}

fs.writeFileSync(filename, JSON.stringify(collections_config, null, 4));
