# Generate csv files for covid-19 Malaysia

# library
library(tidyverse)
library(readxl)
# source the data
# source("covid-19_data_update_full.R")  # deprecated
# source("covid-19_data_update_state.R")  # deprecated
# source("covid-19_data_date_correct.R")  # deprecated
# source("covid-19_data_update_state_html.R")  # uncomment to update today
# up to 2020-03-29, date corrected

# Data from KPK
# ============= 

# Malaysia
# --------
covid_my_full = read.csv("covid-19_my_full_1.csv")  # data before 2020-03-30
covid_my_full$date = as.Date(covid_my_full$date)

# New data, 2020-03-30 onwards
library(readxl)
covid_my_append = read_excel("covid-19_my_full.xls", sheet = "main")
covid_my_full = rbind(covid_my_full, covid_my_append)

# generate total
covid_my_full$total_cases = cumsum(covid_my_full$new_cases)
covid_my_full$total_deaths = cumsum(covid_my_full$new_deaths)
covid_my_full$total_recover = cumsum(covid_my_full$recover)

# save data to csv
write.csv(covid_my_full, "covid-19_my.csv", row.names = F)

# New row - Imported Cases; from 24/4 onwards
imported_cases = read_excel("covid-19_my_import.xls", sheet = "main")$imported_cases
covid_my_full$imported_cases = c(rep(0, dim(covid_my_full)[1] - length(imported_cases)), imported_cases)

# New row - Noncitizen Cases; from 6/6 onwards
# noncitizen_cases = read_excel("covid-19_my_noncitizen.xls", sheet = "main")$noncitizen_cases
# covid_my_full$noncitizen_cases = c(rep(0, dim(covid_my_full)[1] - length(noncitizen_cases)), noncitizen_cases)
# not reliablly webscraped
  
# New rows - Events 
# first case in China
covid_my_full$china = 0
covid_my_full[covid_my_full$date >= "2019-12-31", "china"] = 1
covid_my_full$days_china = cumsum(covid_my_full$china)
# first case in Malaysia
covid_my_full$first = 0
covid_my_full[covid_my_full$date >= "2020-01-25", "first"] = 1
covid_my_full$days_first = cumsum(covid_my_full$first)
# first local transmission
covid_my_full$local = 0
covid_my_full[covid_my_full$date >= "2020-02-06", "local"] = 1
covid_my_full$days_local = cumsum(covid_my_full$local)
# uda holdings
covid_my_full$uda = 0
covid_my_full[covid_my_full$date >= "2020-03-02", "uda"] = 1
covid_my_full$days_uda = cumsum(covid_my_full$uda)
# tabligh event
covid_my_full$tabligh = 0
covid_my_full[covid_my_full$date >= "2020-02-28", "tabligh"] = 1
covid_my_full$days_tabligh = cumsum(covid_my_full$tabligh)
# movement control order, MCO
covid_my_full$mco = 0
covid_my_full[covid_my_full$date >= "2020-03-18", "mco"] = 1
covid_my_full$days_mco = cumsum(covid_my_full$mco)
# simpang renggam
covid_my_full$renggam = 0
covid_my_full[covid_my_full$date >= "2020-03-15", "renggam"] = 1
covid_my_full$days_renggam = cumsum(covid_my_full$renggam)
# CMCO/PKPB - 4/5/2020
covid_my_full$cmco = 0
covid_my_full[covid_my_full$date >= "2020-05-04", "cmco"] = 1
covid_my_full$days_cmco = cumsum(covid_my_full$cmco)
# RMCO/PKPP - 10/6/2020 - 31/8/2020
# import tak perlu kuarantin
covid_my_full$rmco = 0
covid_my_full[covid_my_full$date >= "2020-06-10", "rmco"] = 1
covid_my_full$days_rmco = cumsum(covid_my_full$rmco)

# view
tail(covid_my_full, 10)

# save data to csv
write.csv(covid_my_full, "covid-19_my_full.csv", row.names = F)
# test read data
test1 = read.csv("covid-19_my_full.csv")
test1$date = as.Date(test1$date)
str(test1)
colnames(test1)
test1$date

# State
# -----
covid_my_state = read.csv("covid-19_my_state_1.csv")  # data before 2020-03-30
covid_my_state$date = as.Date(covid_my_state$date)

# New data, 2020-03-30 onwards
date_start = as.Date("2020-03-30")
date_end = Sys.Date()  # change if required
# date_end = as.Date("2021-02-08")  # change if required, max date needed
date_range = date_start:date_end
state_append = covid_my_state$state[1:16]
for (i in 1:length(date_range)) {
  date_append = as.Date(date_range[i], origin = "1970-01-01")
  covid_my_state_append = read_excel("covid-19_my_state.xls", sheet = format(date_append, "%Y%m%d"))[1:16,-1]
  colnames(covid_my_state_append) = c("new_cases", "total_cases", "new_deaths")
  covid_my_state_append = cbind(date = date_append, state = state_append, covid_my_state_append, total_deaths = NA)
  covid_my_state = rbind(covid_my_state, covid_my_state_append)
}  # it will append from 2020-03-30 to today every time, not a very effective algorithm
# to make this better, so will only append the latest date

# generate total
covid_my_state = covid_my_state %>% group_by(state) %>% mutate(total_deaths = cumsum(new_deaths))
covid_my_state = as.data.frame(covid_my_state)

# view
tail(covid_my_state, 16*4)

# save data to csv
write.csv(covid_my_state, "covid-19_my_state.csv", row.names = F)
# test read data
test2 = read.csv("covid-19_my_state.csv")
test2$date = as.Date(test2$date)
str(test2)
colnames(test2)
tail(test2$date, 16*4)
