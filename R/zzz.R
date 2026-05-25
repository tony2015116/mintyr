utils::globalVariables("..non_nested_cols")

.onAttach <- function(libname, pkgname) {
  pkg_version <- as.character(utils::packageVersion("mintyr"))

  # 动态时间问候 (使用 ASCII Unicode 转义)
  # \U0001F989 (🦉), \u2615 (☕), \u2600 (☀️), \U0001F319 (🌙)
  hour <- as.numeric(format(Sys.time(), "%H"))
  greeting <- if (hour < 5) {
    "\U0001F989 Late night hacking? Remember to save your workspace."
  } else if (hour < 12) {
    "\u2615 Good morning! Coffee first, data second."
  } else if (hour < 18) {
    "\u2600 Good afternoon! Keep calm and analyze on."
  } else {
    "\U0001F319 Good evening! May your code run fast while you sleep."
  }

  # 组装启动信息
  # \U0001F33F (🌿)
  msg <- paste0(
    "\n",
    "==========================================================\n",
    " \U0001F33F mintyr v", pkg_version, " Loaded.\n",
    " ", greeting, "\n",
    "==========================================================\n"
  )

  packageStartupMessage(msg)
}
