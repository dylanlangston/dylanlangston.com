import { js_common } from '../js_common.mjs';

const availableModes = [
    "test",
    "build",
    "publish"
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
    validateVersion = (version) => {
        if (!semanticVersion.test(version)) {
            js_common.error(`Invalid "version" input: ${mode}`);
        }
    };
}

export const validations = new Validations();