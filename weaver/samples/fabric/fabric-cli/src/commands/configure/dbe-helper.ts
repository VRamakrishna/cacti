/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import { GluegunCommand } from "gluegun";
import * as fs from "fs";
import * as path from "path";
import { commandHelp, validKeys } from "../../helpers/helpers";

const command: GluegunCommand = {
  name: "dbe",
  description: "Configure DBE for end-to-end encryption",
  run: async (toolbox) => {
    const {
      print,
      parameters: { options, array },
    } = toolbox;
    if (options.help || options.h) {
      commandHelp(
        print,
        toolbox,
        `fabric-cli configure dbe init|update`,
        ``,
        [],
        command,
        ["configure", "dbe"],
      );
      return;
    }
  },
};

module.exports = command;
