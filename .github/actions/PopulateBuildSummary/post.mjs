import { summary } from './summary.mjs';

const version = process.env.INPUT_VERSION;
summary.addHeading(`🧰 DylanLangston.com - v${version}`);
summary.addRaw(`* Build Completed at ${new Date().toISOString()}.`, true);
summary.write({overwrite: false});