<!-- README.md is generated from README.rmd. Please edit that file -->
clouds
======

clouds is a package that implements non-parametric clustering algorithims for groups of numeric data. A cloud is a numerical vector with a weight vector associated from which an empircal cumulative distribution function (ECDF) can be computed.

clouds defines a pseudo-distance function to compare ECDFs. So given a set of clouds -- e.g. an experiment with a response variable and treatment groups, where each group will define a cloud -- a distance matrix for the clouds can be computed. Based on this matrix we can apply different well-known clustering methods to group the clouds.

Currently there are two methods implemented `k_clouds` which uses k-means for the clustering and `j_clouds` which uses Ward's hierarchichal algorithm as implemented in `stats::hclust()` with `method = "ward.D"`.

### Installation

Install from GitHub with `devtools`:

    devtools::install_github("nebulae-co/clouds")

### Usage

Lets make some data from five different normal distributions:

``` r
library("dplyr")

n_distributions <- 5L
n_groups <- 4L
group_size <- 12
N <- group_size * n_groups
distributions <- letters[1:n_distributions]
groups <- LETTERS[1:(n_distributions * n_groups)]

mean <- 1:5
sd <- c(2, 1, 0.5, 1, 2)

sample <- data_frame(
  y = c(mapply(rnorm, mean = mean, sd = sd, MoreArgs = list(n = N))),
  distribution = rep(distributions, each = N),
  group = rep(groups, each = group_size))

sample
```

    #> # A tibble: 240 x 3
    #>             y distribution group
    #>         <dbl>        <chr> <chr>
    #>  1  2.0355661            a     A
    #>  2  2.4251103            a     A
    #>  3  0.7001281            a     A
    #>  4 -0.6477998            a     A
    #>  5  1.2728224            a     A
    #>  6  1.6601561            a     A
    #>  7  1.2103591            a     A
    #>  8 -1.0395949            a     A
    #>  9  1.7951571            a     A
    #> 10  3.5448991            a     A
    #> # ... with 230 more rows

Now lets load `clouds` and get the `k_clouds` clusters:

``` r
library("clouds")

sample %>%
  k_clouds(var = "y", group = "group", k = 5, threshold = 0.01)
```

    #>    group cluster
    #> 1      A       e
    #> 2      B       e
    #> 3      C       e
    #> 4      D       e
    #> 5      E       e
    #> 6      F       e
    #> 7      G       c
    #> 8      H       e
    #> 9      I       c
    #> 10     J       c
    #> 11     K       c
    #> 12     L       c
    #> 13     M       d
    #> 14     N       b
    #> 15     O       b
    #> 16     P       d
    #> 17     Q       a
    #> 18     R       a
    #> 19     S       a
    #> 20     T       a

Compare with the `j_clouds` clusters:

``` r
sample %>%
  j_clouds(var = "y", group = "group", k = 5)
```

    #>    group cluster
    #> 1      A       a
    #> 2      B       a
    #> 3      C       a
    #> 4      D       a
    #> 5      E       b
    #> 6      F       b
    #> 7      G       b
    #> 8      H       b
    #> 9      I       c
    #> 10     J       c
    #> 11     K       c
    #> 12     L       c
    #> 13     M       d
    #> 14     N       d
    #> 15     O       d
    #> 16     P       d
    #> 17     Q       e
    #> 18     R       e
    #> 19     S       e
    #> 20     T       e

### About

This is mostly result of [Julian](https://github.com/CruzJulian)'s research for his [Master Thesis](https://github.com/CruzJulian/Tesis).

[Daniel](https://github.com/demorenoc) has done the packaging.

Still a work in progress.
