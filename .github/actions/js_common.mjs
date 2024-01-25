import { EOL } from 'os';
import https from 'https';
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


    fetch = async (URL) => new Promise((resolve, reject) => {
        const responseHandler = (res) => {
            let data = "";
            res.on("data", (chunk) => {
                data += chunk;
            });
            res.on("end", () => {
                resolve(data);
            });
            res.on("error", (err) => {
                reject(err.message);
            });
        };

        const options = {
            headers: { "User-Agent": "dylanlangston.com github actions" }
        };

        https.get(URL, options, responseHandler);
    });

    getWorkflowDetails = async (runId) => await this.fetch(`https://api.github.com/repos/dylanlangston/dylanlangston.com/actions/runs/${runId}`);
}

export const js_common = new JS_Common();