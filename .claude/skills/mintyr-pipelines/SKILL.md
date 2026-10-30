---
name: mintyr-pipelines
description: Run grouped / nested data pipelines with the R package mintyr - batch-import Excel/CSV, reshape and nest by trait x group, k-fold cross-validation within groups, descriptive statistics, and export input files for HIBLUP, DMU or ASReml-R.
---

# mintyr grouped data pipelines

mintyr (>= 0.2.1) is an R package built on data.table that packages the usual "many groups x many variables" loop into a small set of functions:

```
files ─► import ─► reshape & nest ─► cross-validate / summarise ─► export ─► files
```

Use it when the user uploads several Excel/CSV files to combine and clean; fits the same model per trait / breed / farm; needs cross-validation inside every group; wants descriptive statistics by group (e.g. "mean ± SD" report tables); needs phenotype files for HIBLUP, DMU or ASReml-R; or wants data written back to the original file / sheet layout.

## 1. Set up the environment (once per session)

Check first:

```bash
Rscript -e 'library(mintyr); cat(as.character(packageVersion("mintyr")))'
```

If this prints 0.2.1 or later, go to step 2. Otherwise try, in order:

1. **CRAN reachable**: `Rscript -e 'install.packages("mintyr", repos = "https://cloud.r-project.org")'`
2. **CRAN blocked, but apt and GitHub reachable (common in Ubuntu / Debian sandboxes)**:
   ```bash
   export DEBIAN_FRONTEND=noninteractive
   apt-get update -qq
   apt-get install -y -qq --no-install-recommends r-base-core r-cran-data.table r-cran-readxl r-cran-writexl
   git clone --depth 1 https://github.com/tony2015116/mintyr /tmp/mintyr-src
   R CMD INSTALL --no-docs /tmp/mintyr-src
   ```
   The apt step takes a few minutes; use a long command timeout.
3. If neither works, tell the user that R packages cannot be installed here and that access to CRAN or GitHub must be allowed. Do not imitate mintyr's results with hand-written code from other packages.

Run R with `LANG=C.UTF-8` (or `Sys.setlocale("LC_CTYPE", "C.UTF-8")`); otherwise `±` and non-ASCII text print as escape sequences.

## 2. How to work

- Write the R code to a script file (e.g. `analysis.R`) and run it with `Rscript analysis.R`; hand the script to the user with the results so the analysis can be rerun.
- Copy uploaded files into the working directory before processing; never modify the originals.
- Inspect the data first (`str()`, `names()`, `head()`) before choosing `cols` and `by`. If it is unclear which columns are traits, ask the user rather than guess.
- Deliver result tables as files (`export_xlsx()` or `fwrite()`) and summarise the outcome in a sentence or two.

## 3. Shared argument conventions

| Argument | Meaning |
|---|---|
| `data` | input table or list; never modified by reference |
| `cols` | columns to work on, as names or indices |
| `by` | grouping column(s) |
| `out_type` | `"dt"` (data.table, default) or `"df"` (data.frame, needed by ASReml-R) |
| `path` | output location; missing folders are created |
| `seed` | reproducible CV folds without disturbing the global RNG |

The 0.1.x argument names (`cols2l`, `cols2bind`, `nest_dt`, `group_cols`, `rows2bind`, ...) were removed; do not use them. Cross-validation results have no `splits` column; they have `train_idx` / `validate_idx` and `train` / `validate`.

## 4. Pick the function for the task

### Import

```r
import_xlsx(file, combine = TRUE, sheet = NULL, skip = 0, header_rows = 1,
            header_sep = "_", header_fill = "auto", file_col = "excel_name",
            sheet_col = "sheet_name", path_col = NULL, workers = 1,
            verbose = FALSE, on_error = "stop", ...)
import_csv(file, combine = TRUE, file_col = "_file", path_col = NULL,
           full_path = FALSE, keep_ext = FALSE, ...)
```

- Reads every sheet of every workbook into one table, adding source columns `excel_name` / `sheet_name`.
- Title row above the header: `skip = 1`. Two-row header (merged cells): `header_rows = 2`.
- Possibly broken files: `on_error = "warn"` skips them with one warning.
- Folder names carry information (farm / year / batch): `path_col = "file_path"`, then `get_path_info(file_path, n = -3)` etc.
- A column whose type differs between sources is combined as text with a warning; pass such warnings on to the user.

### Reshape and nest

```r
w2l_nest(data, cols = NULL, by = NULL, out_type = "dt")       # -> name | by... | data (list-column)
w2l_split(data, cols = NULL, by = NULL, out_type = "dt", sep = "_")  # -> named list "mpg_0", ...
c2p_nest(data, cols, by = NULL, pairs_n = 2, sep = "-", out_type = "dt")  # all pairs -> value1, value2
r2p_nest(data, names_from, cols, out_type = "dt", id = NULL)  # one trait across environments, aligned by id
```

