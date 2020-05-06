if (!exists("setup_env")) {
  stop("must be called from within setup.R")
}

setup_env$load_data <- function(stp) {
  env <- global_env()

  # figure out what region the selected stp is a part of, as well as the other
  # stps in that region
  region <- inner_join(
    file.path("data", "reference", "nhser18.csv") %>%
      read_csv(col_types = "cc"),
    file.path("data", "reference", "stp18cd_to_nhser18cd.csv") %>%
      read_csv(col_types = "cc"),
    by = "nhser18cd"
  ) %>%
    group_by(nhser18cd) %>%
    filter(any(stp18cd == stp))

  if (nrow(region) == 0) {
    stop("stp code does not exist")
  }

  env$region_name <- region[1,]$nhser18nm
  # all codes from the region
  env$region <- region$stp18cd

  env$pop_raw_all <- file.path("data", "reference", "population.csv") %>%
    read_csv(col_types = cols(
      ccg18cd = col_character(),
      ccg18cdh = col_character(),
      stp18cd = col_character(),
      area_names = col_character(),
      all_ages = col_double(),
      age = col_double(),
      count = col_double()
    )) %>%
    mutate(is_region_stp = stp18cd %in% env$region,
           is_stp = stp18cd == stp)

  env$pop_raw_region <- filter(pop_raw_all, is_region_stp)
  env$pop_raw <- filter(pop_raw_all, is_stp)

  # Get Geo Data ----
  # "https://opendata.arcgis.com/datasets/4669a971a0d94feb8d63fb0b28949998_4.geojson"
  env$stp_geo <- file.path("data", "geo") %>%
    st_read(layer = "stp",
            quiet = TRUE,
            stringsAsFactors = FALSE,
            as_tibble = TRUE) %>%
    mutate(is_stp = stp18cd == stp,
           is_region_stp = stp18cd %in% env$region)

  # "https://ons-inspire.esriuk.com/arcgis/services/Administrative_Boundaries/Countries_December_2018_Boundaries_GB_BUC/MapServer/WFSServer?request=GetCapabilities&service=WFS"
  env$countries <- file.path("data", "geo") %>%
    st_read(layer = "countries",
            quiet = TRUE,
            stringsAsFactors = FALSE,
            as_tibble = TRUE) %>%
    st_transform(crs = 27700)

  env$stp_name <- filter(stp_geo, is_stp)$stp18nm

  # Load MPI

  env$mpi_all <- file.path("data", "sensitive", "mpi.fst") %>%
    read_fst() %>%
    as_tibble() %>%
    mutate(is_region_stp = stp %in% env$region,
           # use curly-curly from rlang to ensure we are using the functions
           # argument
           is_stp = stp == {{stp}})

  env$mpi_region <- filter(env$mpi_all, is_region_stp)
  env$mpi <- filter(env$mpi_all, is_stp)

  env$activity_region <- file.path("data", "sensitive", "activity.fst") %>%
    read_fst() %>%
    as_tibble()

  env$activity <- semi_join(env$activity_region, mpi, by = "su_pat_id")

  env$forecast_activity <- file.path("data",
                                     "sensitive",
                                     "forecast_activity.fst") %>%
    read_fst() %>%
    as_tibble() %>%
    filter(stp == {{stp}})

  env$historical_deaths <- file.path("data",
                                     "sensitive",
                                     "historical_deaths.fst") %>%
    read_fst() %>%
    as_tibble() %>%
    filter(stp == {{stp}})

  env$forecast_deaths <- file.path("data",
                                   "reference",
                                   "forecast_deaths.csv") %>%
    read_csv(col_types = "ncncn") %>%
    filter(age_group >= 18, stp == {{stp}})

  env
}
