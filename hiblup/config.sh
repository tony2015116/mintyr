# =============================================================================
# mintyr + HIBLUP：用户设置（只需要修改这个文件）
# 公共函数在 lib.sh 中，一般不需要修改
# =============================================================================

# ---- 1. 程序与路径 -----------------------------------------------------------
HIBLUP="hiblup"                  # HIBLUP 可执行文件（不在 PATH 中时写绝对路径）
THREADS_FLAG="--threads"         # 个别版本只认 --thread 时改这里
THREADS=16
ROOT="$HOME/gblup"               # 与 export_scenarios(path = ...) 相同
GROUP="herd"                     # 与 cv_scenarios(group = ...) 相同

# ---- 2. 遗传关系 -------------------------------------------------------------
# 只给 BFILE：GBLUP（GRM）；只给 PEDIGREE：PBLUP（A 矩阵）；
# 两者都给：一步法 ssGBLUP（H 矩阵）。0.make_xrm.sh 据此计算关系矩阵
BFILE="$HOME/geno/geno"          # PLINK 二进制前缀（.bed/.bim/.fam），不用就留空
PEDIGREE=""                      # 系谱文件（个体 父 母三列），不用就留空
XRM="${ROOT}/xrm/geno"           # 关系矩阵输出前缀
XRM_DOM=0                        # 1：同时计算并拟合显性关系矩阵
MAKE_XRM_ARGS=()                 # --make-xrm 的其他参数，如 (--alpha 0.05 --step 10000)
XRM_FILES=()                     # 已有关系矩阵时直接列出前缀（不含 .bin），并跳过第 0 步，
                                 # 如 ("/data/geno.GA" "/data/geno.GD")

# ---- 3. 模型效应 -------------------------------------------------------------
# 对每个场景的每个性状调用一次，返回该效应的列名（空格分隔，没有就返回空）：
#   $1 场景名（借用其他场景先验的场景收到的是先验来源的名称）
#   $2 效应类型：dcovar 分类固定效应 | qcovar 数值协变量 |
#                            rand 环境随机效应 | gxe 基因型×环境随机效应
#   $3 性状名（adg、bf……）   $4 性状列名（value、value1、north……）
# 交互项用冒号连接：sex:batch。gxe 写成 “环境列:A”（加性）或 “环境列:D”（显性）。
# 用 case 匹配 “场景:性状” 即可按场景、按性状设置不同的模型，例如：
#   dcovar) case "$1:$3" in
#             st_mp:*|mt_mp:*) echo "herd sex batch" ;;  # 合并群体时加群体效应
#             *:fcr)           echo "sex" ;;             # fcr 只校正性别
#             *)               echo "sex batch" ;;
#           esac ;;
#   rand)   echo "litter" ;;                             # 窝效应（重复记录模型写 id）
#   gxe)    case "$1" in st_mp) echo "herd:A" ;; esac ;; # 群体×加性遗传
effects() {
  case "$2" in
    dcovar) echo "sex batch" ;;
    qcovar) echo "" ;;
    rand)   echo "" ;;
    gxe)    echo "" ;;
  esac
}

# ---- 4. 场景 -----------------------------------------------------------------
#        名称    目录          类型 层级 CV文件 先验来源
# 类型：st 单性状（列 value）| mt 多性状（列 value1 value2 ...）|
#       bt 同一性状在各群体视为不同性状（以群体水平命名的列，自动加 --ignore-cove）
# 层级：cv_data 下的路径去掉末尾几层，就是对应的 param_est_res 路径
#       （“性状/群体/重复/折” 去掉 2 层 → “性状/群体”；去掉 3 层 → “性状”）
# CV文件：train（训练集）或 masked（掩蔽式：一个文件，验证个体表型为缺失）
# 先验来源：用哪个场景的全量参数估计结果，省略时用本场景
scenario  st_sp   2.1.st_sp     st   2    train
scenario  st_mp   2.2.st_mp     st   3    train
scenario  mt_sp   2.3.mt_sp     mt   2    train
scenario  mt_mp   2.4.mt_mp     mt   3    train
scenario  mt_bt   2.5.mt_bt     bt   3    train
# 进阶场景示例（用 export_nest() 导出，见文章“进阶场景”一节）：
# scenario mt3     2.6.mt3      mt   3    train            # 三性状模型
# scenario st_mask 3.1.st_mask  st   2    masked  st_sp    # 掩蔽式交叉验证
# scenario across  3.2.across   st   0    train   st_mp    # 跨群体预测（不分折）

# ---- 5. 运行选项（都可以在命令行临时覆盖，如 CV_MODE=reml bash 2.cross_validate.sh）
VC_METHOD="${VC_METHOD:-AI}"     # AI | EM | EMAI | HE | HI
AI_MAXIT="${AI_MAXIT:-50}"
CV_MODE="${CV_MODE:-fixed}"      # fixed：固定全量方差组分，用 --mme 求解（快）
                                 # reml ：每折在训练集上重新估计方差组分（严格，慢）
R2="${R2:-0}"                    # 1：交叉验证时加 --r2，输出 PEV 与可靠性
SKIP_DONE="${SKIP_DONE:-1}"      # 1：已有结果的数据集跳过（断点续跑）
ONLY_TRAITS="${ONLY_TRAITS:-}"   # 只跑这些性状（目录名，可用通配符），如 "adg adg-*"
ONLY_GROUPS="${ONLY_GROUPS:-}"   # 只跑这些群体，如 "north"
PARAM_EXTRA=()                   # 第 1 步额外的 HIBLUP 参数，如 (--pcg)
CV_EXTRA=()                      # 第 2 步额外的 HIBLUP 参数
