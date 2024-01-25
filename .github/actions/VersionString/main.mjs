import { js_common } from '../js_common.mjs';

const time = process.env.INPUT_TIME;
const date = new Date(time);

const major = 1;
const minor = parseInt(`${date.getFullYear() - 2000}${date.getMonth()}${date.getDate()}`);
const patch = parseInt(`${date.getHours()}${date.getMinutes()}${date.getSeconds()}`);

if (isNaN(minor) || isNaN(patch)) 
{
    js_common.error(`Failed to set date from input "time": ${time}`)
}

js_common.output('version', `${major}.${minor}.${patch}`);
js_common.notice(`Version: ${major}.${minor}.${patch}`);