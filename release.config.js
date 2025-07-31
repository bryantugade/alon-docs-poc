module.exports = {
  branches: ['main'],
  plugins: [
    '@semantic-release/commit-analyzer',
    '@semantic-release/release-notes-generator',
    '@semantic-release/changelog',
    [
      '@semantic-release/exec',
      {
        prepareCmd: 'node scripts/update-version.js ${nextRelease.version}',
        // publishCmd: 'node scripts/create-site-zip.js'
      }
    ],
    [
      '@semantic-release/git',
      {
        assets: ['CHANGELOG.md', 'version.txt'],
        message: 'chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}'
      }
    ],
    // [
    //   '@semantic-release/github',
    //   {
    //     assets: [
    //       { path: 'site.zip', label: 'Built Hugo Site' }
    //     ]
    //   }
    // ]
  ],
  tagFormat: 'v${version}'
};
