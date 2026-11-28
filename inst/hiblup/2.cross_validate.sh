#!/usr/bin/env bash
# 第 2 步：交叉验证
#   CV_MODE=fixed（默认）：方差组分固定为第 1 步的全量估计值，用 --mme 求解
#   CV_MODE=reml         ：每折在训练集上重新估计方差组分（不需要第 1 步）
# 验证个体在关系矩阵中、但没有训练表型，HIBLUP 会输出它们的 GEBV
# 用法：bash 2.cross_validate.sh [场景 ...]   不写场景时运行所有已导出的场景
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
check_xrm
pick_scenarios "$@"
[[ $CV_MODE =~ ^(fixed|reml)$ ]] || die "CV_MODE 只能是 fixed 或 reml"
extra=(); (( R2 )) && extra+=(--r2)
extra+=(${CV_EXTRA[@]+"${CV_EXTRA[@]}"})

for sc in "${SCENARIOS[@]}"; do
  dir=$(scenario_dir "$sc"); fname=${SC_FILE[$sc]}
  from=$(scenario_dir "${SC_FROM[$sc]}")
  mapfile -t files < <(find "$dir/cv_data" -name "$fname.txt" 2> /dev/null | sort)
  (( ${#files[@]} )) || die "$dir/cv_data 下没有 $fname.txt"
  last=""

  for f in "${files[@]}"; do
    rel=${f#"$dir/cv_data/"}; rel=${rel%/"$fname".txt}       # 性状/群体/重复/折
    wanted "$rel" || continue
    out="$dir/cv_res/$rel"
    if (( SKIP_DONE )) && compgen -G "$out/fit*.rand" > /dev/null; then continue; fi
    model_args "$sc" "$f" "$rel"

    if [[ $CV_MODE == reml ]]; then
      run_hiblup "$out" "$(reml_mode)" "${ARGS[@]}" --vc-method "$VC_METHOD" \
        --ai-maxit "$AI_MAXIT" ${extra[@]+"${extra[@]}"}
      continue
    fi

    prel=$rel                                                 # 对应的全量参数估计
    for (( k = 0; k < ${SC_STRIP[$sc]}; k++ )); do prel=${prel%/*}; done
    if [[ $prel != "$last" ]]; then
      read_priors "$from/param_est_res/$prel/fit" "${TRAIT_COLS[@]}"
      log "$sc | $prel | vc-priors: ${VC[*]} | covc-priors: ${COVC[*]:-无}"
      last=$prel
    fi
    pri=(--vc-priors "${VC[@]}")
    (( NTRAIT > 1 )) && pri+=(--covc-priors "${COVC[@]}")
    run_hiblup "$out" --mme "${ARGS[@]}" "${pri[@]}" ${extra[@]+"${extra[@]}"}
  done
done
log "交叉验证完成"
