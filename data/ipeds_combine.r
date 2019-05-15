################################################################################
##
## COMBINE IPEDS DATASETS INTO A SINGLE WORKING DATASET
## Benjamin Skinner
##
################################################################################

## PURPOSE

## The purpose of this file is automate the process of:
##
## (1) combining yearly versions of IPEDS survey files (e.g.,
##     HD2010.csv, HD2011.csv)
## (2) combining datasets created in (1) into a single master dataset
##
## This file assumes you've downloaded the zipped files you will need
## from http://nces.ed.gov/ipeds/datacenter/DataFiles.aspx and placed
## this file (or file that runs this code) in the same directory.

## ORDER OF CODE - do not change

## (1) Functions
## (2) Build datasets (your code goes here)
## (3) Merge datasets
## (4) Output

## clear memory
rm(list=ls())
setwd("~/R/ipeds/data")

################################################################################
## FUNCTIONS
################################################################################

## unzip function (modified) from
## http://stackoverflow.com/questions/8986818/automate-zip-file-reading-in-r
read.zip <- function(zipfile) {
    # Create a name for the dir where we'll unzip
    zipdir <- tempfile()
    # Create the dir using that name
    dir.create(zipdir)
    # Unzip the file into the dir
    unzip(zipfile, exdir=zipdir)
    # Get the files into the dir
    files <- list.files(zipdir, recursive = TRUE)
    # Chose rv file if more than two
    if(length(files)>1) {
        file <- grep("*_rv.csv", files, value = TRUE)
    } else {
        file <- files[1]
    }
    # Get the full name of the file
    file <- paste(zipdir, file, sep="/")
    # Read the file
    read.csv(file, header=TRUE)
}

## combine IPEDS yearly files into single file
build.dataset <- function(regexzip, conditions = NULL, vars = NULL) {
    ## bring in list of zip files
    zfiles <- sort(grep(regexzip, list.files(), value = TRUE))
    ## loop through files
    for (i in 1:length(zfiles)) {
        ## unzip data with read.zip function
        data <- read.zip(zfiles[i])
        ## lower variable names in dataset
        names(data) <- tolower(names(data))
        ## subset data based on conditions
        if (!is.null(conditions)) {
            cond <- eval(parse(text = (gsub("(\\b[[:alpha:]]+\\b)",
                                        "data$\\1", conditions))))
            data <- data[cond,]
        }
        ## subset data based on rows needed
        if (!is.null(vars)) {
            data <- data[,vars]
        }
        ## get year from file name
        year <- as.numeric(gsub("\\D", "", zfiles[i]))
        ## convert split year (e.g., 0910 to 2009)
        if (year < 2000) {
            year <- round(year/100, digits=0) + 2000
        }
        ## add year column
        data$year <- year
        ## append dataset to prior data (data0)
        if(i == 1) {
            ## save a new data name for later rbind
            data0 <- data
        } else if(i == 2) {
            ## first appending
            result <- rbind(data0, data)
        } else {
            ## 
            result <- rbind(result, data)
        }
    }
    ## sort dataset: unitid by year
    result <- result[order(result$unitid,result$year),]
    ## return dataset
    return(result)
}

################################################################################
## BUILD DATASETS - INSERT YOUR CODE HERE
################################################################################

## NOTES ON CODE STRUCTURE

## The build.dataset() function takes three arguments:
## (NB: These require knowledge of the variables in the IPEDS survey files.)

## (1) regexzip   --> takes a regular expression of survey file names
##                    * only one type of IPEDS survey file per function
##                    * must take value

## (2) conditions --> takes conditional statement to subset by rows
##                    * entire conditional statement as single string
##                    * variable names only (no data$ prepend)
##                    * can be NULL if no condition needed

## (3) vars       --> takes variable names to subset by columns
##                    * variable names must be concatenated using c()
##                    * can be NULL if no condition needed

## You need to save to *.data so that the merge code below
## works. Give a unique name to each survey dataset group.

## EXAMPLE CODE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## IPEDS enrollment data (using EF*B.csv files)

## regexzip <- "EF[0-9]*B.zip$"
## cond <- "lstudy == 1 & line == 412"
## var <- c("unitid","efage05","efage06","efage09")
## enroll.data <- build.dataset(regexzip = regexzip,
##                              conditions = cond,
##                              vars = var)

## IPEDS institutional characterist data (using HH*.csv files)
## (NB: no condition used below)


# regexzip <- "HD[0-9]{4,}.zip$" - worked after seeing cheatsheet - https://github.com/rstudio/cheatsheets/raw/master/regex.pdf
# regexzip <- "HD[0-9]{4,}.zip$"
# var <- c("unitid","instnm","city","stabbr","zip","sector","iclevel",
#          "control","hloffer","ugoffer","groffer","carnegie")
# attr.data <- build.dataset(regexzip = regexzip,
#                            vars = var)


# Graduation Rates, no cond, no var
regexzip <- "GR[0-9]{4,}.zip$"
var <- c("unitid","grtype","cohort","grrace24")
attr.data <- build.dataset(regexzip = regexzip)



## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

################################################################################
## MERGE DATASETS
################################################################################

## NB: this code requires survey datasets with *.data
datasets <- ls(pattern = ".data\\b")
for(i in 1:length(datasets)) {
    if (i == 1) {
        final.data <- eval(parse(text = datasets[i]))
    } else {
        merge.data <- eval(parse(text = datasets[i]))
        final.data <- merge(final.data, merge.data,
                            by = c("unitid", "year"),
                            all.x = TRUE)
    }
}

################################################################################
## OUTPUT FINAL DATASET AS .CSV
################################################################################

## write.csv(final.data, file = "ipeds_HD.csv") 
write.csv(final.data, file = "ipeds_GR.csv") 
