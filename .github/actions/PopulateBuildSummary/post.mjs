import { summary } from './summary.mjs';
import { validations } from './validations.mjs';
import { js_common } from '../js_common.mjs';

// Start Main
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

// Inputs
let version = process.env.INPUT_VERSION;
const mode = process.env.INPUT_MODE.toLowerCase();
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

// Validations
if (!validations.versionValid(version)) {
    version = "Unknown"
}
else {
    version = `v${version}`;
}
validations.validateMode(mode);

function Test() {
    summary.addRaw(`* Started at ${startTime}.`, true);
    summary.addRaw(`* Completed at ${new Date().toISOString()}.`, true);
}
function Build() {
    summary.addRaw(`* Started at ${startTime}.`, true);
    summary.addRaw(`* Completed at ${new Date().toISOString()}.`, true);
}
function Deploy() {
    summary.addRaw(`* Started at ${startTime}.`, true);
    summary.addRaw(`* Completed at ${new Date().toISOString()}.`, true);
}
function Release() {
    summary.addRaw(`* Started at ${startTime}.`, true);
    summary.addRaw(`* Completed at ${new Date().toISOString()}.`, true);
}

// Write the summary
summary.write({overwrite: false});