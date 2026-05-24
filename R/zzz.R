utils::globalVariables("..non_nested_cols")

.onAttach <- function(libname, pkgname) {
  pkg_version <- as.character(utils::packageVersion("mintyr"))

  # Dynamic time greeting logic
  hour <- as.numeric(format(Sys.time(), "%H"))
  greeting <- if (hour < 12) {
    "Good morning!"
  } else if (hour < 18) {
    "Good afternoon!"
  } else {
    "Good evening!"
  }

  # Assemble startup message with Unicode escapes for emojis
  # \U0001F9E0 is Brain (🧠), \U0001F4A1 is Lightbulb (💡)
  msg <- paste0(
    "==========================================================\n",
    " ", greeting, " mintyr (v", pkg_version, ") Loaded.\n",
    " \U0001F4A1 Reminder: Put First Things First.\n",
    "=========================================================="
  )

  packageStartupMessage(msg)
}
