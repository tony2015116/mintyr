# mintyr <a href='https://tony2015116.github.io/mintyr/'><img src='man/figures/logo.svg' alt="mintyr package logo" width="120" align="right" />
<!--apple-touch-icon-120x120.png-->
<!-- <picture><source srcset="reference/figures/apple-touch-icon-120x120.png" media="(prefers-color-scheme: dark)"></picture> -->

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/mintyr)](https://CRAN.R-project.org/package=mintyr)
[![CRAN total downloads](https://cranlogs.r-pkg.org/badges/grand-total/mintyr)](https://CRAN.R-project.org/package=mintyr)
[![Dev Version](https://img.shields.io/badge/devel%20version-0.1.3.9000-purple.svg)](https://github.com/tony2015116/mintyr)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/tony2015116/mintyr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/tony2015116/mintyr/actions/workflows/R-CMD-check.yaml)
[![GitHub last commit](https://img.shields.io/github/last-commit/tony2015116/mintyr)](#)
<!-- badges: end -->

<!--[![CodeFactor](https://www.codefactor.io/repository/github/tony2015116/mintyr/badge/main)](https://www.codefactor.io/repository/github/tony2015116/mintyr/overview/main)
[![GitHub R package version](https://img.shields.io/github/r-package/v/tony2015116/mintyr)](#)-->

`mintyr` is a high-performance data processing toolkit designed specifically for **animal breeding and genomic selection**. Leveraging the zero-copy and multi-threading capabilities of `data.table`, it significantly simplifies the construction of automated data pipelines in large-scale commercial breeding programs (e.g., coordinating data across nucleus and multiplier farms, or handling multi-trait growth test records).

The package is not only highly optimized for iterative analysis workflows with the `ASReml-R` package (supporting dynamic modeling and multi-trait/multi-breed nested grouping), but is also capable of generating and batch-exporting formatted phenotypic data files required for automated pipeline analyses in other mainstream command-line breeding software (e.g., HIBLUP, DMU).

## ✨ Key Features

`mintyr` covers five critical stages in the lifecycle of breeding data analysis:

**🚀 High-Performance Data Importing (`import_xlsx`, `import_csv`)**
- Native support for merging multiple files and sheets simultaneously.
- Automatically appends source tracking columns (`excel_name`, `sheet_name`) to prevent data confusion across different farms or batches.
- Utilizes OpenMP multi-threading and in-place `data.table` conversion for a minimal memory footprint.

**🔄 Automated Data Reshaping & Nesting (`w2l_nest`, `c2p_nest`, `r2p_nest`)**
- `c2p_nest`: Column-to-pairs nested transformation that automatically renames feature columns, providing standard uniform inputs for iterative multi-trait genetic correlation evaluations.
- `w2l_nest` / `w2l_split`: Wide-to-long format transformations with subsetting and nesting by grouping variables (e.g., farm, breed, or line).

**🧪 Cross-Validation & Model Evaluation (`split_cv`, `nest_cv`)**
- Provides streamlined k-fold cross-validation and repeated CV splitting tailored for nested `data.table` structures, facilitating the evaluation of breeding value prediction accuracy (GP).

**📊 Batch Exporting for Breeding Software (`export_nest`, `export_list`)**
- Automatically builds local folder hierarchies and batch-exports data based on nested groups or list structures (e.g., `tempdir()/Line/Breed/data.txt`), providing seamless text-file preparation to bridge the gap with command-line driven breeding evaluation software like HIBLUP and DMU.

**🛠️ Phenotypic Statistics & Preprocessing (`top_perc`, `format_digits`, `get_path_info`)**
- Quickly extracts the top N% performing individuals for specific traits, supporting independent extraction by analytical groups (e.g., different test batches), alongside robust number formatting and path-parsing utilities.

## 📥 Installation
You can install this package from either CRAN or GitHub:
``` r
### From CRAN
install.packages("mintyr")
### From GitHub
pak::pak("tony2015116/mintyr")
```
## 📋️ Cheat Sheet
<a href='https://raw.githubusercontent.com/tony2015116/mintyr/main/man/figures/cheatsheet.svg' target="_blank"><img src='https://raw.githubusercontent.com/tony2015116/mintyr/main/man/figures/cheatsheet.svg' alt="mintyr package quick reference guide and cheatsheet" width="800" align="center" /></a>


## 🤝 Acknowledgments

Special thanks to AI assistance, for helping transform the initial concepts and inspirations for the `mintyr` package into reality. Their contribution has been invaluable in refining ideas, improving code structure, and crafting documentation.
