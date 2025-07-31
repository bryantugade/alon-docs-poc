const fs = require('fs');
const version = process.argv[2];

if (!version) {
  console.error("No version argument passed.");
  process.exit(1);
}

fs.writeFileSync('version.txt', version);
console.log(`Updated version.txt to ${version}`);
