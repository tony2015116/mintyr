# mintyr 0.2.0

## New features

* New `desc_stats()`: descriptive statistics by group (presets as in
  `rstatix::get_summary_stats()`, plus `cv`, `skew`, `kurt`, `ci_low` /
  `ci_high`), an optional total row (counts add up, statistics use all
  records), `min_n`, per-variable `digits`, `labels`, report-ready text via
  `fmt = "{mean} ± {sd}"` and a wide report layout (`shape = "wide"`).
  Computed column by column with data.table's grouped functions: about a
  second for a million records in 20,000 groups.
* `import_xlsx()` reads multi-row headers (`header_rows`, `header_sep`),
  using the merged cells stored in .xlsx files (`header_fill`), accepts
  sheet names in `sheet`, and can skip unreadable files / sheets
  (`on_error = "warn"`).

## Breaking changes

* `top_perc()` now computes its statistics with the same engine as
  `desc_stats()`: columns are lower case (`n`, `min`, `max`, `mean`,
  `median`, `sd`, `se`, `cv`), the CV is `NA` unless all selected values are
  positive, and a new `stats` argument chooses the statistics.

* `split_cv()` and `nest_cv()` no longer depend on 'rsample'. Folds are built
  with base R / 'data.table'. The `splits` column (rsample `rsplit` objects)
  is replaced by `train_idx` / `validate_idx` (row indices); `...` is no
  longer forwarded. New arguments `seed` (reproducible folds without
  disturbing the RNG stream), `materialize` (`FALSE` keeps only indices) and
  `out_type` (`"df"` returns `train` / `validate` as plain data.frames, e.g.
  for ASReml-R).
* `export_nest()` now returns the written file paths (invisibly) instead of a
  count, consistent with `export_list()` and `export_xlsx()`.
* `export_nest()` stops when the grouping columns do not identify rows
  uniquely (files would overwrite each other) or name unknown columns.
* `export_nest()` / `export_list()` write missing values as `NA` and do not
  quote fields by default (`na`, `quote` and `...` are passed to `fwrite()`).
* `r2p_nest()` gains `id`; it stops instead of silently returning counts
  when `id` + `names_from` do not identify rows uniquely.
* `get_path_info(rm_path = FALSE)` keeps the root (`/`, `C:/`, `//`).

## Unified argument names

The old argument names have been removed; code written for 0.1.x must be
updated (calls with old names now fail with "unused argument").

| Function(s) | Old | New |
|---|---|---|
| `nest_cv()`, `split_cv()`, `export_nest()`, `export_list()` | `nest_dt`, `split_dt` | `data` |
| `w2l_nest()`, `w2l_split()` | `cols2l` | `cols` |
| `c2p_nest()` | `cols2bind` | `cols` |
| `r2p_nest()` | `rows2bind`, `by` | `names_from`, `cols` |
| `export_nest()` | `nest_cols`, `group_cols` | `cols`, `by` |
| `top_perc()` | `trait` | `cols` |
| `w2l_nest()`, `w2l_split()`, `c2p_nest()`, `r2p_nest()` | `nest_type`, `split_type` | `out_type` |
| `export_nest()`, `export_list()` | `export_path` | `path` |
| `get_path_info()` | `paths` | `path` |
| `import_csv()`, `import_xlsx()` | `rbind` | `combine` |
| `import_csv()` | `rbind_label` | `file_col` |
| `import_xlsx()` | `show_excel_name`, `show_sheet_name` (logical) | `file_col`, `sheet_col` (column name, `NULL` to omit) |

## Bug fixes

* Fixed a bug in `export_xlsx()`.
* `w2l_nest()` / `w2l_split()` no longer turn the caller's data.frame into a
  data.table by reference.
* `w2l_split(sep = )` works on every data.table version.
* `split_cv()` / `export_list()` reject a single data.frame.
* `import_xlsx()`: tables returned by parallel workers get a valid
  self-reference; duplicated base names are warned about and made unique.
* `import_csv()`: dots in directory names are no longer taken for an
  extension.
* `export_list()` / `export_nest()` sanitise path components.
* `export_xlsx()` rejects `.xls`/`.xlsm` paths and sheets above Excel's row
  limit.
* `top_perc()` keeps groups too small to select any record (`N = 0`, with a
  warning); `format_digits()` validates `digits` before using it.

## Other

* Regression tests for all functions.

# mintyr 0.1.3

* removed `convert_nest()`.
* combined `get_filename()` and `get_path_segment()` to `get_path_info()`.
* add `export_xlsx()`.
* Focus on data.table and minimize external dependencies.

# mintyr 0.1.2

* Fixed bug in `convert_nest()`.

# mintyr 0.1.1

* Removed function `nedaps()` and `fires()` due to low usage.
* Removed example dataset `nedap` and `fire`.
* Fixed bug in `export_nest()`.

# mintyr 0.1.0

* Initial CRAN submission.
