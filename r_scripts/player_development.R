##### Packages & Functions #####

library(data.table)
library(rlist)
library(plyr)
library(tidyverse)
library(XML)

##### Data Import #####

data <- map_dfr(.x = list.files(path = "data/player_development", full.names = TRUE),
                .f = function(x) {
                  
                  readHTMLTable(
                    htmlParse(
                      x, encoding = "UTF-8"
                    )
                  ) %>%
                    as.data.frame() %>%
                    mutate(
                      year = suppressWarnings(
                        as.numeric(
                          str_extract(
                            x,
                            "[0-9]+"
                          )
                        )
                      )
                    ) %>%
                    select(
                      "name" = "NULL.Name",
                      "age" = "NULL.Age",
                      "pa" = "NULL.PA",
                      "ambition" = "NULL.Amb",
                      "determination" = "NULL.Det",
                      "professionalism" = "NULL.Prof",
                      "year",
                      "ca" = "NULL.CA",
                      "appearances" = "NULL.Apps",
                      "starts" = "NULL.Starts",
                      "minutes" = "NULL.Mins"
                    ) %>%
                    mutate(
                      subs = ifelse(
                        appearances == "-",
                        0,
                        ifelse(
                          str_detect(
                            appearances,
                            "\\("
                          ),
                          suppressWarnings(
                            as.numeric(
                              str_sub(
                                str_extract(
                                  appearances,
                                  "\\(([0-9]+)"
                                ),
                                2L
                              )
                            )
                          ),
                          0
                        )
                      ),
                      starts = ifelse(
                        starts == "-",
                        0,
                        suppressWarnings(
                          as.numeric(
                            starts
                          )
                        )
                      ),
                      minutes = ifelse(
                        minutes == "-",
                        0,
                        suppressWarnings(
                          as.numeric(
                            str_replace_all(
                              minutes,
                              ",",
                              ""
                            )
                          )
                        )
                      ),
                      appearances = starts + subs,
                      across(
                        c("age", "pa", "ambition", "determination", "professionalism", "ca"),
                        ~ suppressWarnings(
                          as.numeric(.x)
                        )
                      )
                    )
                  
                }) %>%
  arrange(
    year
  ) %>%
  group_by(
    name
  ) %>%
  mutate(
    year_number = row_number()
  ) %>%
  ungroup() %>%
  select(
    1:7,
    "year_number",
    8:11
  )

stats <- data %>%
  mutate(
    pa_group = case_when(
      pa %between% c(101, 110) ~ 1,
      pa %between% c(111, 120) ~ 2,
      pa %between% c(121, 130) ~ 3,
      pa %between% c(131, 140) ~ 4,
      pa %between% c(141, 150) ~ 5,
      pa %between% c(151, 160) ~ 6,
      pa %between% c(161, 170) ~ 7,
      pa %between% c(171, 180) ~ 8,
      pa %between% c(181, 190) ~ 9,
      pa %between% c(191, 200) ~ 10,
      .default = NA
    )
  ) %>%
  group_by(
    name
  ) %>%
  mutate(
    ca_change = ca - lag(ca)
  ) %>%
  ungroup() %>%
  group_by(
    age,
    pa_group
  ) %>%
  reframe(
    mean = round(
      mean(
        ca_change,
        na.rm = TRUE
      ),
      2
    )
  )
