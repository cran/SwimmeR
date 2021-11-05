## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, message = FALSE---------------------------------------------------
library(SwimmeR)
library(dplyr)

## ----read_results, message = FALSE--------------------------------------------
TX_FL_IN_path <- system.file("extdata", "Texas-Florida-Indiana.pdf", package = "SwimmeR")

TX_FL_IN_text <- read_results(file = TX_FL_IN_path)

## ----read_results output, message = FALSE-------------------------------------
TX_FL_IN_text[294:303]

## ----swim_parse, message = FALSE----------------------------------------------
TX_FL_IN_df <-
  swim_parse(
    file = TX_FL_IN_text,
    typo = c("Indiana  University", ", University of"), # not required in versions >= 0.7.0
    replacement = c("Indiana University", "") # not required in versions >= 0.7.0
  )

## ----Swim Parse output, message = FALSE---------------------------------------
TX_FL_IN_df[102:104,]

## ----read_results html, message = FALSE, eval=FALSE---------------------------
#  NYS_link <- "http://www.nyhsswim.com/Results/Girls/2003/NYS/Single.htm"
#  NYS_text <- read_results(file = NYS_link, node = "pre")

## ----read_results html actual, message = FALSE, echo = FALSE------------------
NYS_text_path <- system.file("extdata", "NYS_text.RDS", package = "SwimmeR")
NYS_text <- readRDS(NYS_text_path)

## ----read_results html output, message = FALSE--------------------------------
NYS_text[587:598]

## ----swim_parse html, message = FALSE-----------------------------------------
NYS_df <- swim_parse(file = NYS_text, avoid = c("NY State Rcd:"))

## ----swim_parse html output, message = FALSE----------------------------------
NYS_df[358:360,]

## ----splits output, message = FALSE-------------------------------------------
TX_FL_IN_df_splits <-
  swim_parse(
    read_results(TX_FL_IN_path),
    # typo = c("Indiana  University", ", University of"), # not required in versions >= 0.7.0
    # replacement = c("Indiana University", ""), # not required in versions >= 0.7.0
    splits = TRUE,
    split_length = 50
  )

TX_FL_IN_df_splits[100:102,]

## ----splits mixed, message = FALSE--------------------------------------------
df <- data.frame(
  Place = 1,
  Name = c("Lenore Lap", "Casey Cumulative"),
  Team = rep("KVAC", 2),
  Event = rep("Womens 200 Freestyle", 2),
  Finals_Time = rep("1:58.00", 2),
  Split_50 = rep("28.00", 2),
  Split_100 = c("31.00", "59.00"),
  Split_150 = c("30.00", "1:29.00"),
  Split_200 = c("29.00", "1:58.00")
)

df

## ----cumulative to lap, message = FALSE---------------------------------------
df %>% 
  filter(Name == "Casey Cumulative") %>% 
  splits_to_lap()

## ----cumulative to lap mixed, message = FALSE---------------------------------
df %>% 
  splits_to_lap(threshold = 35)

## ----lap to cumulative, message = FALSE---------------------------------------
df %>% 
  filter(Name == "Lenore Lap") %>% 
  splits_to_cumulative()

## ----lap to lap cumulative, message = FALSE-----------------------------------
df %>% 
  splits_to_cumulative(threshold = 20)

## ----relay swimmers output, message = FALSE-----------------------------------
TX_FL_IN_df_relay_swimmers <-
  swim_parse(
    read_results(TX_FL_IN_path),
    # typo = c("Indiana  University", ", University of"), # not required in versions >= 0.7.0
    # replacement = c("Indiana University", ""), # not required in versions >= 0.7.0
    relay_swimmers = TRUE
  )

TX_FL_IN_df_relay_swimmers[1:3,]

## ----swim_parse_ISL, message = FALSE------------------------------------------
file_url <-
  "https://github.com/gpilgrim2670/Pilgrim_Data/raw/master/ISL/Season_1_2019/ISL_16112019_CollegePark_Day_1.pdf"

if (SwimmeR:::is_link_broken(file_url) == TRUE) {
  warning("External data unavailable")
} else {
  file_read <- read_results(file_url)
  df_ISL <- swim_parse_ISL(file = file_read)
  df_ISL[which(df_ISL$Name == "KING Lilly"), ]
  
}

## ----formatting times---------------------------------------------------------
data(King200Breast)
King200Breast

## ----formatting times 2-------------------------------------------------------
King200Breast <- King200Breast %>% 
  dplyr::mutate(Time_sec = sec_format(Time),
         Time_swim_2 = mmss_format(Time_sec))
King200Breast

## ----formatted times plot, fig.height = 5, fig.width = 7----------------------
plot(King200Breast$Date, King200Breast$Time_sec, axes = FALSE, ann = FALSE)
axis(1, at = c(16800, 17200, 17600, 18000), labels = c(2016, 2017, 2018, 2019))
axis(2, at = c(125, 130, 135, 140), labels = mmss_format(c(125, 130, 135, 140)), las = 1)
par(mar = c(5,7,4,2) + 0.3)


## ----formatted times ggplot, eval = FALSE-------------------------------------
#  King200Breast %>%
#    ggplot(aes(x = Date, y = Time_sec)) +
#    geom_point() +
#    scale_y_continuous(labels = scales::trans_format("identity", mmss_format)) +
#    theme_classic() +
#    labs(y= "Time",
#         title = "Lilly King NCAA 200 Breaststroke")

## ----get_mode setup-----------------------------------------------------------
Name <- c(rep("Lilly King", 5), rep("James Sullivan", 3))
Team <- c(rep("IU", 2), "Indiana", "IUWSD", "Indiana University", rep("Monsters University", 2), "MU")
df <- data.frame(Name, Team, stringsAsFactors = FALSE)
df

## ----get_mode-----------------------------------------------------------------
df <- df %>% 
  dplyr::group_by(Name) %>% 
  dplyr::mutate(Team = get_mode(Team))
df

## ----brackets 1, fig.dim = c(8, 5)--------------------------------------------
teams <- c("red", "orange", "yellow", "green", "blue", "indigo", "violet")
draw_bracket(teams = teams)

## ----brackets 2, fig.dim = c(8, 5)--------------------------------------------
round_two <- c("red", "yellow", "blue", "indigo")
draw_bracket(teams = teams,
             round_two = round_two)

## ----brackets 3, fig.dim = c(8, 5)--------------------------------------------
round_three <- c("red", "blue")
draw_bracket(teams = teams,
             round_two = round_two,
             round_three = round_three)

## ----brackets champion, fig.dim = c(8, 5)-------------------------------------
champion <- "red"
draw_bracket(teams = teams,
             round_two = round_two,
             round_three = round_three,
             champion = champion)

