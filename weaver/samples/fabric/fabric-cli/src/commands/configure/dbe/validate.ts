/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import { GluegunCommand } from "gluegun";
import * as fs from "fs";
import * as path from "path";
import * as dotenv from "dotenv";
import logger from "../../../helpers/logger";
import { commandHelp, getNetworkConfig } from "../../../helpers/helpers";
import { invoke } from "../../../helpers/fabric-functions";
dotenv.config({ path: path.resolve(__dirname, "../../../../.env") });

const command: GluegunCommand = {
  name: "validate",
  description: "validate dbe init",
  run: async (toolbox) => {
    const {
      print,
      parameters: { options, array },
    } = toolbox;
    if (options.help || options.h) {
      commandHelp(
        print,
        toolbox,
        `fabric-cli configure dbe validate --init|--update --target-network=<network1|network2> --org=<orgMspId> --user=<username>`,
        `fabric-cli configure dbe validate --init --target-network=network1 --org=Org1MSP`,
        [],
        command,
        ["configure", "dbe", "validate"],
      );
      return;
    }

    if (!options["target-network"]) {
      print.error("--target-network needs to specified");
      return;
    }

    let userid = "user1";
    if (options["user"]) {
      userid = options["user"];
    }
    let orgs = []
    if (options["org"]) {
        orgs = [options["org"]]
    }
    
    let ccFunc = 'ValidateDbeInitVal'
    if (options['update']) {
        ccFunc = 'ValidateDbeUpdateVal'
    }

    const netConfig = getNetworkConfig(options["target-network"]);
    const interopCC = process.env.DEFAULT_CHAINCODE
        ? process.env.DEFAULT_CHAINCODE
        : "interop";

    const spinner = print.spin(`Invoking ${ccFunc}`);

    try {
      const result = await invoke(
        {
          contractName: interopCC,
          channel: netConfig.channelName,
          ccFunc: ccFunc,
          args: [],
        },
        netConfig.connProfilePath,
        options["target-network"],
        netConfig.mspId,
        logger,
        userid,
        false,
        orgs
      );
      spinner.succeed(`Response from network: ${JSON.stringify(result)} `);
    } catch (err) {
      spinner.fail(`Error invoking chaincode`);
      logger.error(`Error invoking chaincode: ${err}`);
    }

    process.exit();
  },
};

module.exports = command;
