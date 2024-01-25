import { js_common } from '../js_common.mjs';

const token = process.env.INPUT_TOKEN;
const trigger = process.env.INPUT_TRIGGER;
const runId = process.env.INPUT_RUNID;

const workFlowRun = await js_common.getWorkflowDetails(runId);
const data = JSON.parse(workFlowRun);

js_common.notice(workFlowRun);

// Trigger workflow
js_common.notice(await js_common.triggerWorkflow(trigger, {
    'head_commit': data.head_commit
}, token));