## Update

This is an update from 0.1.3 (current CRAN version) to 0.2.0.

* Breaking changes: argument names were unified across functions
  (e.g. `cols2l` / `cols2bind` / `trait` -> `cols`); NEWS.md lists every
  old -> new name.
* Removed the dependency on 'rsample'; cross-validation is now implemented
  with base R and 'data.table'.
* New function `desc_stats()`; `import_xlsx()` gains multi-row headers.
* Title and Description were updated to reflect the broader scope.

## Test environments

* local: Windows 11, R 4.6.1
* win-builder: R-devel
* GitHub Actions: ubuntu-latest, macos-latest, windows-latest (R-release)

## R CMD check results

0 errors | 0 warnings | 0 notes

## Reverse dependencies

There are currently no reverse dependencies.
