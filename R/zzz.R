.onUnload <- function (libpath) {
  library.dynam.unload("clouds", libpath)
}
