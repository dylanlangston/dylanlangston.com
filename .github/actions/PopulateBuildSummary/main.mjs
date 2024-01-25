import { validations } from './validations.mjs';

const mode = process.env.INPUT_MODE.toLowerCase();

validations.validateMode(mode);