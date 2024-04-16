import { js_common } from '../js_common.mjs';

function parseDate(input) {
    let date;
    if (!input) {
        date = new Date();
    } else if (!isNaN(input)) {
        date = new Date(parseInt(input) * 1000);
    } else {
        date = new Date(input);
    }
    return date;
}

const time = process.env.INPUT_TIME;
const date = parseDate(time);

function pad(value) {
    return new String(value).padStart(2, "0")
}

const major = 1;
const minor = parseInt(`${pad(date.getFullYear() - 2000)}${pad(date.getMonth())}${pad(date.getDate())}`);
const patch = parseInt(`${pad(date.getHours())}${pad(date.getMinutes())}${pad(date.getSeconds())}`);

if (isNaN(minor) || isNaN(patch)) 
{
    js_common.error(`Failed to set date from input "time": ${time}`)
}

const version = `${major}.${minor}.${patch}`;

js_common.output('version', version);
js_common.notice(`Version: ${version}`);
