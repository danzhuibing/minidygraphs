asISO8601Time <- function(x) {
  if (!inherits(x, "POSIXct"))
    x <- as.POSIXct(x, tz = "GMT")
  format(x, format = "%04Y-%m-%dT%H:%M:%OS3Z", tz = 'GMT')
}