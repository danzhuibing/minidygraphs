#' Mini version of dygraphs
#'
#' R tutorial of htmlwidgets using \href{http://dygraphs.com}{dygraph} Javascript library.
#'
#' @inheritParams htmlwidgets::createWidget
#'
#' @param data Time series data,
#'   must be an \link[xts]{xts} object or an object which is convertible to
#'   \code{xts}.
#' @param main Main plot title (optional)
#' @param xlab X axis label
#' @param ylab Y axis label
#' @param width Width in pixels (optional, defaults to automatic sizing)
#' @param height Height in pixels (optional, defaults to automatic sizing)
#'
#' @return Interactive dygraph plot
#'
#' @examples
#' library(minidygraphs)
#' lungDeaths <- cbind(mdeaths, fdeaths)
#' minidygraph(lungDeaths)
#' @export
minidygraph <-
  function(data,
           main = NULL,
           xlab = NULL,
           ylab = NULL,
           width = NULL,
           height = NULL,
           elementId = NULL) {
    if(xts::xtsible(data)) {
      if(!xts::is.xts(data))
        data <- xts::as.xts(data)
      format <- "date"
    } else {
      stop("Unsupported type passed to argument 'data'.")
    }

    periodicity <- xts::periodicity(data)

    # extract time
    time <- time(data)

    # get data as a named list
    data <- zoo::coredata(data)
    data <- unclass(as.data.frame(data))

    # merge time back into list and convert to JS friendly string
    timeColumn <- list()
    timeColumn[[periodicity$label]] <- asISO8601Time(time)
    data <- append(timeColumn, data)

    # create native dygraph attrs object
    attrs <- list()
    attrs$title <- main
    attrs$xlabel <- xlab
    attrs$ylabel <- ylab
    attrs$labels <- names(data)
    attrs$legend <- "auto"
    attrs$retainDateWindow <- FALSE
    attrs$axes$x <- list()
    attrs$axes$x$pixelsPerLabel <- 60
    attrs$axes$x$axisLabelWidth <- 70

    # create x (dygraph attrs + some side data)
    x <- list()
    x$attrs <- attrs
    x$scale <- periodicity$scale
    x$annotations <- list()
    x$shadings <- list()
    x$events <- list()
    x$format <- format

    names(data) <- NULL
    x$data <- data

    # create widget
    htmlwidgets::createWidget(
      name = "minidygraphs",
      x = x,
      width = width,
      height = height,
      htmlwidgets::sizingPolicy(viewer.padding = 10, browser.fill = TRUE),
      elementId = elementId,
      package = 'minidygraphs'
    )
  }

#' Shiny bindings for minidygraphs
#'
#' Output and render functions for using minidygraphs within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a minidygraphs
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name minidygraphs-shiny
#'
#' @export
minidygraphsOutput <-
  function(outputId,
           width = '100%',
           height = '400px') {
    htmlwidgets::shinyWidgetOutput(outputId, 'minidygraphs', width, height, package = 'minidygraphs')
  }

#' @rdname minidygraphs-shiny
#' @export
renderMinidygraphs <-
  function(expr,
           env = parent.frame(),
           quoted = FALSE) {
    if (!quoted) {
      expr <- substitute(expr)
    } # force quoted
    htmlwidgets::shinyRenderWidget(expr, minidygraphsOutput, env, quoted = TRUE)
  }
