https://github.com/actions/toolkit/blob/main/packages/core/src/summary.ts

const { EOL } = require("os");
const fs = require("fs");

const issueCommand = (cmd) => process.stdout.write(`${cmd}${EOL}`);

const notice = (value) => issueCommand(`::notice::${value}`);

// Todo
notice("Build Summary Todo...");