#' Load Qualifying Results (not cached)
#'
#' Loads qualifying session results for a given season and round.
#'
#' @param season number from 1950 to 2022 (defaults to current season).
#' @param round number from 1 to 23 (depending on season), and defaults
#' to most recent.
#' @param type select drivers or constructors championship data. Defaluts to
#' drivers
#' @importFrom magrittr "%>%"
#' @return A dataframe with columns driverId (or constructorId), position,
#' points, wins and constructorsId in the case of drivers championship.

.load_standings <- function(season = 'current', round = 'last', type = 'driver'){
  if(season != 'current' & (season < 2003 | season > 2022)){
    stop('Year must be between 1950 and 2022 (or use "current")')
   }
  res <-  httr::GET(glue::glue('http://ergast.com/api/f1/{season}/{round}/{type}Standings.json?limit=40', season = season, round = round, type = type))
  data <- jsonlite::fromJSON(rawToChar(res$content))
  if(type == 'driver'){
    data$MRData$StandingsTable$StandingsLists$DriverStandings[[1]] %>%
    tidyr::unnest(cols = c(Driver)) %>%
    dplyr::select(driverId, position,points, wins, Constructors ) %>%
    tidyr::unnest(cols = c(Constructors)) %>%
    suppressWarnings() %>%
    suppressMessages() %>%
    dplyr::select(driverId, position,points, wins, constructorId) %>%
    tibble::as_tibble()
  } else if (type == 'constructor'){
    data$MRData$StandingsTable$StandingsLists$ConstructorStandings[[1]] %>%
    tidyr::unnest(cols = c(Constructor)) %>%
    suppressWarnings() %>%
    suppressMessages() %>%
    dplyr::select(constructorId, position, points, wins) %>%
    tibble::as_tibble()
  }

}

#' Load Qualifying Results
#'
#' Loads qualifying session results for a given season and round.
#'
#' @param season number from 1950 to 2022 (defaults to current season).
#' @param round number from 1 to 23 (depending on season), and defaults
#' to most recent.
#' #' @param type select drivers or constructors championship data. Defaluts to
#' drivers
#' @importFrom magrittr "%>%"
#' @return A dataframe with columns driverId (or constructorId), position,
#' points, wins and constructorsId in the case of drivers championship.
#' @export

load_standings <- memoise::memoise(.load_standings)

