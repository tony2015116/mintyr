#' @title nedap
#' @description Dairy cow feeding behavior dataset
#' @format A data frame with 31863 rows and 9 variables:
#' \describe{
#'   \item{\code{animal_number}}{integer Animal identification number}
#'   \item{\code{lifenumber}}{logical Life number of the animal}
#'   \item{\code{responder}}{integer Responder identification number}
#'   \item{\code{location}}{integer Feeding station location}
#'   \item{\code{visit_time}}{double Time of feeding visit}
#'   \item{\code{duration}}{integer Duration of feeding visit (minutes)}
#'   \item{\code{state}}{integer Status code}
#'   \item{\code{weight}}{integer Body weight (kg)}
#'   \item{\code{feed_intake}}{integer Feed intake amount (kg)}
#'}
"nedap"



#' @title fire
#' @description Feeding behavior dataset from Fire system
#' @format A data frame with 9794 rows and 10 variables:
#' \describe{
#'   \item{\code{Location}}{integer Feeding station identification number}
#'   \item{\code{Tag}}{integer Animal electronic tag number}
#'   \item{\code{Date}}{character Date of feeding visit}
#'   \item{\code{Entry}}{character Time when animal entered feeding station}
#'   \item{\code{Exit}}{character Time when animal left feeding station}
#'   \item{\code{Ent Wt}}{double Feed weight at entry (kg)}
#'   \item{\code{Ext Wt}}{double Feed weight at exit (kg)}
#'   \item{\code{Consumed}}{double Amount of feed consumed (kg)}
#'   \item{\code{Weight}}{double Animal body weight (kg)}
#'   \item{\code{Topup Amount}}{double Amount of feed added to bin (kg)}
#'}
"fire"
