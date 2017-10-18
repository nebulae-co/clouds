#' @useDynLib clouds
#' @importFrom Rcpp sourceCpp
NULL

# Helper functional
list_outer <- function(a, b, fun) {
  outer(a,
        b,
        function(x, y) {
          vapply(seq_along(x), function(i) fun(x[[i]], y[[i]]), numeric(1))
        })
}

#' cloud receives a vector and makes a cloud object
#'
#' @param x       a numeric vector
#' @param weight  a vector of weights for x, 1 / length(x) by default
#'
#' @return a cloud object, a data frame with columns `value` and
#'         `weight`
#' @export
cloud <- function(x, weight = 1 / length(x)){
  cloud <- data.frame(value = x, weight = weight)
  class(cloud) <- c("cloud", "data.frame")
  cloud
}

rbind_clouds <- function(...){
  clouds <- list(...)
  N <- sum(sapply(clouds, nrow))
  clouds <- lapply(clouds,
                   function(cloud){
                     cloud$weight <- cloud$weight * nrow(cloud) / N
                     cloud
                   })
  structure(do.call(rbind, clouds), class = c("cloud", "data.frame"))
}

#' cloud_distance computes the distance between two cloud objects
#'
#' @param x,y cloud objects
#'
#' @return numeric, the distance between clouds
#' @export
cloud_distance <- function(x, y){
  clouds_df <- rbind(cbind(x, binary = 0), cbind(y, binary = 1))
  clouds_df <- clouds_df[with(clouds_df, order(value)), , drop = FALSE]
  cloud_distance_(clouds_df)
}

#' k-clouds clustering
#'
#' @param df         data frame with the data to cluster
#' @param var        character or integer indicating the column name or position
#'                   of the numeric column to evalute for defining the clusters,
#'                   1L by default
#' @param group      character or integer indicating the column name or position
#'                   of the column that defines the treatments, 2L by default
#' @param k          integer, number of super-groups to cluster in
#' @param threshold  double, value to stop the iteration. Stops if the
#'                   difference between the previous total distance and the
#'                   current total distance is less than threshold
#' @param iter       integer, maximum number of iterations
#'
#' @return           a data frame with columns group and cluster.
#'                     - group: referencees the group variable
#'                     - cluster: a letter indicating the cluster to which the
#'                                group belongs
#' @export
k_clouds <- function(df, var = NULL, group = NULL, k = NULL, threshold = 0.01,
                     iter = 100){
  if (is.null(var)) var <- 1L
  if (is.null(group)) group <- 2L
  x <- df[[var]]
  y <- df[[group]]
  clouds <- lapply(split(x, y), cloud)

  seed_index <- sample(length(clouds), k, replace = FALSE)
  centers <- stats::setNames(clouds[seed_index], LETTERS[1:k])

  ## Helper variables
  prev <- 0
  min <- current <- 10000
  current_iter <- 0L

  ## Main loop
  while(abs(prev - current) > threshold && current_iter < iter){
    prev <- current
    dist_matrix <- list_outer(centers, clouds, cloud_distance)
    groups <- letters[apply(dist_matrix, 2, which.min)]
    current <- sum(apply(dist_matrix, 2, min))
    grouped_clouds <- split(clouds, groups)
    centers <- lapply(grouped_clouds, do.call, what = rbind_clouds)
    if(current < min){ # min is not being re-assigned, bug?
      groups_min <- groups
    }
    current_iter <- current_iter + 1L
  }

  data.frame(group = names(clouds), cluster = groups_min)
}


#' j-clouds clustering
#'
#' @param df     data frame with the data to cluster
#' @param var    character or integer indicating the column name or position
#'               of the numeric column to evalute for defining the clusters, 1L
#'               by default
#' @param group  character or integer indicating the column name or position
#'               of the column that defines the treatments, 2L by default
#' @param k      integer, number of super-groups to cluster in (where to cut
#'               the hierarchichal tree)
#'
#' @return       a data frame with columns group and cluster.
#'                 - group: references the group variable
#'                 - cluster: a letter indicating the cluster to which the
#'                            group belongs
#' @export
j_clouds <- function(df, var = NULL, group = NULL, k = NULL){
  if (is.null(var)) var <- 1L
  if (is.null(group)) group <- 2L
  x <- df[[var]]
  y <- df[[group]]
  clouds <- lapply(split(x, y), cloud)

  dist_matrix <- stats::as.dist(list_outer(clouds, clouds, cloud_distance))
  ward_clust <- stats::hclust(dist_matrix, method = "ward.D")
  groups <- stats::cutree(ward_clust, k)

  data.frame(group = names(groups), cluster = letters[groups])
}
