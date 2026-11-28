#!/usr/bin/env bash
# 第 0 步：计算一次关系矩阵（GRM / A / H，可加显性），后面所有模型都用 --xrm 复用
# 用法：bash 0.make_xrm.sh
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

if (( ${#XRM_FILES[@]} )); then
  check_xrm; log "使用已有关系矩阵：${XRMS[*]}"; exit 0
fi
src=()
[[ -n $BFILE    ]] && src+=(--bfile "$BFILE")
[[ -n $PEDIGREE ]] && src+=(--pedigree "$PEDIGREE")
(( ${#src[@]} )) || die "BFILE 和 PEDIGREE 至少要给一个"
comp=(--add); (( XRM_DOM )) && comp+=(--dom)

mkdir -p "$(dirname "$XRM")"
log "计算关系矩阵：${src[*]} ${comp[*]} -> ${XRM}.*"
"$HIBLUP" --make-xrm "${src[@]}" "${comp[@]}" ${MAKE_XRM_ARGS[@]+"${MAKE_XRM_ARGS[@]}"} \
  "$THREADS_FLAG" "$THREADS" --out "$XRM"
check_xrm
log "完成：${XRMS[*]}"
