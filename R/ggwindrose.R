#' ggplot wrapper to create a windrose (polar wind-bin frequency plot)
#'
#' @return ggplot object
#'
#' @param data tibble containing wind speed, wind direction and/or air pollutant concentration data
#' @param ws symbol giving the wind velocity column name (wind velocity preferably in m/s)
#' @param wd symbol giving the wind direction column name  in degrees
#' @param wd_binwidth numeric, binwidth for wind direction in °, wd_binwidth should fullfill:
#'   `(360 / wd_binwidth) %in% c(4, 8, 16, 32)`
#' @param ws_binwidth numeric, binwidth for wind speed
#' @param ws_max numeric, can be NA, wind speed is squished at this value
#' @param groupings additional groupings. Use helper [grp()] to create. **Necessary** for some facets!
#' @param fill_scale ggplot2 discrete fill scale, e.g. [ggplot2::scale_fill_gradientn()]
#' @param reverse TRUE/FALSE, should wind speed bin factors be sorted descending (TRUE)
#'   or ascending (FALSE). Usually for wind roses a descending order (higher wind speed on
#'   the outside) is used.
#' @param bg raster map, e.g. ggmap object as plot background
#' @param ... Other arguments passed on to [ggplot2::geom_bar()]. Used
#'   to set an aesthetic to a fixed value. Defaults are `color = "white", width = 1, size = 0.25`
#'
#' @return [ggplot2::ggplot()] object
#' @export
#'
#' @examples
#' library(ggplot2)
#'
#' fn <- rOstluft.data::f("Zch_Stampfenbachstrasse_2010-2014.csv")
#'
#' data <-
#'   rOstluft::read_airmo_csv(fn) %>%
#'   rOstluft::rolf_to_openair() %>%
#'   openair::cutData(date, type = "daylight")
#'
#' ggwindrose(data, ws, wd)
#'
#' # squish ws
#' ggwindrose(data, ws, wd, ws_max = 5)
#'
#' # change binning
#' ggwindrose(data, ws, wd, wd_binwidth = 22.5, ws_binwidth = 1.5, ws_max = 4.5)
#'
#' # don't like bar outlines?
#' ggwindrose(data, "ws", "wd", color = "black", ws_max = 4)
#'
#' # bigger outlines
#' ggwindrose(data, ws, wd, ws_max = 5, size = 1)
#'
#' # a map as background
#' bb <- bbox_lv95(2683141, 1249040, 500)
#' bg <- get_stamen_map(bb)
#' ggwindrose(data, ws, wd, ws_max = 5, alpha = 0.8, bg = bg) +
#'   theme(
#'     panel.grid.major = element_line(linetype = 2, color = "black", size = 0.5)
#'    )
#'
#' # another fill scale
#' ggwindrose(data, ws, wd, ws_max = 5,
#'            fill_scale = scale_fill_manual(values = matlab::jet.colors(6)))
#'
#' # reverse the order of ws, but keep the coloring and legend order
#' ggwindrose(data, ws, wd, ws_max = 4, reverse = FALSE,
#'            fill_scale = scale_fill_viridis_d(direction = -1))
#'
#' # faceting: important the faceting variable, must also be in grouping!
#' ggwindrose(data, ws, wd, ws_max = 5, groupings = grp(daylight)) +
#'   facet_wrap(vars(daylight))
#'
#' # you can use groupings to directly mutate the data for faceting.
#' # in this example we define the groupings external for better
#' # readability
#' groupings = grp(
#'   season = cut_season(date, labels = c(DJF = "winter", MAM = "spring",
#'                       JJA = "summer", SON = "autumn")),
#'   year = cut_seasonyear(date, label = "year")
#' )
#'
#' # only three years for smaller plot size and cut the last december
#' # theming remove the NOSW labels and reduce the y spacing between plots
#' data <- dplyr::filter(data, date < lubridate::ymd(20121201))
#' ggwindrose(data, ws, wd, ws_max = 3, groupings = groupings) +
#'   facet_grid(rows = vars(year), cols = vars(season)) +
#'   theme(
#'     axis.text.x = element_blank(),
#'     panel.spacing.y = unit(0, "pt")
#'   )
ggwindrose <- function(data, ws, wd,
                       wd_binwidth = 45,
                       ws_binwidth = 1,
                       ws_max = NA,
                       groupings = grp(),
                       fill_scale = scale_fill_viridis_d(),
                       reverse = TRUE,
                       bg = NULL,
                       ...

) {

  ws <- rlang::ensym(ws)  # or enquo but summary_wind accept only strings or symbols
  wd <- rlang::ensym(wd)
  wd_cutfun <- cut_wd.fun(binwidth = wd_binwidth)
  ws_cutfun <- cut_ws.fun(binwidth = ws_binwidth, ws_max = ws_max, reverse = reverse)

  data_summarized <- summary_wind(data, !!ws, !!wd, !!ws, groupings = groupings,
                                  wd_cutfun = wd_cutfun, ws_cutfun = ws_cutfun)

  bar_args <- modify_list(list(color = "white", width = 1, size = 0.25), rlang::dots_list(...))
  bar_layer <- rlang::exec(geom_bar, stat = "identity", !!!bar_args)

  # we will convert the wd factor to numeric. so we can always place breaks on NESW
  breaks <- c(0, 90, 180, 270) / wd_binwidth + 1
  xexpand <- expand_scale(add = (1 - bar_args$width) / 2)

  plot <- ggplot(data_summarized, aes(x = as.numeric(!!wd), y = .data$freq, fill = !!ws)) +
    bar_layer +
    coord_polar2(start = -2 * pi / 360 * wd_binwidth / 2, bg = bg) +
    scale_x_continuous(breaks = breaks, labels = c("N", "E", "S", "W"), expand = xexpand) +
    scale_y_continuous(limits = c(0, NA), expand = expand_scale(), labels = scales::percent) +
    fill_scale +
    guides(fill = guide_legend(title = rlang::quo_text(ws), reverse = !reverse)) +
    theme_rop_windrose()

  return(plot)
}
