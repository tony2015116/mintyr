# =============================================================================
# mintyr + HIBLUP：公共函数（由 0/1/2 号脚本 source；设置在 config.sh 中）
# =============================================================================

die() { echo "[ERROR] $*" >&2; exit 1; }
log() { echo "[$(date '+%F %T')] $*"; }

# ---- 场景登记（config.sh 中调用）--------------------------------------------
declare -A SC_DIR SC_TYPE SC_STRIP SC_FILE SC_FROM
SC_ORDER=()
scenario() {                     # 名称 目录 类型 层级 [CV文件] [先验来源]
  (( $# >= 4 )) || die "scenario 至少需要 4 个参数：名称 目录 类型 层级"
  [[ $3 =~ ^(st|mt|bt)$ ]] || die "场景 $1 的类型必须是 st / mt / bt"
  [[ $4 =~ ^[0-9]+$ ]]     || die "场景 $1 的层级必须是整数"
  SC_DIR[$1]=$2; SC_TYPE[$1]=$3; SC_STRIP[$1]=$4
  SC_FILE[$1]=${5:-train}; SC_FROM[$1]=${6:-$1}
  SC_ORDER+=("$1")
}

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${LIB_DIR}/config.sh"

scenario_dir() {
  [[ -n "${SC_DIR[$1]:-}" ]] || die "未知场景 '$1'（config.sh 中登记的有：${SC_ORDER[*]}）"
  echo "${ROOT}/${SC_DIR[$1]}"
}

pick_scenarios() {               # 命令行参数 -> SCENARIOS；未指定时取已导出的场景
  SCENARIOS=()
  if (( $# )); then
    local s; for s in "$@"; do scenario_dir "$s" > /dev/null; SCENARIOS+=("$s"); done
  else
    local s; for s in "${SC_ORDER[@]}"; do
      [[ -d "${ROOT}/${SC_DIR[$s]}" ]] && SCENARIOS+=("$s")
    done
    (( ${#SCENARIOS[@]} )) || die "$ROOT 下没有找到任何已登记场景的目录"
  fi
  log "场景：${SCENARIOS[*]}"
}

# ---- 关系矩阵 ----------------------------------------------------------------
check_xrm() {                    # -> XRMS 数组（--xrm 的各个前缀）与 XRM_KIND（G/H/P）
  XRMS=()
  if (( ${#XRM_FILES[@]} )); then
    XRMS=("${XRM_FILES[@]}"); XRM_KIND=""
  else
    local k; XRM_KIND=""
    for k in G H P; do [[ -f "${XRM}.${k}A.bin" ]] && { XRM_KIND=$k; break; }; done
    [[ -n $XRM_KIND ]] || die "未找到 ${XRM}.GA/HA/PA.bin，请先运行 0.make_xrm.sh"
    XRMS=("${XRM}.${XRM_KIND}A")
    (( XRM_DOM )) && XRMS+=("${XRM}.${XRM_KIND}D")
  fi
  local x; for x in "${XRMS[@]}"; do
    [[ -f "$x.bin" && -f "$x.id" ]] || die "未找到关系矩阵 $x.bin / $x.id"
  done
  XRM_ARG=$(IFS=,; echo "${XRMS[*]}")
}

xrm_of() {                       # A / D / 完整前缀 -> 关系矩阵前缀（gxe 用）
  case $1 in
    A) echo "${XRMS[0]}" ;;
    D) (( ${#XRMS[@]} > 1 )) || die "gxe 用到了 D，但没有显性关系矩阵（XRM_DOM=1）"
       echo "${XRMS[1]}" ;;
    *) echo "$1" ;;
  esac
}

# ---- 表头与列 ----------------------------------------------------------------
col_pos() {                      # 文件 列名 -> 列号（从 1 开始）
  awk -F'\t' -v n="$2" 'NR == 1 { sub(/\r$/, "")
       for (i = 1; i <= NF; i++) if ($i == n) { print i; exit 0 }
       exit 1 }' "$1" || die "$1 的表头中没有列 '$2'"
}

trait_cols() {                   # 类型 文件 -> 性状列名
  case "$1" in
    st) echo "value" ;;
    mt) awk -F'\t' 'NR == 1 { sub(/\r$/, "")
             for (i = 1; i <= NF; i++) if ($i ~ /^value[0-9]+$/) printf "%s ", $i
             exit }' "$2" ;;
    bt) awk -F'\t' -v g="$GROUP" '{ sub(/\r$/, "") }
             NR == 1 { n = NF; for (i = 1; i <= NF; i++) { h[i] = $i; if ($i == g) gc = i }
                       if (!gc) exit 1; next }
             { lv[$gc] = 1 }
             END { for (i = 1; i <= n; i++) if (h[i] in lv) printf "%s ", h[i] }' "$2" ||
          die "$2 的表头中没有分组列 '$GROUP'" ;;
  esac
}

term_pos() {                     # 文件 效应类型 项（sex、sex:batch、herd:A）-> 列号表示
  local f=$1 type=$2 term=$3 part out="" i=0 n p
  local -a parts
  IFS=: read -r -a parts <<< "$term"
  n=${#parts[@]}
  for part in "${parts[@]}"; do
    i=$((i + 1))
    if [[ $type == gxe && $i == "$n" ]]; then p=$(xrm_of "$part")
    else p=$(col_pos "$f" "$part"); fi
    out+="${out:+:}$p"
  done
  [[ $type == gxe && $n -lt 2 ]] && die "gxe 项要写成 环境列:A，收到 '$term'"
  echo "$out"
}

# ---- 模型参数 ----------------------------------------------------------------
model_args() {                   # 场景 文件 相对路径 -> ARGS 数组、NTRAIT
  # 借用其他场景先验的场景（掩蔽式、跨群体……）必须与先验来源用同一个模型，
  # 所以 effects() 收到的是先验来源场景的名称
  local sc=$1 f=$2 rel=$3 type=${SC_TYPE[$1]} name=${3%%/*} msc=${SC_FROM[$1]} i t eff spec terms term p any
  local -a cols=() traits=() pos=()
  read -r -a cols <<< "$(trait_cols "$type" "$f")"
  (( ${#cols[@]} )) || die "$f 中找不到性状列"
  NTRAIT=${#cols[@]}; TRAIT_COLS=("${cols[@]}")

  # 性状名：st 为目录名；mt 为性状组合按 “-” 拆开；bt 为目录名（列名是群体）
  case $type in
    mt) IFS=- read -r -a traits <<< "$name"
        (( ${#traits[@]} == NTRAIT )) || traits=("${cols[@]}") ;;
    *)  for t in "${cols[@]}"; do traits+=("$name"); done ;;
  esac

  for t in "${cols[@]}"; do p=$(col_pos "$f" "$t"); pos+=("$p"); done
  ARGS=(--pheno "$f" --pheno-pos "${pos[@]}")

  local -A flag=([dcovar]=--dcovar [qcovar]=--qcovar [rand]=--rand [gxe]=--rand-gxe)
  for eff in dcovar qcovar rand gxe; do
    local -a per=(); any=0
    for (( i = 0; i < NTRAIT; i++ )); do
      terms=$(effects "$msc" "$eff" "${traits[i]}" "${cols[i]}")
      spec=""
      for term in $terms; do p=$(term_pos "$f" "$eff" "$term"); spec+="${spec:+,}$p"; done
      [[ -n $spec ]] && any=1
      per+=("${spec:-0}")                 # 0：该性状没有这类效应
    done
    (( any )) && ARGS+=("${flag[$eff]}" "${per[@]}")
  done

  ARGS+=(--xrm "$XRM_ARG")
  [[ $type == bt ]] && ARGS+=(--ignore-cove)   # 不同个体测定，没有残差协方差
  return 0
}

# ---- 先验：.vars / .covars -> --vc-priors / --covc-priors --------------------
# HIBLUP 1.7 的输出（以表头中的性状列名作前缀）：
#   单性状 .vars：location / dam / geno.GA / geno.GD / e
#   多性状 .vars：value1_location ... value1_e  value2_...（每个性状一段）
#   .covars    ：value1:value2_geno.GA ... value1:value2_e
# 每个性状各行的顺序（环境随机效应、G×E、遗传效应、残差）就是 --vc-priors
# 要求的顺序；--covc-priors 每个关系矩阵一组（按 --xrm 的顺序），再加残差一组
# （--ignore-cove 时不给残差组），组内按下三角、逐列：1:2, 1:3, ..., 2:3, ...
# 方差估计到边界（0）时 --mme 会报 “unqualified prior variances”：
# 把非正的方差换成该性状方差总和的 1e-6，并在日志中提示
floor_vc() {                     # "v1,v2,..." 说明 -> 处理后的字符串
  awk -v x="$1" -v what="$2" 'BEGIN { n = split(x, v, ","); t = 0
      for (i = 1; i <= n; i++) if (v[i] + 0 > 0) t += v[i]
      f = (t > 0 ? t : 1) * 1e-6; out = ""
      for (i = 1; i <= n; i++) {
        if (v[i] + 0 <= 0) { printf "[WARN] %s 第 %d 个方差为 %s，改为 %.3g\n", what, i, v[i], f > "/dev/stderr"; v[i] = sprintf("%.3g", f) }
        out = out (i > 1 ? "," : "") v[i] }
      print out }'
}

read_priors() {                  # 结果前缀 性状列名... -> VC、COVC
  local p=$1; shift
  local -a tc=("$@")
  local n=${#tc[@]} t v x xb="" cov
  VC=(); COVC=()
  [[ -f "$p.vars" ]] || die "缺少 $p.vars，请先运行 1.param_est.sh"
  if (( n == 1 )); then
    v=$(awk 'NR > 1 && NF >= 2 { printf "%s%s", s, $2; s = "," }' "$p.vars")
    [[ -n $v ]] || die "无法从 $p.vars 读取方差组分"
    VC=("$(floor_vc "$v" "$p.vars")"); return 0
  fi
  for t in "${tc[@]}"; do
    v=$(awk -v t="${t}_" 'NR > 1 && index($1, t) == 1 { printf "%s%s", s, $2; s = "," }' "$p.vars")
    [[ -n $v ]] || die "无法从 $p.vars 读取性状 $t 的方差组分"
    VC+=("$(floor_vc "$v" "$p.vars [$t]")")
  done
  [[ -f "$p.covars" ]] || die "缺少 $p.covars"
  for x in "${XRMS[@]}"; do xb+="${xb:+ }${x##*/}"; done
  cov=$(awk -v traits="${tc[*]}" -v xrms="$xb" '
    BEGIN { n = split(traits, tr, " "); nx = split(xrms, xs, " ")
            for (q = 1; q <= nx; q++) ord[q] = xs[q]; ord[nx + 1] = "e" }
    NR > 1 {
      for (i = 1; i <= n; i++) for (j = 1; j <= n; j++) if (i != j) {
        pre = tr[i] ":" tr[j] "_"
        if (index($1, pre) == 1) {
          c = substr($1, length(pre) + 1); a = (i < j) ? i : j; b = (i < j) ? j : i
          val[c, a, b] = $2; seen[c] = 1
        }
      }
    }
    END {
      for (q = 1; q <= nx + 1; q++) {
        c = ord[q]; if (!(c in seen)) continue      # 没有残差组：--ignore-cove
        out = ""; s = ""
        for (col = 1; col < n; col++) for (row = col + 1; row <= n; row++) {
          if (!((c, col, row) in val)) { print "MISSING " c > "/dev/stderr"; exit 1 }
          out = out s val[c, col, row]; s = ","
        }
        print out
      }
    }' "$p.covars") || die "$p.covars 中的协方差不完整"
  [[ -n $cov ]] || die "无法从 $p.covars 读取协方差"
  mapfile -t COVC <<< "$cov"
  return 0
}

# ---- 过滤与运行 --------------------------------------------------------------
wanted() {                       # 相对路径 -> 是否在 ONLY_TRAITS / ONLY_GROUPS 范围内
  local rel=$1 t g pat ok
  t=${rel%%/*}; g=""
  [[ $rel == */* ]] && { g=${rel#*/}; g=${g%%/*}; }
  if [[ -n $ONLY_TRAITS ]]; then
    ok=0; for pat in $ONLY_TRAITS; do [[ $t == $pat ]] && ok=1; done
    (( ok )) || return 1
  fi
  if [[ -n $ONLY_GROUPS && -n $g ]]; then
    ok=0; for pat in $ONLY_GROUPS; do [[ $g == $pat ]] && ok=1; done
    (( ok )) || return 1
  fi
  return 0
}

reml_mode() { (( NTRAIT > 1 )) && echo --multi-trait || echo --single-trait; }

run_hiblup() {                   # 输出目录 HIBLUP 参数... ；日志写入 <目录>/hiblup.log
  local out=$1; shift
  mkdir -p "$out"
  if ! "$HIBLUP" "$@" "$THREADS_FLAG" "$THREADS" --out "$out/fit" > "$out/hiblup.log" 2>&1; then
    tail -n 20 "$out/hiblup.log" >&2
    die "HIBLUP 运行失败，完整日志：$out/hiblup.log"
  fi
}
