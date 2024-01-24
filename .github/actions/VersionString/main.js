import { EOL } from 'os';
import fs from 'fs'

const issueCommand = (cmd) => process.stdout.write(`${cmd}${EOL}`);
const issueFileCommand = (command, message) => {
    const filePath = process.env[`GITHUB_${command.toUpperCase()}`]
    if (!filePath) throw new Error(`Unable to find environment variable for file command ${command}`);
    if (!fs.existsSync(filePath)) throw new Error(`Missing file at path: ${filePath}`);
  
    fs.appendFileSync(filePath, `${message}${EOL}`, { encoding: 'utf8' });
}

const output = (name, value) => issueFileCommand("output", `${name}=${value}`);
const notice = (value) => issueCommand(`::notice::${value}`);
const error = (value) => issueCommand(`::error::${value}`);

const time = process.env.INPUT_TIME;
const date = new Date(time);

const major = 1;
const minor = parseInt(`${date.getFullYear() - 2000}${date.getMonth()}${date.getDate()}`);
const patch = parseInt(`${date.getHours()}${date.getMinutes()}${date.getSeconds()}`);

if (isNaN(minor) || isNaN(patch)) 
{
    const errorText = `Failed to set date from input "time": ${time}`;
    error(errorText)
    throw new Error(errorText);
}

output('version', `${major}.${minor}.${patch}`);
notice(`Version: ${major}.${minor}.${patch}`);