// This can be called by C/C++ code
function saveFileFromMEMFSToDisk(memoryFSname, localFSname) {
	const data = FS.readFile(memoryFSname);
	const blob = new Blob([data.buffer], { type: 'application/octet-binary' });

	const blobUrl = URL.createObjectURL(blob);

	const link = document.createElement('a');
	link.href = blobUrl;
	link.target = '_blank';
	link.download = localFSname;
	link.click();
}