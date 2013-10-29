# check dir exists and is indeed a dir
checkDir = function(dirname, dir) {
  if (!file.exists(dir))
    stopf("%s directory does not exists: %s", dirname, dir)
  if (!isDirectory(dir))
    stopf("% directory is not a directory: %s", dirname, dir)
}

isShowInfoEnabled = function() {
  getPMOptShowInfo()
}

# show message if show.info is TRUE
showInfoMessage = function(msg, ...) {
  if (isShowInfoEnabled()) {
    messagef(msg, ...)
  }
}

showStartupMsg = function(mode, cpus, socket.hosts) {
  if (mode != MODE_LOCAL) {
    if (mode %in% c(MODE_MULTICORE, MODE_MPI) || 
      (mode == MODE_SOCKET && !is.na(cpus))) {
      showInfoMessage("Starting parallelization in mode=%s with cpus=%i.",
        mode, cpus)
    } else if (mode == MODE_SOCKET) {
      showInfoMessage("Starting parallelization in mode=%s on %i hosts.", 
        mode, length(socket.hosts))
    } else if (mode == MODE_BATCHJOBS) {
      #FIXME function is exported in later bj version, also then depend on it
      showInfoMessage("Starting parallelization in mode=%s-%s.", 
        mode, getBJConfig()$cluster.functions$name)
    }
  }
}

# either the option level is not set or it is and the level of parmap matches
isParallelizationLevel = function(level) {
  optlevel = getPMOptLevel()
  is.na(optlevel) || (!is.na(level) && level == optlevel)
}

exportToSlavePkgParallel = function(objname, objval) {
  # clusterExport is trash because of envir argument, we cannot easily export
  # stuff defined in the scope of an R function
  # cl = NULL is default cluster, pos=1 is always globalenv
  # I really hope the nextline does what I think in all cases...
  clusterCall(cl=NULL, assign, x=objname, value=objval, pos=1)
}
