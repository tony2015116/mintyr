#!/usr/bin/env bash
# 第 1 步：用全部记录（param_est_data）估计方差组分
# 用法：bash 1.param_est.sh [场景 ...]      不写场景时运行所有已导出的场景
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
check_xrm
pick_scenarios "$@"

for sc in "${SCENARIOS[@]}"; do
  dir=$(scenario_dir "$sc")
  if [[ ! -d "$dir/param_est_data" ]]; then
    log "$sc：没有 param_est_data，跳过（先验来自 ${SC_FROM[$sc]}）"; continue
  fi
  mapfile -t files < <(find "$dir/param_est_data" -name data.txt | sort)
  (( ${#files[@]} )) || die "$dir/param_est_data 下没有 data.txt"

  for f in "${files[@]}"; do
    rel=${f#"$dir/param_est_data/"}; rel=${rel%/data.txt}   # 例如 adg/north、adg-bf
    wanted "$rel" || continue
    out="$dir/param_est_res/$rel"
    if (( SKIP_DONE )) && [[ -f "$out/fit.vars" ]]; then continue; fi
    model_args "$sc" "$f" "$rel"
    mode=$(reml_mode)
    log "$sc | $rel | $mode"
    run_hiblup "$out" "$mode" "${ARGS[@]}" --vc-method "$VC_METHOD" --ai-maxit "$AI_MAXIT" \
      ${PARAM_EXTRA[@]+"${PARAM_EXTRA[@]}"}
  done
done
log "参数估计完成"
