# gr.r

# import 2016 gr data



## GR data has been downloaded, but can't combine (on my own yet)  
## Next, let's take 2016, what is the GR of BYU, BYU-I, BYU,H, SVU?
## Need to identify schools in GR list by UNITID for 2016

getwd()
setwd("~/R/ipeds")

library(readxl)
gr2016 <- read_xlsx(path = "GR/gr2016_rv.xlsx")

hd2016 <- read_xlsx(path = "GR/hd2016.xlsx")


# merge instnm into gr data
## merge two data frames by ID
grhd2016 <- merge(gr2016,hd2016,by="UNITID")
names(grhd2016) <- tolower(names(grhd2016))
names(grhd2016)

# Filter by Southern Virginia, Brigham Young
library(dplyr)
library(stringr)
svubyu <- grhd2016 %>%
  filter (str_detect(instnm,"Southern Virginia|Brigham Young"))

