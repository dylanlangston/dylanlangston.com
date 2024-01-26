import { js_common } from '../js_common.mjs';

const availableModes = [
    "onpush",
    "automerge",
    "test",
    "build",
    "deploy",
    "release",
];

const semanticVersion = /^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$/g;

class Validations {
    validateMode = (mode) => {
        if (!availableModes.some(m => m == mode))
        {
            js_common.notice(`Valid Modes are: "${availableModes.join("\", \"")}"`);
            js_common.error(`Unknown "mode" input: ${mode}`);
        }
    };
    versionValid = (version) => semanticVersion.test(version);
}

export const validations = new Validations();