---
name: mintyr-pipelines-zh
description: （中文版）用 R 包 mintyr 处理分组/嵌套数据：批量导入 Excel/CSV、按性状×分组重塑嵌套、组内 k 折交叉验证、描述统计、导出为 HIBLUP/DMU/ASReml 输入文件。Use for mintyr or grouped breeding-data pipelines in R.
---

# mintyr 分组数据流程

mintyr（≥ 0.2.1）是基于 data.table 的 R 包，把“多分组 × 多变量”数据的常见循环封装成一组函数：

```
文件 ─► 导入 ─► 重塑与嵌套 ─► 交叉验证 / 描述统计 ─► 导出 ─► 文件
```

适用场景：用户上传多个 Excel/CSV 需要合并清洗；按性状/品种/场分别建模；组内交叉验证；按组出描述统计表（如“均值 ± 标准差”）；为 HIBLUP、DMU、ASReml-R 准备表型文件；按原文件/工作表结构写回。

## 1. 准备环境（每个会话先做）

先检查：

```bash
Rscript -e 'library(mintyr); cat(as.character(packageVersion("mintyr")))'
```

能输出 0.2.1 或更高版本就跳到第 2 步。否则按顺序尝试：

1. **能访问 CRAN 时**：`Rscript -e 'install.packages("mintyr", repos = "https://cloud.r-project.org")'`
2. **CRAN 被拦截、但 apt 和 GitHub 可用时（Ubuntu/Debian 沙箱常见）**：
   ```bash
   export DEBIAN_FRONTEND=noninteractive
   apt-get update -qq
   apt-get install -y -qq --no-install-recommends r-base-core r-cran-data.table r-cran-readxl r-cran-writexl
   git clone --depth 1 https://github.com/tony2015116/mintyr /tmp/mintyr-src
   R CMD INSTALL --no-docs /tmp/mintyr-src
   ```
   apt 安装需要几分钟，命令超时要设长一些。
3. 都不行时，告诉用户当前环境无法安装 R 包，需要放行 CRAN 或 GitHub 的网络访问；不要用别的包手写替代逻辑冒充 mintyr 的结果。

运行 R 脚本时设置 `LANG=C.UTF-8`（或 `Sys.setlocale("LC_CTYPE", "C.UTF-8")`），否则中文和 `±` 会显示成转义字符。

## 2. 工作方式

- 把 R 代码写成脚本文件（如 `analysis.R`），用 `Rscript analysis.R` 运行；需要交付时把脚本一起交给用户，方便复现。
- 处理用户上传的文件时，先复制到工作目录再处理，不要修改原件。
- 先用 `str()` / `names()` / `head()` 看清列名和类型，再决定 `cols` 和 `by`。列名不确定时问用户，不要猜性状列。
- 结果表用 `export_xlsx()` 或 `fwrite()` 写成文件交付，并在回复里用一两句话说明结果。

## 3. 通用参数约定

| 参数 | 含义 |
|---|---|
| `data` | 输入表或列表，函数不会原地修改 |
| `cols` | 要处理的列，列名或列号均可 |
| `by` | 分组列 |
| `out_type` | `"dt"`（data.table，默认）或 `"df"`（data.frame，ASReml-R 需要） |
| `path` | 输出位置，不存在的文件夹会自动创建 |
| `seed` | 交叉验证可复现，不影响全局随机数 |

0.1.x 的旧参数名（`cols2l`、`cols2bind`、`nest_dt`、`group_cols`、`rows2bind` 等）已移除，不要使用。交叉验证结果没有 `splits` 列，而是 `train_idx` / `validate_idx` 和 `train` / `validate`。

## 4. 按任务选函数

### 导入

```r
import_xlsx(file, combine = TRUE, sheet = NULL, skip = 0, header_rows = 1,
            header_sep = "_", header_fill = "auto", file_col = "excel_name",
            sheet_col = "sheet_name", path_col = NULL, workers = 1,
            verbose = FALSE, on_error = "stop", ...)
import_csv(file, combine = TRUE, file_col = "_file", path_col = NULL,
           full_path = FALSE, keep_ext = FALSE, ...)
```

- 读入所有工作簿的所有工作表，自动加来源列 `excel_name` / `sheet_name`。
- 有标题行时用 `skip = 1`；表头占两行（有合并单元格）时用 `header_rows = 2`。
- 文件中可能有坏文件时用 `on_error = "warn"`，跳过并给出一条警告。
- 文件夹名带信息（场/年份/批次）时：`path_col = "file_path"`，再用 `get_path_info(file_path, n = -3)` 等提取。
- 同一列在不同表里类型不一致时会合并为文本并给出警告，要把警告转告用户。

### 重塑与嵌套

```r
w2l_nest(data, cols = NULL, by = NULL, out_type = "dt")       # -> name | by... | data(列表列)
w2l_split(data, cols = NULL, by = NULL, out_type = "dt", sep = "_")  # -> 命名列表 "mpg_0" ...
c2p_nest(data, cols, by = NULL, pairs_n = 2, sep = "-", out_type = "dt")  # 变量两两组合 -> value1, value2
r2p_nest(data, names_from, cols, out_type = "dt", id = NULL)  # 同一性状在不同环境并排，按 id 对齐
```

