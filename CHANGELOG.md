# Changelog

## 1.0.0 -- 2025-09-30

- Update to latest stdlib (no longer uses `dynamic`)
- Update to latest gleeunit
    - gleeunit v1.6.0 added a timeout to the erlang runner
    - The vendored version used in this package does not use the timeout, which keeps the behavior the same as in the previous version of this package
    - See https://github.com/lpil/gleeunit/issues/51 for a discussion of the timeout

_Note: This version should be backwards compatible with the previous version._

## 0.1.0 -- 2024-05-05

- First release!
