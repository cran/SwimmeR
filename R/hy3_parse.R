#' Parses Hy-Tek .hy3 files
#'
#' Helper function used inside `swim_parse` for dealing with Hy-Tek .hy3 files.
#' Can have more columns than other `swim_parse` outputs, because .hy3 files can
#' contain more data
#'
#' @importFrom dplyr mutate
#' @importFrom dplyr lead
#' @importFrom dplyr case_when
#' @importFrom dplyr select
#' @importFrom dplyr arrange
#' @importFrom dplyr left_join
#' @importFrom dplyr bind_rows
#' @importFrom dplyr summarise
#' @importFrom dplyr ungroup
#' @importFrom dplyr rowwise
#' @importFrom dplyr group_by
#' @importFrom stringr str_replace
#' @importFrom stringr str_replace_all
#' @importFrom stringr str_extract
#' @importFrom stringr str_extract_all
#' @importFrom stringr str_detect
#' @importFrom stringr str_length
#' @importFrom stringr str_split
#' @importFrom purrr map
#' @importFrom utils head
#' @importFrom utils tail
#'
#' @param file output from \code{read_results}
#' @param avoid a list of strings.  Rows in \code{x} containing these strings
#'   will not be included. For example "Pool:", often used to label pool
#'   records, could be passed to \code{avoid}.  The default is
#'   \code{avoid_default}, which contains many strings similar to "Pool:", such
#'   as "STATE:" and "Qual:".  Users can supply their own lists to \code{avoid}.
#' @param typo a list of strings that are typos in the original results.
#'   \code{swim_parse} is particularly sensitive to accidental double spaces, so
#'   "Central  High School", with two spaces between "Central" and "High" is a
#'   problem, which can be fixed.  Pass "Central High School" to \code{typo}.
#'   Unexpected commas as also an issue, for example "Texas, University of"
#'   should be fixed using \code{typo} and \code{replacement}
#' @param replacement a list of fixes for the strings in \code{typo}.  Here one
#'   could pass "Central High School" (one space between "Central" and "High")
#'   and "Texas" to \code{replacement} fix the issues described in \code{typo}
#' @return returns a data frame with columns \code{Name}, \code{Place},
#'   \code{Age}, \code{Team}, \code{Prelims}, \code{Finals}, &
#'   \code{Event}.  May also contain \code{Seed_Time}, \code{USA_ID}, and/or
#'   \code{Birthdate}.  Note all swims will have a \code{Finals}, even if
#'   that time was actually swam in the prelims (i.e. a swimmer did not qualify
#'   for finals).  This is so that final results for an event can be generated
#'   from just one column.
#'
#' @seealso \code{parse_hy3} must be run on the output of
#'   \code{\link{read_results}}
#' @seealso \code{parse_hy3} runs inside of \code{\link{swim_parse}}

