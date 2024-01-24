import { summary } from './summary.mjs';

const version = process.env.INPUT_VERSION;
summary.addHeading(`DylanLangston.com - v${version}`);
summary.addSeparator();
summary.addRaw(`- Build Completed at ${new Date()}.`, true);
summary.write({overwrite: false});