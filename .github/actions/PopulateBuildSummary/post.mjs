import { summary } from './summary.mjs';
import { validations } from './validations.mjs';
import { js_common } from '../js_common.mjs';

// Inputs
let version = process.env.INPUT_VERSION;
const mode = process.env.INPUT_MODE.toLowerCase();
const runId = process.env.INPUT_RUNID;
let startTime = "Unknown";
try {
    const workFlowRun = await js_common.getWorkflowDetails(runId);
    startTime = JSON.parse(workFlowRun).run_started_at;
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

function OnPush() {
    summary.addHeading(`DylanLangston.com - ${version}`, 3);
    summary.addEOL();
}
function Test() {
    summary.addHeading(`🧪 Tests`, 3);
    summary.addEOL();

    summary.addRaw(`* Started at ${startTime}.`, true);
    summary.addRaw(`* Completed at ${new Date().toISOString()}.`, true);
}
function Build() {
    summary.addHeading(`🧰 Build`, 3);
    summary.addEOL();

    summary.addRaw(`* Started at ${startTime}.`, true);
    summary.addRaw(`* Completed at ${new Date().toISOString()}.`, true);
}
function Deploy() {
    summary.addHeading(`🚀 Deploy`, 3);
    summary.addEOL();

    summary.addRaw(`* Started at ${startTime}.`, true);
    summary.addRaw(`* Completed at ${new Date().toISOString()}.`, true);
}
function Release() {
    summary.addHeading(`📦 Release`, 3);
    summary.addEOL();

    summary.addRaw(`* Started at ${startTime}.`, true);
    summary.addRaw(`* Completed at ${new Date().toISOString()}.`, true);
}

// Start Main
switch (mode) {
    case "onpush":
        OnPush();
        break;
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