hy3_parse <-
  function(file,
           avoid = avoid_minimal,
           typo = typo_default,
           replacement = replacement_default) {

    avoid_minimal <- c("Sammy Steroids")

    typo_default <- c("typo")

    replacement_default <- c("typo")

    #### testing ####
    # file <- read_results(system.file("extdata", "2020_NI_Champs_Qualifier_UNAC.hy3", package = "SwimmeR")) # works 11/12
    # file <- read_results(system.file("extdata", "Meet Results-2019 CIF SWIMMING AND  DIVING CHAMPIONSHIPS-10May2019-001.hy3", package = "SwimmeR")) # doesn't work 11/12
    # file <- add_row_numbers(text = file)
    # avoid = avoid_minimal
    # typo = typo_default
    # replacement = replacement_default

    file <- file %>%
      .[purrr::map_lgl(., ~ !any(stringr::str_detect(., avoid)))] %>%
      stringr::str_replace_all(stats::setNames(replacement, typo))

    # data beginning with E1M or E1F contains results from each swim (male and female respectively)
    entry <- file %>%
      stringr::str_extract_all("^E1M.*|^E1F.*") %>%
      .[purrr::map(., length) > 0] %>%
      stringr::str_replace_all("([:alpha:]{1,})\\s{1,}([:alpha:]{1,})", "\\1\\2") %>%
      trimws()

    entry <-
      unlist(purrr::map(entry, stringr::str_split, "\\s{1,}"),
             recursive = FALSE) %>%
      .[purrr::map(., length) > 2]

    entry_rows <- entry %>%
      purrr::map(tail, 1) %>%
      unlist()

    entry <- entry %>%
      # purrr::map(tail, -1) %>%
      purrr::map(head, 10)

    entry <- data.frame(entry, stringsAsFactors = FALSE) %>%
      t()
    rownames(entry) <- NULL

    entry <- data.frame(entry, stringsAsFactors = FALSE)

    if (stringr::str_detect(entry$`X2`[1], "^\\d{2,3}[:alpha:]$")) {
      entry <- entry[c("X1", "X2", "X7")]
    } else {
      entry <- entry[c("X2", "X3", "X9")]
    }

    colnames(entry) <- c("ID", "Event", "Seed_Time")
    entry$Row_Numb <- as.numeric(entry_rows)

    # entries are doubled in the case of prelims/finals
    # need to collect both prelim and final entry into one row
    entry <- entry %>%
      dplyr::group_by(ID, Event, Seed_Time) %>%
      dplyr::summarise(Row_Numb = min(as.numeric(Row_Numb))) %>%
      dplyr::arrange(Row_Numb) %>%
      dplyr::ungroup()

    entry <- entry %>%
      dplyr::mutate(ID_Numb = stringr::str_extract(ID, "^\\d{1,}"),
                    Row_Numb = as.numeric(Row_Numb)) %>%
      dplyr::mutate(Gender = dplyr::case_when(
        stringr::str_detect(ID, "MB$|MM$") ~ "M",
        stringr::str_detect(ID, "FG$|FW$") ~ "F"
      )) %>%
      dplyr::mutate(
        Course = stringr::str_extract(Seed_Time, "[:alpha:]$"),
        Course = dplyr::case_when(Course == "Y" ~ "Yard",
                                  Course == "M" ~ "Meter"),
        Event = dplyr::case_when(
          Event == "25A" ~ paste("25", Course,  "Freestyle"),
          Event == "50A" ~ paste("50", Course,  "Freestyle"),
          Event == "100A" ~ paste("100", Course,  "Freestyle"),
          Event == "200A" ~ paste("200", Course,  "Freestyle"),
          Event == "400A" ~ paste("400", Course,  "Freestyle"),
          Event == "500A" ~ paste("500", Course,  "Freestyle"),
          Event == "800A" ~ paste("800", Course,  "Freestyle"),
          Event == "1000A" ~ paste("1000", Course,  "Freestyle"),
          Event == "1500A" ~ paste("1500", Course,  "Freestyle"),
          Event == "1650A" ~ paste("1650", Course,  "Freestyle"),
          Event == "25B" ~ paste("25", Course,  "Backstroke"),
          Event == "50B" ~ paste("50", Course,  "Backstroke"),
          Event == "100B" ~ paste("100", Course,  "Backstroke"),
          Event == "200B" ~ paste("200", Course,  "Backstroke"),
          Event == "25C" ~ paste("25", Course,  "Breaststroke"),
          Event == "50C" ~ paste("50", Course,  "Breaststroke"),
          Event == "100C" ~ paste("100", Course,  "Breaststroke"),
          Event == "200C" ~ paste("200", Course,  "Breaststroke"),
          Event == "25D" ~ paste("25", Course,  "Butterfly"),
          Event == "50D" ~ paste("50", Course,  "Butterfly"),
          Event == "100D" ~ paste("100", Course,  "Butterfly"),
          Event == "200D" ~ paste("200", Course,  "Butterfly"),
          Event == "100E" ~ paste("100", Course,  "Individual Medley"),
          Event == "200E" ~ paste("200", Course,  "Individual Medley"),
          Event == "400E" ~ paste("400", Course,  "Individual Medley"),
          Event == "6F" ~ "1 mtr Diving (6 dives)",
          Event == "11F" ~ "1 mtr Diving (11 dives)"
        ),
        Seed_Time = stringr::str_remove(Seed_Time, "[:alpha:]$")
      ) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(
        Row_Min = as.numeric(Row_Numb),
        Row_Max = dplyr::lead(Row_Min, 1L, default = length(file) - 1),
        Row_Min = Row_Min - 0.1
      ) %>%
      dplyr::mutate(Finals = NA,
                    Prelims = NA) %>%
      dplyr::select(-ID,-Course) %>%
      dplyr::arrange(Row_Min)

    # Collect prelims and finals times as well as finals places

    finals <- hy3_times(file = file, type = "finals")
    prelims <- hy3_times(file = file, type = "prelims")
    places <- hy3_places(file = file, type = "finals")

    # add prelims and finals times as well as finals places to entry
    entry <-
      interleave_results(entries = entry,
                         results = finals,
                         type = "individual")
    entry <-
      interleave_results(entries = entry,
                         results = prelims,
                         type = "individual")

    entry <-
      interleave_results(entries = entry,
                         results = places,
                         type = "individual")


    suppressWarnings(entry <- entry %>%
      dplyr::mutate(DQ = case_when(stringr::str_detect(Finals, "Q") == TRUE ~ 1,
                                   TRUE ~ 0)) %>%
      dplyr::mutate(
        Seed_Time = stringr::str_remove(Seed_Time, "[A-Z]{1,}"),
        Prelims = stringr::str_remove(Prelims, "[A-Z]{1,}"),
        Finals = stringr::str_remove(Finals, "[A-Z]{1,}"),
      ) %>%
      na_if_character("0.00") %>%
      dplyr::mutate(Seed_Time = dplyr::case_when(is.na(Seed_Time) ~ "00.00",
                                          TRUE ~ Seed_Time),
                    Prelims = dplyr::case_when(is.na(Prelims) ~ "00.00",
                                             TRUE ~ Prelims),
                    Finals = dplyr::case_when(is.na(Finals) ~ "00.00",
                                            TRUE ~ Finals)) %>%
      dplyr::mutate(
        Seed_Time = dplyr::case_when(
          stringr::str_detect(Event, "Diving") == FALSE ~ mmss_format(as.numeric(Seed_Time)),
          stringr::str_detect(Event, "Diving") == TRUE ~ Seed_Time,
          TRUE ~ "00.00"
        ),
        Prelims = dplyr::case_when(
          stringr::str_detect(Event, "Diving") == FALSE ~ mmss_format(as.numeric(Prelims)),
          stringr::str_detect(Event, "Diving") == TRUE ~ Prelims,
          TRUE ~ "00.00"
        ),
        Finals = dplyr::case_when(
          stringr::str_detect(Event, "Diving") == FALSE ~ mmss_format(as.numeric(Finals)),
          stringr::str_detect(Event, "Diving") == TRUE ~ Finals,
          TRUE ~ Finals
        )
      ) %>%
      na_if_character("00.00") %>%
      dplyr::mutate(Place = as.numeric(Finals_Place)) %>%
      dplyr::select(-Finals_Place) %>%
      dplyr::mutate(Place = dplyr::case_when(Place == 0 ~ 100000,
                                      TRUE ~ Place)) %>%
      na_if_numeric(100000))

    # data beginning with D1M contains swimmer info (M for male, F for female)
    swimmer <- file %>%
      stringr::str_extract_all("^D1M.*|^D1F.*") %>%
      .[purrr::map(., length) > 0] %>%
      str_replace_all("([:alpha:]{1,})\\s([:alpha:]{1,})", "\\1\\2") %>%
      trimws()

    swimmer <-
      unlist(purrr::map(swimmer, stringr::str_split, "\\s{1,}"),
             recursive = FALSE)


    swimmer_rows <- swimmer %>%
      purrr::map(tail, 1) %>%
      unlist()

    swimmer <- swimmer %>%
      # purrr::map(tail, -1) %>%
      purrr::map(unique) %>%
      purrr::map(head, 7)

    # works for CA results 11/12 - reenable when completing hy3 work
    # swimmer <- swimmer %>%
    #   purrr::map(str_remove_all, "^\\d{1,4}$") %>%
    #   purrr::map(str_remove_all, "^N$") %>%
    #   purrr::map(str_remove_all, "^D1F\\d{1,}") %>%
    #   purrr::map(str_remove_all, "^D1M\\d{1,}")

    swimmer <- data.frame(swimmer, stringsAsFactors = FALSE) %>%
      t()
    rownames(swimmer) <- NULL

    # works for CA results 11/12 - reenable when completing hy3 work
    # swimmer <- data.frame(swimmer, stringsAsFactors = FALSE) %>%
    #   na_if_character("") %>%
    #   fill_left()

    swimmer <- data.frame(swimmer, stringsAsFactors = FALSE)

    swimmer <- swimmer %>%
      dplyr::mutate(
        ID = X2,
        First = X3,
        USA_ID = dplyr::case_when(
          stringr::str_detect(X4, "[A-Z]{3,}") ~ X4,
          stringr::str_detect(X5, "[A-Z]{3,}") ~ X5
        ),
        Birthdate = dplyr::case_when(
          stringr::str_detect(X5, "[A-Z]{3,}") == FALSE &
            stringr::str_length(X5) >= 6 ~ X5,
          stringr::str_detect(X6, "[A-Z]{3,}") == FALSE &
            stringr::str_length(X6) >= 6 ~ X6
        ),
        Age = dplyr::case_when(
          stringr::str_length(X5) < 6 &
            stringr::str_length(X5) >= 1 &
            X5 != "0" & stringr::str_detect(X4, "[A-Z]{3,}") == FALSE ~ X5,
          stringr::str_length(X6) < 6 &
            stringr::str_length(X6) >= 1 & X6 != "0" ~ X6,
          stringr::str_length(X6) >= 6 &
            stringr::str_length(X7) < 6 & X7 != "0" ~ X7
        )
      ) %>%
      dplyr::mutate(Row_Numb = as.numeric(swimmer_rows)) %>%
      dplyr::select(ID, First, USA_ID, Birthdate, Age, Row_Numb)

    swimmer <- swimmer %>%
      dplyr::mutate(
        ID_Numb = stringr::str_extract(ID, "^\\d{1,}"),
        Row_Numb = as.numeric(Row_Numb),
        Last_Name = stringr::str_remove(ID, ID_Numb),
        Name = paste0(Last_Name, ", ", First)
      ) %>%
      dplyr::select(-Last_Name,-First,-ID)


    # data beginning with C1 contains team info
    team <- file %>%
      stringr::str_extract_all("^C1.*") %>%
      .[purrr::map(., length) > 0] %>%
      str_replace_all("\\s{2,}Unattached", " Unattached") %>%
      trimws()

    team <-
      unlist(purrr::map(team, stringr::str_split, "\\s{2,}"), recursive = FALSE) %>%
      purrr::map(unique)

    team_rows <- team %>%
      purrr::map(tail, 1) %>%
      unlist()

    team <- team %>%
      purrr::map(head, 1) %>%
      purrr::map(paste, collapse = " ")

    team <-
      data.frame(Team = unlist(team), Row_Numb = as.numeric(team_rows)) %>%
      dplyr::mutate(Team = stringr::str_remove(Team, "^C1[A-Z]{1,} ")) %>%
      dplyr::mutate(
        Row_Min = as.numeric(Row_Numb),
        Row_Max = dplyr::lead(Row_Min, 1L, default = length(file)) - 1,
      )

    # data beginning with F1 contains relay info
    if(any(stringr::str_detect(file, "^F1.*")) == TRUE){
    relay <- file %>%
      stringr::str_extract_all("^F1.*") %>%
      .[purrr::map(., length) > 0] %>%
      # str_replace_all("([:alpha:]{1,})\\s{2,}([:alpha:]{1,})", "\\1\\2") %>%
      trimws()

    relay <-
      unlist(purrr::map(relay, stringr::str_split, "\\s{1,}"),
             recursive = FALSE) %>%
      purrr::map(unique)

    relay_rows <- relay %>%
      purrr::map(tail, 1) %>%
      unlist()

    relay <- relay %>%
      # purrr::map(tail, -1) %>%
      purrr::map(unique) %>%
      purrr::map(head, 9)

    relay <- data.frame(relay, stringsAsFactors = FALSE) %>%
      t()

    rownames(relay) <- NULL

    relay <- data.frame(relay, stringsAsFactors = FALSE)

    relay <- relay[c("X1", "X2", "X3", "X4", "X8", "X9")]

    colnames(relay) <-
      c("Team", "Relay_Rank", "ID", "Event", "X8", "X9")
    relay$Row_Numb <- as.numeric(relay_rows)

    relay <- relay %>%
      dplyr::mutate(
        Seed_Time = dplyr::case_when(
          stringr::str_detect(X8, "\\d{2,}\\.\\d{2,}") ~ X8,
          stringr::str_detect(X9, "\\d{2,}\\.\\d{2,}") ~ X9,
          TRUE ~ "NA"
        )
      ) %>%
      na_if_character("^NA$") %>%
      dplyr::select(-X8,-X9)

    relay <- relay %>%
      dplyr::group_by(Team, Relay_Rank, Event, Seed_Time, ID) %>%
      dplyr::summarise(Row_Numb = min(as.numeric(Row_Numb), na.rm = TRUE)) %>%
      dplyr::arrange(Row_Numb) %>%
      dplyr::ungroup()

    relay <- relay %>%
      dplyr::mutate(Gender = dplyr::case_when(
        stringr::str_detect(ID, "MB$|MM$|MXX$") ~ "M",
        stringr::str_detect(ID, "FG$|FW$|FXX$") ~ "F"
      )) %>%
      dplyr::mutate(
        Course = stringr::str_extract(Seed_Time, "[:alpha:]$"),
        Course = dplyr::case_when(Course == "Y" ~ "Yard",
                                  Course == "M" ~ "Meter"),
        Event = dplyr::case_when(
          Event == "200E" ~ paste("200", Course,  "Medley Relay"),
          Event == "400E" ~ paste("400", Course,  "Medley Relay"),
          Event == "200A" ~ paste("200", Course,  "Freesytle Relay"),
          Event == "400A" ~ paste("400", Course,  "Freesytle Relay"),
          Event == "800A" ~ paste("800", Course,  "Freesytle Relay")
        ),
        Seed_Time = stringr::str_remove(Seed_Time, "[:alpha:]$")
      ) %>%
      dplyr::mutate(
        Row_Min = as.numeric(Row_Numb),
        Row_Max = dplyr::lead(Row_Min, 1L, default = length(file) - 1),
        Row_Min = Row_Min - 0.1
      ) %>%
      dplyr::mutate(Finals = NA,
                    Prelims = NA) %>%
      dplyr::select(-Course,-Team,-Relay_Rank,-ID)


    # Collect times from prelims and finals, plus places from finals
    relay_finals <- hy3_times(file = file, type = "relay_finals")
    relay_prelims <- hy3_times(file = file, type = "relay_prelims")
    relay_places <- hy3_places(file = file, type = "relay_finals")

    # Add times and places into relay dataframe
    relay <-
      interleave_results(entries = relay,
                       results = relay_finals,
                       type = "relay")
    relay <-
      interleave_results(entries = relay,
                       results = relay_prelims,
                       type = "relay")

    # works for CA results 11/12 - reenable when completing hy3 work
    # relay  <-
    #   transform(relay, Finals_Place = relay_places$Finals_Place[findInterval(Row_Min, relay_places$Row_Numb, all.inside = TRUE)])

    relay <-
      interleave_results(entries = relay,
                         results = relay_places,
                         type = "relay")

   # Clean up relay dataframe
    suppressWarnings(relay <- relay %>%
      dplyr::mutate(DQ = case_when(stringr::str_detect(Finals, "Q") == TRUE ~ 1,
                                   TRUE ~ 0)) %>%
      dplyr::mutate(
        Seed_Time = stringr::str_remove(Seed_Time, "[A-Z]{1,}"),
        Prelims = stringr::str_remove(Prelims, "[A-Z]{1,}"),
        Finals = stringr::str_remove(Finals, "[A-Z]{1,}")
      ) %>%
      dplyr::mutate(
        Seed_Time = mmss_format(as.numeric(Seed_Time)),
        Prelims = mmss_format(as.numeric(Prelims)),
        Finals = mmss_format(as.numeric(Finals))
      ) %>%
      na_if_character("00.00") %>%
      dplyr::mutate(Place = as.numeric(Finals_Place)) %>%
      dplyr::select(-Finals_Place) %>%
      dplyr::mutate(Place = dplyr::case_when(Place == 0 ~ 100000,
                                             TRUE ~ Place)) %>%
      na_if_numeric(100000))
    } else {
      relay <- data.frame(
        Name = character(),
        Place = numeric(),
        Age = character(),
        Team = character(),
        Prelims = character(),
        Finals = character(),
        Row_Numb = character(),
        stringsAsFactors = FALSE
      )
    }

    #### Binding up data
    data <- dplyr::left_join(swimmer, entry, by = "ID_Numb") %>%
      dplyr::rowwise() %>%
      dplyr::mutate(Row_Numb = min(c(Row_Numb.x, Row_Numb.y), na.rm = TRUE)) %>%
      dplyr::select(-Row_Numb.x,-Row_Numb.y)

    data <- dplyr::bind_rows(data, relay)

    data  <-
      transform(data, Team = team$Team[findInterval(Row_Numb, team$Row_Min)])

    data <- data %>%
      dplyr::mutate(
        Finals = dplyr::case_when(
          stringr::str_detect(Finals, "[:alpha:]") ~ "Bad Entry",
          TRUE ~ Finals
        ),
        Prelims = dplyr::case_when(
          stringr::str_detect(Prelims, "[:alpha:]") ~ "Bad Entry",
          TRUE ~ Prelims
        )
      ) %>%
      na_if_character("Bad Entry") %>%
      dplyr::mutate(Finals = dplyr::case_when((is.na(Prelims) == FALSE &
                                                      is.na(Finals) == TRUE) ~ Prelims,
                                                   TRUE ~ Finals
      )) %>%
      dplyr::mutate(
        Birthdate = stringr::str_extract(USA_ID, "\\d{6,8}"),
        USA_ID = dplyr::case_when(stringr::str_length(USA_ID) < 8 ~ "Bad Entry",
                                  TRUE ~ USA_ID)
      ) %>%
      na_if_character("Bad Entry") %>%
      dplyr::select(-Row_Min,-Row_Max,-Row_Numb,-ID_Numb)

    ## cleaning up data
    data <- data %>%
      dplyr::mutate(
        Finals = dplyr::case_when(
          is.na(Finals) == TRUE &
            is.na(Prelims) == FALSE ~ Prelims,
          TRUE ~ Finals
        )
      ) %>%
      na_if_character("00.00")
      # filter(is.na(Finals) == FALSE | is.na(Prelims) == FALSE)

    return(data)

  }
