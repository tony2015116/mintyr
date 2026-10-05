# mintyr <a href='https://tony2015116.github.io/mintyr/'><img src='man/figures/logo.svg' alt="mintyr package logo" width="120" align="right" /></a>

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/mintyr)](https://CRAN.R-project.org/package=mintyr)
[![CRAN total downloads](https://cranlogs.r-pkg.org/badges/grand-total/mintyr)](https://CRAN.R-project.org/package=mintyr)
[![Dev Version](https://img.shields.io/badge/devel%20version-0.2.0-purple.svg)](https://github.com/tony2015116/mintyr)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/tony2015116/mintyr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/tony2015116/mintyr/actions/workflows/R-CMD-check.yaml)
[![GitHub last commit](https://img.shields.io/github/last-commit/tony2015116/mintyr)](#)
<!-- badges: end -->

**mintyr turns "many groups × many variables" data into analysis-ready pieces — and back into files — with `data.table` speed and no surprises.**

A lot of real-world analysis follows the same loop: take a wide table, split it by trait and group, fit something on every piece (often with cross-validation), then write each piece or result to its own file or sheet. mintyr packages that loop into a small set of consistent functions:

```
 files ──► import ──► reshape & nest ──► cross-validate / summarise ──► export ──► files
          (xlsx/csv)   (by trait × group)      (per piece)          (txt/csv/xlsx)
```

It was born in animal breeding, where this loop is everywhere (multi-trait, multi-breed, multi-farm data feeding ASReml-R, HIBLUP or DMU), but nothing in it is specific to genetics.

## Who is it for?

| Field | Typical use |
|---|---|
| Animal & plant breeding | Per-trait / per-breed models, genetic correlations across traits or environments, input files for HIBLUP or DMU |
| Multi-site / multi-batch experiments | The same analysis for every site × variable, with results written back per site |
| Grouped machine learning | Reproducible (stratified) k-fold CV run separately within every subgroup |
| Reporting | Read dozens of Excel workbooks, clean them in one table, write them back to the original file/sheet layout |
| Any grouped analysis | Pairwise correlations between many variables, top/bottom-N% summaries per group |

## Installation

```r
# From CRAN
install.packages("mintyr")

# Development version from GitHub
pak::pak("tony2015116/mintyr")
```

## Quick start

Fit a model for every trait within every group, using 4-fold cross-validation, and export each subset to its own folder:

```r
library(mintyr)
library(data.table)

# 1. Wide -> long, nested by trait (`name`) and group (`am`)
nested <- w2l_nest(mtcars, cols = c("mpg", "qsec"), by = "am")
nested
#>    name am               data
#> 1:  mpg  1 <data.table[13x9]>
#> 2:  mpg  0 <data.table[19x9]>
#> 3: qsec  1 <data.table[13x9]>
#> 4: qsec  0 <data.table[19x9]>

# 2. Reproducible 4-fold CV inside every trait x group
cv <- nest_cv(nested, v = 4, seed = 2026)

# 3. Predictive ability per fold, then averaged
cv[, r := mapply(function(tr, va) {
  fit <- lm(value ~ wt + hp, data = tr)
  cor(predict(fit, va), va$value)
}, train, validate)]
cv[, .(mean_r = round(mean(r), 3)), by = .(name, am)]
#>    name am mean_r
#> 1:  mpg  1  0.816
#> 2:  mpg  0  0.881
#> 3: qsec  1  0.884
#> 4: qsec  0  0.858

# 4. One file per trait x group: <path>/<name>/<am>/data.txt
export_nest(nested, path = file.path(tempdir(), "by_trait"))
```

## What's inside

**Import and export — a lossless round trip**

| Function | What it does |
|---|---|
| `import_xlsx()` | Read many workbooks and sheets into one table, with `excel_name` / `sheet_name` source columns; optional parallel reading (`workers`) |
| `import_csv()` | Read many CSV/TXT files with `fread()`, with a source-file column |
| `export_xlsx()` | Write a table back to the original file/sheet layout, or a list of tables into one workbook or one file each |
| `export_nest()` | Write every nested table to `<path>/<group1>/<group2>/<column>.txt` |
| `export_list()` | Write every element of a named list to its own file (names may contain `/` for sub-folders) |

**Reshape and nest**

| Function | What it does |
|---|---|
| `w2l_nest()` / `w2l_split()` | Wide → long, then nest (list-column) or split (named list) by variable and group |
| `c2p_nest()` | All pairs (or triples, …) of variables, renamed to `value1`, `value2`, … for uniform pairwise analysis |
| `r2p_nest()` | Same variable across levels of another column (e.g. one column per environment), aligned by an ID |

**Cross-validation and summaries**

| Function | What it does |
|---|---|
| `split_cv()` / `nest_cv()` | Repeated, optionally stratified k-fold CV for a list of tables or a nested table; returns fold indices and (optionally) the subsets |
| `top_perc()` | Statistics of the top / bottom X% per variable and group |
| `format_digits()` | Format numeric columns for reports (decimals, percentages) |
| `get_path_info()` | Extract file names or path segments, cross-platform |

## Examples by use case

**Pairwise correlations between many variables, per group**

```r
pairs <- c2p_nest(mtcars, cols = c("mpg", "hp", "wt"), by = "am")
pairs[, .(r = sapply(data, function(d) cor(d$value1, d$value2))), by = .(pairs, am)]
```

**The same trait in different environments (e.g. genotype × environment)**

```r
# growth: one row per animal x farm
r2p_nest(growth, names_from = "farm", cols = c("adg", "backfat"), id = "animal")
# -> per trait: animal | farm1 | farm2, ready for a cross-environment correlation
```

**Clean many Excel files and put them back where they came from**

```r
dt <- import_xlsx(list.files("raw", pattern = "\\.xlsx$", full.names = TRUE))
dt <- dt[!is.na(weight)]                  # any data.table processing
export_xlsx(dt, path = "cleaned")         # same file names, same sheet names
```

**Input files for command-line breeding software**

```r
export_nest(nested, path = "hiblup_runs", na = "NA")       # HIBLUP
export_nest(nested, path = "dmu_runs", na = "-9999",       # DMU: numeric missing code,
            col.names = FALSE)                             #      no header
```

## Design principles

- **No side effects.** Your input objects are never modified by reference.
- **No silent data loss.** File names are sanitised; if two outputs would land on the same path, mintyr stops instead of overwriting. `r2p_nest()` refuses ambiguous IDs instead of returning counts.
- **Consistent arguments.** `data` is the input, `cols` are the columns to work on, `by` are grouping columns, `out_type` chooses `data.table` (`"dt"`) or `data.frame` (`"df"`), `path` is where files go.
- **Light dependencies.** `data.table`, `readxl`, `writexl` and base R; cross-validation is implemented in the package itself.
- **Reproducible.** `seed` makes CV folds reproducible without disturbing your global random-number stream.

## Upgrading from 0.1.x

Version 0.2.0 unifies argument names (`cols2l`, `cols2bind`, `trait`, `nest_dt`, `group_cols`, `export_path`, `rbind`, … → `cols`, `data`, `by`, `path`, `combine`, …); the old names are no longer accepted. Cross-validation no longer depends on rsample: the `splits` column is replaced by `train_idx` / `validate_idx`. See [NEWS](NEWS.md) for the complete old → new table.

## Cheat sheet

<a href='https://raw.githubusercontent.com/tony2015116/mintyr/main/man/figures/cheatsheet.svg' target="_blank"><img src='https://raw.githubusercontent.com/tony2015116/mintyr/main/man/figures/cheatsheet.svg' alt="mintyr package quick reference guide and cheatsheet" width="800" align="center" /></a>

## Acknowledgments

AI assistants helped turn the initial ideas behind mintyr into code, refine its structure and write its documentation.
