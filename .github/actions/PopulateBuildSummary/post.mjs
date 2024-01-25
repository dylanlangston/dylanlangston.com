import { summary } from './summary.mjs';
import { validations } from './validations.mjs';
import { js_common } from '../js_common.mjs';

// Inputs
let version = process.env.INPUT_VERSION;
const mode = process.env.INPUT_MODE.toLowerCase();
const runId = process.env.INPUT_RUNID;
const startTime = "Unknown";

try {
    const workFlowRun = await js_common.getWorkflowDetails(runId);
    console.log(workFlowRun);
    js_common.notice(workFlowRun);
    startTime = JSON.parse(workFlowRun).run_started_at;
}
catch (err) {
    console.log(err);
    js_common.notice(`Failed to fetch workflow run details: ${err}`);
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
    summary.addHeading(`🧪 DylanLangston.com - ${version}`);
    summary.addEOL();

    summary.addRaw(`* Test Started at ${startTime}.`, true);
    summary.addRaw(`* Test Completed at ${new Date().toISOString()}.`, true);
}
function Build() {
    summary.addHeading(`🧰 DylanLangston.com - ${version}`);
    summary.addEOL();

    summary.addRaw(`* Build Started at ${startTime}.`, true);
    summary.addRaw(`* Build Completed at ${new Date().toISOString()}.`, true);
}
function Publish() {
    summary.addHeading(`📦 DylanLangston.com - ${version}`);
    summary.addEOL();

    summary.addRaw(`* Publish Started at ${startTime}.`, true);
    summary.addRaw(`* Publish Completed at ${new Date().toISOString()}.`, true);
}

// Start Main
switch (mode) {
    case "test":
        Test();
        break;
    case "build":
        Build();
        break;
    case "publish":
        Publish();
        break;
    default:
        js_common.error(`Invalid Operation!`);
};

// Write the summary
summary.write({overwrite: false});