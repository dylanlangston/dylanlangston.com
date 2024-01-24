module.exports = ({core}) => {
    const date = new Date(core.getInput('time', { required: true }));
    
    const major = 1;
    const minor = parseInt(`${date.getFullYear()-2000}${date.getMonth()}${date.getDate()}`);
    const patch = parseInt(`${date.getHours()}${date.getMinutes()}${date.getSeconds()}`);

    if (isNaN(minor) || isNaN(patch)) core.setFailed("Failed to set date input time: ${{ inputs.time }}");
    
    core.setOutput('version', `${major}.${minor}.${patch}`);
    core.notice(`Version: ${major}.${minor}.${patch}`);
};