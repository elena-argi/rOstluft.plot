% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/summary_wind.R
\name{summary_wind}
\alias{summary_wind}
\title{Summarise y values over binned wind data.}
\usage{
summary_wind(data, ws, wd, z, groups = NULL, fun = "mean",
  fun.args = list(), nmin = 3, wd_cutfun = cut_wd.fun(binwidth = 45),
  wd_offset = 0, ws_cutfun = cut_ws.fun(binwidth = 1, ws_max = NA))
}
\arguments{
\item{data}{a data.frame or tibble containing the data (wide format)}

\item{ws}{string giving the wind velocity parameter name (wind velocity preferably in m/s)}

\item{wd}{string giving the wind direction parameter name  in degrees}

\item{z}{string giving the parameter name to be summarised}

\item{groups}{character string, can be NULL, 'wd', 'ws', ...}

\item{fun}{function or list of functions for summary.}

\item{fun.args}{a list of extra arguments passed on to fun.}

\item{nmin}{numeric, minimum number of values for fun, if n < nmin: NA is returned}

\item{wd_cutfun}{function, cut function for wind direction (to create bins)}

\item{wd_offset}{numeric, offset for wind_direction (in °) if groups == "wd"; bins are then calculated
over \code{(wd + wd_offset) \%\% 360}}

\item{ws_cutfun}{function, cut function for wind speed}
}
\value{
a tibble with summarised data
}
\description{
Input data should be original unbinned data.
1-dimensional binning and calculating summary statistics over wind direction and/or wind velocity bins, respectively.
}
\section{Computed variables}{

\itemize{
\item If groups = NULL: groups = "wd". In this case, bins are calculated over wind direction;
a tibble including wd and summarised z is returned
\item groups can be strings for other variables in data; then fun is applied over those;
a tibble including groups and summarised z is returned
}
}
