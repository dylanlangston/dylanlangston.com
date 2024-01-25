import { summary } from './summary.mjs';
import { js_common } from '../js_common.mjs';

// Start Main
const mode = process.env.INPUT_MODE.toLowerCase();
switch (mode) {
    case "onpush":
    case "automerge":
        process.exit(0); // Exit no error
    case "test":
        Test();
        break;
    case "build":
        Build();
        break;
    case "deploy":
        Deploy();
        break;
    case "release":
        Release();
        break;
    default:
        js_common.error(`Invalid Operation!`);
};

// Write the summary
summary.write({overwrite: false});

async function getStartTime() {
    const runId = process.env.INPUT_RUNID;
    let startTime = "Unknown";
    try {
        const workflowJobs = JSON.parse(await js_common.getWorkflowJobsDetails(runId));
        const currentJob = workflowJobs.jobs.filter(j => j.status == "in_progress")[0];
        startTime = currentJob.started_at;
    }
    catch (err) {
        js_common.error(`Failed to fetch workflow run details: ${err}`);
    }
}

async function Test() {
    summary.addRaw(`* Started at ${await getStartTime()}.`, true);
    summary.addRaw(`* Completed at ${new Date().toISOString()}.`, true);
}
async function Build() {
    summary.addRaw(`* Started at ${await getStartTime()}.`, true);
    summary.addRaw(`* Completed at ${new Date().toISOString()}.`, true);
}
async function Deploy() {
    summary.addRaw(`* Started at ${await getStartTime()}.`, true);
    summary.addRaw(`* Completed at ${new Date().toISOString()}.`, true);
}
async function Release() {
    summary.addRaw(`* Started at ${await getStartTime()}.`, true);
    summary.addRaw(`* Completed at ${new Date().toISOString()}.`, true);
}