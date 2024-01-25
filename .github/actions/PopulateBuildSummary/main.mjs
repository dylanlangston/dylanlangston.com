import { validations } from './validations.mjs';

const mode = process.env.INPUT_MODE.toLowerCase();

validations.validateMode(mode);

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