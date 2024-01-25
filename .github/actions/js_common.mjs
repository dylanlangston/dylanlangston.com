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

    getWorkflowDetails = (runId, callback) => {
        let url = `https://api.github.com/repos/dylanlangston/dylanlangston.com/actions/runs/${runId}`;

        https.get(url,(res) => {
            let body = "";
        
            res.on("data", (chunk) => {
                body += chunk;
            });
        
            res.on("end", () => {
                try {
                    let json = JSON.parse(body);
                    callback(json);
                } catch (error) {
                    this.error(error.message);
                };
            });
        }).on("error", (error) => {
            this.error(error.message);
        });
    };
}

export const js_common = new JS_Common();