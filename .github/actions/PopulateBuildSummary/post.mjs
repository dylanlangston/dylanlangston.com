import { summary } from './summary.mjs';
import { validations } from './validations.mjs';
import { js_common } from '../js_common.mjs';

const version = process.env.INPUT_VERSION;
const mode = process.env.INPUT_MODE.toLowerCase();

validations.validateVersion(version);
validations.validateMode(mode);

function Test() {
    summary.addRaw(`* Test Completed at ${new Date().toISOString()}.`, true);
}

function Build() {
    summary.addRaw(`* Build Completed at ${new Date().toISOString()}.`, true);
}

function Publish() {
    summary.addRaw(`* Publish Completed at ${new Date().toISOString()}.`, true);
}

// Heading
summary.addHeading(`🧰 DylanLangston.com - v${version}`);
summary.addEOL();

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