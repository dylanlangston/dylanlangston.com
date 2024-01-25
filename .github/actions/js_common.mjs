import { EOL } from 'os';
import fs from 'fs'

class JS_Common {
    issueCommand = (cmd) => process.stdout.write(`${cmd}${EOL}`);
    issueFileCommand = (command, message) => {
        const filePath = process.env[`GITHUB_${command.toUpperCase()}`]
        if (!filePath) throw new Error(`Unable to find environment variable for file command ${command}`);
        if (!fs.existsSync(filePath)) throw new Error(`Missing file at path: ${filePath}`);
    
        fs.appendFileSync(filePath, `${message}${EOL}`, { encoding: 'utf8' });
    }

    output = (name, value) => this.issueFileCommand("output", `${name}=${value}`);
    notice = (value) => this.issueCommand(`::notice::${value}`);
    error = (value) => {
        this.issueCommand(`::error::${value}`);
        throw new Error(value);
    }
}

export const js_common = new JS_Common();