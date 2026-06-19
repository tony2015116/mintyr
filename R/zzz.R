utils::globalVariables("..non_nested_cols")

.onAttach <- function(libname, pkgname) {
  v <- as.character(utils::packageVersion("mintyr"))

  hour <- as.numeric(format(Sys.time(), "%H"))
  greeting <- if (hour < 5)
    "\U0001F33F Late night hacking? Remember to save your workspace."
  else if (hour < 12)
    "\U0001F33F Good morning! Coffee first, data second."
  else if (hour < 18)
    "\U0001F33F Good afternoon! Keep calm and analyze on."
  else
    "\U0001F33F Good evening! May your code run fast while you sleep."

  packageStartupMessage(paste0(
    greeting
  ))
}
