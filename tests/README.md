# Tests

Run `pwsh -NoProfile -File tests/scripts/build-sample-app.tests.ps1 -WorkingDirectory <temporary-directory>` to check the sample-app packaging hook without Azure access. The test downloads the pinned upstream project, checks the archive and repeated execution, and verifies cleanup and archive preservation after a failed fetch.
