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

**mintyr** is an R package that enables automatic monitor the stations and pigs in the pig farm which using nedap pig performance test stations.`station_monitor()` can monitor the number of pigs within a testing station, total feed intake, total visit time, total visit frequency, and overall weight condition. `fid_monitor()` can monitor the feed intake and proportion of each pig within a single testing station.`table_monitor()` can monitor several informations in table fromat.`monitor_schedule()` packages the previous two functions into one that can be set to monitor on a regular basis.

# Installation
You can install the development version from GitHub with:
``` r
# install.packages("pak")
pak::pak("tony2015116/mintyr")
```
## Example

This is a basic example which shows you how to download pig performance test CSVs data:

``` r
# Require packages
library(mintyr)
```
