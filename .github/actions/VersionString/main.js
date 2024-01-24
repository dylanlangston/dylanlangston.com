const { EOL } = require("os");

const issueCommand = (cmd) => process.stdout.write(`${cmd}${EOL}`);
const output = (name, value) => issueCommand(`::set-output name=${name}::${value}`);
const notice = (value) => issueCommand(`::notice::${value}`);

const date = new Date(process.env.INPUT_TIME);

const major = 1;
const minor = parseInt(`${date.getFullYear() - 2000}${date.getMonth()}${date.getDate()}`);
const patch = parseInt(`${date.getHours()}${date.getMinutes()}${date.getSeconds()}`);

if (isNaN(minor) || isNaN(patch)) 
{
    process.stdout.write(`Failed to set date input time: ${time}${EOL}`);
    process.exitCode = 1;
    return;
}

output('version', `${major}.${minor}.${patch}`);
notice(`Version: ${major}.${minor}.${patch}`);