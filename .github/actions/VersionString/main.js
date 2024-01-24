const { EOL } = require("os");

// ::name key=value
const issueCommand = (name, key, value) => process.stdout.write(`::${name} ${key}=${value}${EOL}`);
const output = (name, value) => issueCommand('set-output', name, value);
const notice = (name, value) => issueCommand('notice', name, value);

const date = new Date(process.env.INPUT_TIME);

const major = 1;
const minor = parseInt(`${date.getFullYear() - 2000}${date.getMonth()}${date.getDate()}`);
const patch = parseInt(`${date.getHours()}${date.getMinutes()}${date.getSeconds()}`);

if (isNaN(minor) || isNaN(patch)) 
{
    process.stdout.write(`Failed to set date input time: ${time}${EOL}`);
    process.exitCode = ExitCode.Failure;
    return;
}

output('version', `${major}.${minor}.${patch}`);
notice(`Version: ${major}.${minor}.${patch}`);