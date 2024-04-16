import { js_common } from '../js_common.mjs';

function parseDate(dateString) {
    if (!dateString) {
        return null;
    }
    
    if (!isNaN(dateString)) {
        return new Date(parseInt(dateString));
    }
    
    const isoRegex = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,3})?Z?$/;
    if (isoRegex.test(dateString)) {
        return new Date(dateString);
    }
    
    return null;
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
