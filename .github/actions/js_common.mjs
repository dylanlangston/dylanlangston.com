import { EOL } from 'os';
import https from 'https';
import fs from 'fs'

const repo = 'dylanlangston/dylanlangston.com';

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
            if (res.statusCode < 200 || res.statusCode > 299) {
                return reject(new Error(`HTTP status code ${res.statusCode}`))
            }

            let data = "";
            res.on('data', (chunk) => data += chunk);
            res.on('end', () => resolve(data));
            res.on('error', (err) => reject(err.message));
        };

        const options = {
            headers: { 
                'User-Agent': `${repo} github actions` 
            }
        };

        https.get(URL, options, responseHandler);
    });

    post(url, token, dataString) {
        const options = {
            method: 'POST',
            headers: {
                'User-Agent': `${repo} github actions`,
                'Accept': 'application/vnd.github.everest-preview+json',
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`,
                'Content-Length': dataString.length,
            },
            timeout: 1000, // in ms
        }

        return new Promise((resolve, reject) => {
            const req = https.request(url, options, (res) => {
                if (res.statusCode < 200 || res.statusCode > 299) {
                    return reject(new Error(`HTTP status code ${res.statusCode}`))
                }

                let data = "";
                res.on('data', (chunk) => data += chunk)
                res.on('end', () => resolve(data));
                res.on('error', (err) => reject(err.message));
            });

            req.on('error', (err) => reject(err));

            req.on('timeout', () => {
                req.destroy();
                reject(new Error('Request time out'));
            });

            req.write(dataString);
            req.end();
        })
    }

    getWorkflowDetails = async (runId) => await this.fetch(`https://api.github.com/repos/${repo}/actions/runs/${runId}`);
    getWorkflowJobsDetails = async (runId) => await this.fetch(`https://api.github.com/repos/${repo}/actions/runs/${runId}/jobs`);
    getJobDetails = async (jobId) => await this.fetch(`https://api.github.com/repos/${repo}/actions/jobs/${jobId}`);

    triggerWorkflow = async (type, body, token) => {
        const url = `https://api.github.com/repos/${repo}/dispatches`;
        const data = {
            'event_type': type,
            "client_payload": body
        };
        return await this.post(url, token, JSON.stringify(data));
    };
}

export const js_common = new JS_Common();