- 长表的数值列统一叫 `value`，性状名在 `name` 列。
- `r2p_nest()` 一定要显式给 `id`；`id + names_from` 不唯一时会报错，这时应向用户说明重复记录。

### 交叉验证

```r
nest_cv(data, v = 10, repeats = 1, strata = NULL, breaks = 4, pool = 0.1,
        seed = NULL, materialize = TRUE, out_type = "dt")   # 输入嵌套表
split_cv(...)                                                # 同参数，输入表的列表
```

始终设置 `seed`。数据很大时用 `materialize = FALSE`，只保留行号。典型用法：

```r
nested <- w2l_nest(dat, cols = c("adg", "bf"), by = "breed")
cv <- nest_cv(nested, v = 5, seed = 2026)
cv[, r := mapply(function(tr, va) {
  fit <- lm(value ~ sex + parity, data = tr)
  cor(predict(fit, va), va$value)
}, train, validate)]
cv[, .(mean_r = mean(r), sd_r = sd(r)), by = .(name, breed)]
```

### 描述统计

```r
desc_stats(data, cols = NULL, by = NULL, type = "common", stats = NULL,
           total = FALSE, total_label = "Total", min_n = 1,
           probs = c(0, .25, .5, .75, 1), conf_level = 0.95, na_rm = TRUE,
           digits = NULL, fmt = NULL, labels = NULL, shape = "long",
           sep = "_", out_type = "dt")
```

- `type`：`"common"`、`"full"`、`"mean_sd"`、`"mean_se"`、`"mean_ci"`、`"median_iqr"`、`"median_mad"`、`"robust"`、`"five_number"`、`"quantile"`、`"mean"`、`"median"`。
- 报告表：`fmt = "{mean} ± {sd}", total = TRUE, shape = "wide"`。模板占位符：`{sd:1}` 指定小数位，`{cv:1%}` 输出百分比，`{q2.5}` 输出百分位数。
- 计数交叉表：`stats = "n", total = TRUE, shape = "wide"`。
- 小样本组：`min_n = 3`，保留 n、其他统计量为 NA。
- 显示名：`labels = c(adg = "日增重 (g)")`；按变量设小数位：`digits = c(2, adg = 0)`。

```r
top_perc(data, perc, cols, by = NULL, keep_data = FALSE,
         stats = c("n","min","max","mean","median","sd","se","cv"))  # perc = 0.1 前10%，-0.1 后10%
format_digits(data, cols = NULL, digits = 2, percentage = FALSE, nan_as_na = FALSE)
```

### 导出

```r
export_xlsx(data, path, file_col = "excel_name", sheet_col = "sheet_name",
            sheet_name = "Sheet1", drop_cols = TRUE, overwrite = TRUE, verbose = FALSE)
export_nest(data, by = NULL, cols = NULL, path = tempdir(), file_type = "txt",
            na = "NA", quote = FALSE, ...)   # path/<by1>/<by2>/<列名>.txt
export_list(data, path = tempdir(), file_type = "txt", na = "NA", quote = FALSE, ...)
```

- 带 `excel_name` / `sheet_name` 的表交给 `export_xlsx()` 会写回原文件和工作表结构；列表加 `path = "out.xlsx"` 得到一个工作簿，每个元素一张表。
- 先删掉 `path_col` 生成的路径列，再 `export_xlsx()`。
- 三个导出函数都（不可见地）返回写出的文件路径，用它列出交付的文件。

育种软件输入文件：

```r
export_nest(nested, path = "hiblup_runs")                                   # HIBLUP：有表头，NA
export_nest(nested, path = "dmu_runs", na = "-9999", col.names = FALSE)     # DMU：数值缺失码，无表头
cv <- nest_cv(nested, v = 5, seed = 1, out_type = "df")                     # ASReml-R：data.frame
```

### 工具函数

```r
get_path_info(path, n = NULL, rm_extension = TRUE, rm_path = TRUE)
# p <- "D:/data/farmA/2025/pigs.xlsx"
# get_path_info(p) -> "pigs"；n = 1 -> "data"（盘符不算一段）；n = -3 -> "farmA"；n = c(-3, -2) -> "farmA/2025"
mintyr_examples("xlsx"); mintyr_example("xlsx_test1.xlsx")   # 包自带示例文件
```

## 5. 交付前检查

- 核对行数：导入后总行数应等于各文件行数之和；嵌套后各组行数之和应等于原数据。
- 把 mintyr 给出的警告（类型合并、跳过的文件、重复 id 等）原样转告用户。
- 打开导出的文件确认列和缺失值写法符合目标软件要求。
- 不确定某个参数行为时，用 `?函数名` 或 `args(函数名)` 查本机安装版本的文档，不要凭记忆。

参考：速查表 https://tony2015116.github.io/mintyr/cheatsheet-zh.html ，函数文档 https://tony2015116.github.io/mintyr/reference/
