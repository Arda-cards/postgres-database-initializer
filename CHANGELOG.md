# changelog

[![Keep a Changelog](https://img.shields.io/badge/Keep%20a%20Changelog-1.0.0-informational)](https://keepachangelog.com/en/1.0.0/)
[![Semantic Versioning](https://img.shields.io/badge/Sematic%20Versioning-2.0.0-informational)](https://semver.org/spec/v2.0.0.html)
![clq validated](https://img.shields.io/badge/clq-validated-success)

Keep the newest entry at top, format date according to ISO 8601: `YYYY-MM-DD`.

Categories, defined in [changemap.json](.github/clq/changemap.json):

- *major* release trigger:
  - `Changed` for changes in existing functionality.
  - `Removed` for now removed features.
- *minor* release trigger:
  - `Added` for new features.
  - `Deprecated` for soon-to-be removed features.
- *bugfix* release trigger:
  - `Fixed` for any bugfixes.
  - `Security` in case of vulnerabilities.

## [2.2.0-dna-15] - 2025-05-04

### Added

- Optional command `up`, `down`, where `down` tears down the database.

### Fixed

- Handle passwords with `=`.
- Verbose, fails on error.
- Better test cases.
- Fix the CI badge to only reflect builds on the main branch.

## [2.1.0] - 2025-04-29

### Added

- The pgenv file is the preferred alternative to `.pgpass` file when user of password contains characters that must be quoted.

### Fixed

- In the `.pgpass`, if an entry needs to contain : or \, escape this character with \.
- Quotes all SQL identifiers.
- Parse the values file, do not source it

## [2.0.0] - 2025-04-24

### Changed

- The container now accepts only `key=values` property files instead of a psql command file.

### Fixed

- Extracted the test sequence to `tests.sh` got local and remote execution
- Silently ignore failure to make `.pgpass` read-only; while this is required for docker-compose, this is not needed for k8s 
- Install only the postgres client package on a fresh alpine:3.22 image and reduce the image size from 358 to 22MB
- The database role is now always set to the concatenation of the database name with `_role`
- Ensure that images are published only on main or on a feature branch with a feature branch version

## [1.0.0] - 2025-04-22

### Added

- Initial release
