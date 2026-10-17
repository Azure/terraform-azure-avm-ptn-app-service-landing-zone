# Tests

Run `pwsh -NoProfile -File tests/scripts/build-sample-app.tests.ps1 -WorkingDirectory <temporary-directory>` with Avm.Authoring available to check the sample-app packaging hook without Azure access. The test downloads the pinned upstream project, checks the archive and repeated execution, and verifies cleanup and archive preservation after a failed fetch.

The authored checksum and precondition from every zip-deployment example are evaluated in a plan-only Terraform harness with the built-in provider explicitly mocked and mapped in every run. Validation must succeed without an archive, planning must reject a missing archive, and the checksum must match the genuine packaged bytes. This does not claim Azure deployment or module-unit coverage.
