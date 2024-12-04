# mintyr <a href='https://tony2015116.github.io/mintyr/'><img src='man/figures/logo.svg'  width="120" align="right" />
<!--apple-touch-icon-120x120.png-->
<!-- <picture><source srcset="reference/figures/apple-touch-icon-120x120.png" media="(prefers-color-scheme: dark)"></picture> -->

<!-- badges: start -->
[![GitHub R package version](https://img.shields.io/github/r-package/v/tony2015116/mintyr)](#)
[![GitHub last commit](https://img.shields.io/github/last-commit/tony2015116/mintyr)](#)
[![R-CMD-check](https://github.com/tony2015116/mintyr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/tony2015116/mintyr/actions/workflows/R-CMD-check.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

<!--[![CodeFactor](https://www.codefactor.io/repository/github/tony2015116/mintyr/badge/main)](https://www.codefactor.io/repository/github/tony2015116/mintyr/overview/main)-->

`mintyr` is an R package that provides fresh and efficient solutions for data processing, with a particular emphasis on animal breeding data. The package name reflects its core philosophy - delivering clean, fresh, and straightforward approaches to data manipulation. The package originated from the challenges encountered in handling multi-breed and multi-trait data in genomic selection, where nested data structures (via `dplyr::group_nest()`) proved to be remarkably effective for model iteration, especially when combined with `dplyr::mutate` and `purrr::map()` operations. While the tidyverse ecosystem offers powerful tools, to enhance performance while maintaining code clarity, `mintyr` has been implemented primarily using `data.table` and base R functions. Although initially designed for processing genomic selection phenotype data, `mintyr` has evolved to include a comprehensive collection of utility functions that streamline common data processing tasks.

# Acknowledgments

Special thanks to AI assistance, particularly ChatGPT and Claude, for helping transform the initial concepts and inspirations for the `mintyr` package into reality. Their contribution has been invaluable in refining ideas, improving code structure, and crafting documentation.


# Installation
You can install the development version from GitHub with:
``` r
# install.packages("pak")
pak::pak("tony2015116/mintyr")
```
