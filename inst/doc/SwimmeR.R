## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, message = FALSE---------------------------------------------------
library(SwimmeR)
library(rvest)
library(dplyr)
library(ggplot2)
library(scales)

## ----read_results, message = FALSE--------------------------------------------
file_path <- system.file("extdata", "Texas-Florida-Indiana.pdf", package = "SwimmeR")

file_read <- read_results(file = file_path)

## ----read_results output, message = FALSE-------------------------------------
file_read[294:303]

## ----swim_parse, message = FALSE----------------------------------------------
df <-
  swim_parse(
    file = file_read,
    typo = c("Indiana  University", ", University of"),
    replacement = c("Indiana University", "")
  )

## ----Swim Parse output, message = FALSE---------------------------------------
df[100:102,]

## ----read_results html, message = FALSE---------------------------------------
url <- "http://www.nyhsswim.com/Results/Girls/2003/NYS/Single.htm"
url_read <- read_results(file = url, node = "pre")

## ----read_results html output, message = FALSE--------------------------------
url_read[587:598]

## ----swim_parse html, message = FALSE-----------------------------------------
df_1 <- swim_parse(file = url_read, avoid = c("NY State Rcd:"))

## ----swim_parse html output, message = FALSE----------------------------------
df_1[358:360,]

## ----formatting times---------------------------------------------------------
data(King200Breast)
King200Breast

## ----formatting times 2-------------------------------------------------------
King200Breast <- King200Breast %>% 
  mutate(Time_sec = sec_format(Time),
         Time_swim_2 = mmss_format(Time_sec))
King200Breast

## ----formatted times plot, fig.height = 5, fig.width = 7----------------------
King200Breast %>% 
  ggplot(aes(x = Date, y = Time_sec)) +
  geom_point() +
  scale_y_continuous(labels = scales::trans_format("identity", mmss_format)) +
  theme_classic() +
  labs(y= "Time",
       title = "Lilly King NCAA 200 Breaststroke")

## ----get_mode setup-----------------------------------------------------------
Name <- c(rep("Lilly King", 5), rep("James Sullivan", 3))
Team <- c(rep("IU", 2), "Indiana", "IUWSD", "Indiana University", rep("Monsters University", 2), "MU")
df <- data.frame(Name, Team, stringsAsFactors = FALSE)
df

## ----get_mode-----------------------------------------------------------------
df <- df %>% 
  group_by(Name) %>% 
  mutate(Team = get_mode(Team))
df

## ----brackets 1---------------------------------------------------------------
teams <- c("red", "orange", "yellow", "green", "blue", "indigo", "violet")
draw_bracket(teams = teams)

## ----brackets 2---------------------------------------------------------------
round_two <- c("red", "yellow", "blue", "indigo")
draw_bracket(teams = teams,
             round_two = round_two)

## ----brackets 3---------------------------------------------------------------
round_three <- c("red", "blue")
draw_bracket(teams = teams,
             round_two = round_two,
             round_three = round_three)

## ----brackets champion--------------------------------------------------------
champion <- "red"
draw_bracket(teams = teams,
             round_two = round_two,
             round_three = round_three,
             champion = champion)

