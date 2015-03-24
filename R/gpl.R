#' Read colors from GIMP Palette (GPL) files
#'
#' Given a path or URL to an \code{.gpl} file, this function will return
#' a named character vector (if color names are present) of hex RGB colors.
#'
#' @param path partial or full file path or URL to a GPL file
#' @param use_names add color names to the vector (defaults to \code{TRUE}). See NOTE
#' @param .verbose show extra information about GPL file processing
#' @note When using named color palettes in a \code{ggplot2} \code{scale_} context, you
#'     must \code{unname} them or set \code{use_names} to \code{FALSE}.
#'     Not sure if this is a bug or a deliberate feature in ggplot2. Also, Neither Lab nor
#'     greyscale colors are supported.
#' @export
#' @examples
#' # built-in palette
#' gimp16 <- read_gpl(system.file("palettes",
#'                      "base16.gpl", package="swatches"))
#' print(gimp16)
#' #show_palette(gimp16)
#'
#' # from the internet directly
#' # bright <- read_gpl("http://l.dds.ec/gimppal16")
#' # print(bright)
#' # show_palette(bright)
read_gpl <- function(path, use_names=TRUE, .verbose=FALSE) {

  if (is_url(path)) {
    tf <- tempfile()
    stop_for_status(GET(path, write_disk(tf)))
    path <- tf
  }

  gpl <- readLines(path.expand(path), warn=FALSE)

  p_name <- gsub("Name:\ +", "", gpl[2])
  n_colors <- gsub("Columns:\ +", "", gpl[3])

  if (.verbose) {
    message("GPL Palette Name: ", p_name)
    message("# Colors: " , n_colors)
  }

  pal <- NULL

  pal <- sapply(5:length(gpl), function(i) {
    mat <- str_match(gpl[i],
"[[:blank:]]*([[:digit:]]+)[[:blank:]]*([[:digit:]]+)[[:blank:]]*([[:digit:]]+)[[:blank:]]*(.*)$")
    rgb(mat[2], mat[3], mat[4], names=mat[5], maxColorValue=255)
  })

  if (!use_names) { pal <- unname(pal) }

  pal

}