- In long data the values are in `value` and the trait name in `name`.
- Always give `r2p_nest()` an explicit `id`; if `id + names_from` is not unique it stops, and the duplicated records should be reported to the user.

### Cross-validation

```r
nest_cv(data, v = 10, repeats = 1, strata = NULL, breaks = 4, pool = 0.1,
        seed = NULL, materialize = TRUE, out_type = "dt")   # nested table input
split_cv(...)                                                # same arguments, list-of-tables input
```

Always set `seed`. For large data use `materialize = FALSE` (row indices only). Typical use:

```r
nested <- w2l_nest(dat, cols = c("adg", "bf"), by = "breed")
cv <- nest_cv(nested, v = 5, seed = 2026)
cv[, r := mapply(function(tr, va) {
  fit <- lm(value ~ sex + parity, data = tr)
  cor(predict(fit, va), va$value)
}, train, validate)]
cv[, .(mean_r = mean(r), sd_r = sd(r)), by = .(name, breed)]
```

### Descriptive statistics

```r
desc_stats(data, cols = NULL, by = NULL, type = "common", stats = NULL,
           total = FALSE, total_label = "Total", min_n = 1,
           probs = c(0, .25, .5, .75, 1), conf_level = 0.95, na_rm = TRUE,
           digits = NULL, fmt = NULL, labels = NULL, shape = "long",
           sep = "_", out_type = "dt")
```

- `type`: `"common"`, `"full"`, `"mean_sd"`, `"mean_se"`, `"mean_ci"`, `"median_iqr"`, `"median_mad"`, `"robust"`, `"five_number"`, `"quantile"`, `"mean"`, `"median"`.
- Report table: `fmt = "{mean} ± {sd}", total = TRUE, shape = "wide"`. Placeholders: `{sd:1}` sets decimals, `{cv:1%}` gives a percentage, `{q2.5}` a percentile.
- Count table with totals: `stats = "n", total = TRUE, shape = "wide"`.
- Small groups: `min_n = 3` keeps n and sets the other statistics to NA.
- Display names: `labels = c(adg = "ADG (g)")`; per-variable decimals: `digits = c(2, adg = 0)`.

```r
top_perc(data, perc, cols, by = NULL, keep_data = FALSE,
         stats = c("n","min","max","mean","median","sd","se","cv"))  # perc = 0.1 top 10%, -0.1 bottom 10%
format_digits(data, cols = NULL, digits = 2, percentage = FALSE, nan_as_na = FALSE)
```

### Export

```r
export_xlsx(data, path, file_col = "excel_name", sheet_col = "sheet_name",
            sheet_name = "Sheet1", drop_cols = TRUE, overwrite = TRUE, verbose = FALSE)
export_nest(data, by = NULL, cols = NULL, path = tempdir(), file_type = "txt",
            na = "NA", quote = FALSE, ...)   # path/<by1>/<by2>/<column>.txt
export_list(data, path = tempdir(), file_type = "txt", na = "NA", quote = FALSE, ...)
```

- A table with `excel_name` / `sheet_name` passed to `export_xlsx()` is written back to the original files and sheets; a list with `path = "out.xlsx"` becomes one workbook with one sheet per element.
- Drop the `path_col` column before `export_xlsx()`.
- All three return the written file paths invisibly; use them to list the delivered files.

Input files for breeding software:

```r
export_nest(nested, path = "hiblup_runs")                                   # HIBLUP: header, NA
export_nest(nested, path = "dmu_runs", na = "-9999", col.names = FALSE)     # DMU: numeric missing code, no header
cv <- nest_cv(nested, v = 5, seed = 1, out_type = "df")                     # ASReml-R: data.frame subsets
```

### Utilities

```r
get_path_info(path, n = NULL, rm_extension = TRUE, rm_path = TRUE)
# p <- "D:/data/farmA/2025/pigs.xlsx"
# get_path_info(p) -> "pigs"; n = 1 -> "data" (drive letter is not a segment); n = -3 -> "farmA"; n = c(-3, -2) -> "farmA/2025"
mintyr_examples("xlsx"); mintyr_example("xlsx_test1.xlsx")   # example files shipped with the package
```

## 5. Check before delivering

- Row counts: after import, the total equals the sum over files; after nesting, the group sizes add up to the original data.
- Pass mintyr's warnings (type conflicts, skipped files, duplicated ids, ...) on to the user verbatim.
- Open the exported files and confirm columns and missing-value codes match what the target software expects.
- When unsure how an argument behaves, check the installed version with `?function` or `args(function)` instead of relying on memory.

References: cheat sheet https://tony2015116.github.io/mintyr/cheatsheet.html , function reference https://tony2015116.github.io/mintyr/reference/
