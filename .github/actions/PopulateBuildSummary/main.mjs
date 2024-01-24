import { summary } from './summary.mjs';

const version = process.env.INPUT_VERSION;
summary.addHeading(`DylanLangston.com - v${version}`);
summary.write({overwrite: true});