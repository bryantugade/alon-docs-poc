const fs = require('fs');
const archiver = require('archiver');

const output = fs.createWriteStream('site.zip');
const archive = archiver('zip', {
  zlib: { level: 9 }
});

output.on('close', function () {
  console.log(archive.pointer() + ' total bytes');
  console.log('site.zip has been finalized.');
});

archive.on('error', function(err){
  throw err;
});

archive.pipe(output);
archive.directory('public/', false);
archive.finalize();
