## Update

This is a patch release (0.2.1 -> 0.2.2) with bug fixes:

* `top_perc()` no longer selects one record too few because of
  floating-point rounding (e.g. top 29% of 100 records).
* Clear errors instead of duplicated / overwritten columns when input column
  names clash with names created by `nest_cv()`, `w2l_split()`,
  `import_csv()`, `import_xlsx()`, `desc_stats()` and `top_perc()`.
* Minor formatting fixes (`"-0.00"` shown as `"0.00"`).

## R CMD check results

0 errors | 0 warnings | 0 notes

## Test environments

* local: [Windows 11], R [4.5.x]
* win-builder: R-devel, R-release
* R-hub: ubuntu-latest, macos-latest, windows-latest (R-devel)

## Reverse dependencies

There are currently no reverse dependencies on CRAN.
