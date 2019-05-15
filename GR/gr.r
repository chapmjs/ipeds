# gr.r

<<<<<<< HEAD
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

##  At this point I don't know the GR data well enough to make sense of the 
## different types of GR


# GRTYPE:
# 40	Total exclusions 4-year schools
# 2	  4-year institutions, Adjusted cohort (revised cohort minus exclusions)
# 3	  4-year institutions, Completers within 150% of normal time
# 4	  4-year institutions, Transfer-out students
# 41	4-year institutions, noncompleters still enrolled
# 42	4-year institutions, No longer enrolled

## What are the school's unitid?
svubyu %>%
  group_by(instnm, unitid) %>%
  summarize(n = n())

# instnm                          unitid     n
# <chr>                            <dbl> <int>
# 1 Brigham Young University-Hawaii 230047    16
# 2 Brigham Young University-Idaho  142522    27
# 3 Brigham Young University-Provo  230038    15
# 4 Southern Virginia University    233611    17

## What is the 2016 150% graduation rate for each school?
svubyu %>%
  filter(chrtstat == 13) %>% 
  group_by(instnm, unitid, chrtstat, grtotlt, cohort) %>%
  summarize(n = n())

 ## wait, why are there 2 cohorts for SVU?
 ## COHORT	1	Bachelor's/ equiv +  other degree/certif-seeking 2010 subcohorts (4-yr institution)
 ## COHORT	2	Bachelor's or equiv 2010  subcohort (4-yr institution)
 ## COHORT	3	Other degree/certif-seeking 2010 subcohort (4-yr institution)
 ## COHORT	4	Degree/certif-seeking students 2013 cohort ( 2-yr institution)

svubyu %>%
  filter(chrtstat == 13, cohort == 2) %>% #chrtstat of 13 is completers in 150%, cohort of 2 is bachelor's or equi 2010 subcohort 4yr inst
  group_by(instnm, unitid, chrtstat, grtotlt, cohort) %>%
  summarize(n = n())

 # Next, we need the total cohort for each school
svubyu %>%
  filter(chrtstat == 12, cohort == 2) %>% #chrtstat of 12 is adj cohort = revised - exclusions
  group_by(instnm, unitid, chrtstat, grtotlt, cohort) %>%
  summarize(n = n())

 # Next, how do I perform the last step - divide completers / total cohort?
   # should I combine the output into a single output?  then mutate?

svubyu %>%
  filter(chrtstat == 13, cohort == 2) %>% #chrtstat of 13 is completers in 150%, cohort of 2 is bachelor's or equi 2010 subcohort 4yr inst
  mutate (completers150 = grtotlt) %>%
  group_by(instnm, unitid, chrtstat, completers150, cohort) %>%
  summarize(n = n())

svubyucombined <- 
  merge(
  (svubyu %>%
    filter(chrtstat == 13, cohort == 2) %>% #chrtstat of 13 is completers in 150%, cohort of 2 is bachelor's or equi 2010 subcohort 4yr inst
    mutate (completers150 = grtotlt) %>%
    group_by(instnm, unitid, completers150, cohort) %>%
    summarize(n = n())),
  svubyu %>%
    filter(chrtstat == 12, cohort == 2) %>% #chrtstat of 13 is completers in 150%, cohort of 2 is bachelor's or equi 2010 subcohort 4yr inst
    mutate (totalcohort = grtotlt) %>%
    group_by(instnm, unitid, totalcohort, cohort) %>%
    summarize(n = n()),
  by = "unitid")
  
svubyuresults <-
  svubyucombined %>%
    mutate(grrate = completers150 / totalcohort) %>%
    select(instnm.x, unitid, completers150, totalcohort, grrate) %>%
    arrange(instnm.x)



# instnm.x
# 
# unitid
# 
# completers150
# 
# totalcohort
# 
# grrate
# 
# instnm.x
# 
# unitid
# 
# completers150
# 
# totalcohort

# grrate
# 1	Brigham Young University-Hawaii	230047	218	403	0.5409429
# 2	Brigham Young University-Idaho	142522	672	1196	0.5618729
# 3	Brigham Young University-Provo	230038	2837	3415	0.8307467
# 4	Southern Virginia University	233611	74	226	0.3274336

# Wed, May 15, 2019 2:03 pm, Wow! I did it. May not be elegant, but it's valid.
# Started at 11:15 this morning.  So, just under 3 hours to do this.  Not bad
# Next question I have is for those students that complete, 

# Q - What is the average time it takes to graduate?  Could SVU be < BYU's?

# Q - Can I do this for all schools in the data?
=======
# import 2016 gr data
>>>>>>> 3d90091d0124f3eefbb6c92928ad038215e2f2c1
