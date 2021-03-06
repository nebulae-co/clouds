% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cloud.R
\name{cloud}
\alias{cloud}
\title{cloud receives a vector and makes a cloud object}
\usage{
cloud(x, weight = 1/length(x))
}
\arguments{
\item{x}{a numeric vector}

\item{weight}{a vector of weights for x, 1 / length(x) by default}
}
\value{
a cloud object, a data frame with columns `value` and
        `weight`
}
\description{
cloud receives a vector and makes a cloud object
}
