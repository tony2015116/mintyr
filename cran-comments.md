## Update

This is a patch release (0.2.0 -> 0.2.1) that fixes bugs in
`import_xlsx()` / `import_csv()`:

* Combining sheets/files with `combine = TRUE` no longer fails when a column
  is empty or has a different type in some sources.
* `import_xlsx()` now guesses column types from all rows, so columns empty in
  the first 1000 rows are no longer read as logical with data lost.
* Parallel reading in `import_xlsx(workers > 1)` now uses load balancing.

## R CMD check results

0 errors | 0 warnings | 0 notes

## Test environments

* local: [Windows 11], R [4.5.x]
* win-builder: R-devel, R-release
* R-hub: ubuntu-latest, macos-latest, windows-latest (R-devel)

## Reverse dependencies

There are currently no reverse dependencies on CRAN.
