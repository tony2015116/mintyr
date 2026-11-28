# HIBLUP scripts for mintyr

Shell scripts that run the files written by `mintyr::export_scenarios()` through
[HIBLUP](https://www.hiblup.com): relationship matrix, full-data variance
components, and cross-validation. They are kept in the repository but are not
part of the R package, so they can be updated independently of package releases.

Usage (in Chinese): <https://mguo.dpdns.org/mintyr/articles/hiblup-zh.html>

| File | Purpose |
|---|---|
| `config.sh` | Settings: paths, relationship matrix, model (`effects()`), scenarios, run options. The only file to edit. |
| `lib.sh` | Shared functions |
| `0.make_xrm.sh` | Build the relationship matrix (GRM / A / H, optional dominance) |
| `1.param_est.sh` | Variance components from all records |
| `2.cross_validate.sh` | Cross-validation with fixed variance components (`--mme`) or per-fold REML |

Download into a working directory:

```bash
mkdir -p ~/gblup/scripts && cd ~/gblup/scripts
base=https://raw.githubusercontent.com/tony2015116/mintyr/main/hiblup
for f in config.sh lib.sh 0.make_xrm.sh 1.param_est.sh 2.cross_validate.sh; do
  curl -fsSLO "$base/$f"
done
```

Requirements: Linux or macOS with bash 4.3 or later (macOS ships bash 3.2;
install a newer one with `brew install bash`), awk, and HIBLUP. On Windows,
use WSL. Tested with HIBLUP 1.7.0.
