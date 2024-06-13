## code to prepare `ppts_data` dataset goes here
nedap_files <- list.files("data-raw/nedap/", full.names = T, recursive = T)
nedap <- mintyr::import_csv(file = nedap_files)
nedap <- copy(nedap) |>
  tidyfst::filter_dt(location %in% c(501, 505)) |>
  tidyfst::mutate_dt(responder = str_sub(responder, 3, 7)) |>
  tidyfst::mutate_dt(location = ifelse(location == "501", "101",
                                       ifelse(location == "505", "102", location))) |>
  tidyfst::mutate_dt(animal_number = str_replace(animal_number, "^501", "101")) |>
  tidyfst::mutate_dt(animal_number = str_replace(animal_number, "^505", "102")) |>
  tidyfst::mutate_dt(animal_number = as.integer(animal_number),
                     responder = as.integer(responder),
                     location = as.integer(location))




fire <- mintyr::import_csv("data-raw/fire/丹系第2批采食数据.csv")
fire <- fire |>
  tidyfst::mutate_dt(Date = as.Date(Date) + lubridate::years(8),
                     Tag = str_replace(Tag, "9991680000", "")) |>
  tidyfst::filter_dt(Location %in% c(19, 20)) |>
  tidyfst::mutate_dt(Location = ifelse(Location == "19", "101",
                                       ifelse(Location == "20", "102", Location)),
                     Date = as.character(Date)) |>
  tidyfst::mutate_dt(
                     Location = as.integer(Location),
                     Tag = as.integer(Tag))

usethis::use_data(nedap, fire, overwrite = TRUE)
