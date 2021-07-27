# Web Scape Page KPK
# Robustness checked from 2020-04-01 to 2020-05-05

# Data from KPK
library(rvest)
library(stringr)
library(xlsx)
library(readxl)
library(tesseract)
library(magick)
library(magrittr)
library(stringr)

# get data from moh
cases_my = read.csv("https://raw.githubusercontent.com/MoH-Malaysia/covid19-public/main/epidemic/cases_malaysia.csv")
cases_state = read.csv("https://raw.githubusercontent.com/MoH-Malaysia/covid19-public/main/epidemic/cases_state.csv")
deaths_my = read.csv("https://raw.githubusercontent.com/MoH-Malaysia/covid19-public/main/epidemic/deaths_malaysia.csv")
deaths_state = read.csv("https://raw.githubusercontent.com/MoH-Malaysia/covid19-public/main/epidemic/deaths_state.csv")
# will be 1 day late
# so need to update 1 day after
icu_state = read.csv("https://raw.githubusercontent.com/MoH-Malaysia/covid19-public/main/epidemic/icu.csv")
# late by 2 days, may be better rely on press release
cases_my$date = as.Date(cases_my$date)
cases_state$date = as.Date(cases_state$date)
deaths_my$date = as.Date(deaths_my$date)
deaths_state$date = as.Date(deaths_state$date)
icu_state$date = as.Date(icu_state$date)

# scrape import, recovery, icu & breathing support data only, still incomplete from moh
my_date = Sys.Date() - 1  # add 1 day lag
# my_date = "2021-07-24"  # for specific date
my_yr = format(as.Date(my_date), "%Y")
my_day = format(as.Date(my_date), "%d")
my_day_no = as.numeric(my_day)
my_mo = format(as.Date(my_date), "%m")
my_mo_no = as.numeric(my_mo)
my_mo_list = c("januari", "februari", "mac", "april", "mei", "jun", "julai", "ogos", "september", "oktober", "november", "disember")
kpk_url = paste0("https://kpkesihatan.com/", my_yr, "/", my_mo, "/", my_day, "/kenyataan-akhbar-kpk-", my_day_no,
"-", my_mo_list[my_mo_no], "-", my_yr, "-situasi-semasa-jangkitan-penyakit-coronavirus-2019-covid-19-di-malaysia/")

# page:
kpk_page = try(read_html(kpk_url), T)
# test loaded
str(kpk_page)  # make sure html page is loaded, not error

# table: new cases
# table, 1-malay, 2-english
# table_loc = grep("KES BAHARU", html_nodes(kpk_page, "table"), ignore.case = T)
# still need to extract this table bcs the best way to extract imported cases
table_loc = grep("KES BAHARU", html_nodes(kpk_page, "table"), ignore.case = F)
my_cases = html_nodes(kpk_page, "table")[table_loc]
my_table = html_table(my_cases, fill = T, header = T)
my_table = as.data.frame(my_table)
my_table_raw = my_table  # for use in imported case
# remove brackets, from 24/4 starts having report of imported cases in (  )
cases_temp = vector("list", length(17))
# for (i in 1:17) cases_temp[i] = str_split(my_table[,2], " ")[[i]][1]
for (i in 1:17) cases_temp[i] = str_split(my_table[,2], "[(]")[[i]][1]
cases_temp = unlist(cases_temp)
cases_temp = str_trim(cases_temp)  # remove space
# end remove bracket attempt
my_table[,2] = as.numeric(str_remove_all(cases_temp, ","))
my_table[,3] = as.numeric(str_remove_all(my_table[,3], ","))

# text: other info
my_text = html_nodes(kpk_page, "p")
html_text(my_text)

# search for <li>: other info
my_li = html_nodes(kpk_page, "li")
# new structure starting from 20/1/2021

# search for <li> for recover, icu, support
if (my_date > "2021-01-19") {
  # recover
  loc = grep("Kes sembuh", my_li, ignore.case = T)
  recover = str_remove_all(gsub("[()]", "", html_text(my_li[loc])), ",")
  recover = as.numeric(str_extract(recover, "\\d+"))
  # icu
  loc = grep("ICU", my_li, ignore.case = T)
  # icu = str_remove_all(gsub("[()]", "", html_text(my_li[loc])), ",")
  icu = str_remove_all(gsub("[()]", "", html_text(my_li[loc[1]])), ",")
  icu = as.numeric(str_extract(icu, "\\d+"))
  # support
  loc = grep("pernafasan", my_li, ignore.case = T)
  support = str_remove_all(gsub("[()]", "", html_text(my_li[loc])), ",")
  support = as.numeric(str_extract(support, "\\d+"))
}
icu_state[icu_state$date == my_date,]
icu; support
sum(icu_state[icu_state$date == my_date, "icu_covid"]); sum(icu_state[icu_state$date == my_date, "vent_covid"])
sum(icu_state[icu_state$date == my_date, "bed_icu_covid"]); sum(icu_state[icu_state$date == my_date, "vent_port"])

# utilize data direct from moh
if (my_date > "2021-07-23") {
  # new cases
  new_cases = cases_my$cases_new[cases_my$date == my_date]
  # death
  new_deaths = deaths_my$deaths_new[deaths_my$date == my_date]
}

# data frame
data_all = data.frame(date=my_date, location="Malaysia", new_cases=new_cases, new_deaths=new_deaths, 
                      total_cases=NA, total_deaths=NA, recover=recover, total_recover=NA, 
                      icu=icu, support=support)
data_all
data_all$date = as.Date(data_all$date)
data_all = data_all[1,]  # make sure if there is rep row, only 1st row
data_all
# this one for all is very good, 100% accuracy

# read prexisting xls first, the append new row to existing dataframe
data_temp = read_xls("covid-19_my_full.xls")
data_temp = as.data.frame(data_temp)
data_temp = rbind(data_temp, data_all); tail(data_temp)
data_temp = as.data.frame(data_temp)
# write to xls, change to your file name
if (sum(sapply(c(data_all$new_cases, data_all$new_deaths, data_all$recover, data_all$icu, data_all$support), is.na)) == 0) {
  write.xlsx2(data_temp, "covid-19_my_full.xls", sheet = "main", showNA = F, row.names = F)
}

# === imported cases ===
my_table_import = my_table_raw
str_split(my_table_import[,2], " ")
cases_temp = vector("list", length(17))
for (i in 1:17) {
  cases_temp[i] = as.numeric(str_remove_all(gsub("[()]", "", str_split(my_table_import[,2], "[(]")[[i]][2]), ","))
}
cases_temp = unlist(cases_temp)
cases_temp[is.na(cases_temp)] = 0
my_table_import[,2] = cases_temp
colnames(my_table_import) = c("state", "new_cases", "total_cases")
# my_table = cbind(date = rep(my_date, dim(my_table)[1]), my_table[,-1])
# my_table  # do not read state, names always inconsistent
# data_state = my_table[,-1]
data_state_import = my_table_import[,-3]
# rearrange data_state
for (i in 1:length(negeri)) {
  data_state_import[i,] = my_table_import[loc_negeri[i],-3]
}
data_state_import
# numbers by state not reported in table 22/10/2020

# add new sheet to pre-existing xls, change to your file name
write.xlsx2(data_state_import, "covid-19_my_state_import.xls", sheetName = paste0(format(as.Date(my_date), "%Y%m%d")), append = T, showNA = F, row.names = F)

# extract only total imported cases
data_import = data.frame(date=my_date, imported_cases=cases_temp[17])
data_import
data_import$date = as.Date(data_import$date)
# read prexisting xls first, the append new row to existing dataframe
data_temp = read_xls("covid-19_my_import.xls")
data_temp = as.data.frame(data_temp)
data_temp = rbind(data_temp, data_import)
data_temp = as.data.frame(data_temp)
# write to xls, change to your file name
write.xlsx2(data_temp, "covid-19_my_import.xls", sheet = "main", showNA = F, row.names = F)


# to update with 2 days lag
# === state ===

# state name list
negeri = c("Perlis", "Kedah", "Pulau Pinang", "Perak", "Selangor", "Negeri Sembilan", "Melaka", "Johor", "Pahang", "Terengganu", "Kelantan", "Sabah", "Sarawak", "Kuala Lumpur", "Putrajaya", "Labuan")

# utilize data direct from moh
if (my_date > "2021-07-23") {
  # new cases state
  # new_cases_state = cases_state[cases_state$date == my_date, ]; new_cases_state
  # use from table at this moment, need to gen cumulative cases by state later
  # death
  new_deaths_state = deaths_state[deaths_state$date == my_date, ]; new_deaths_state
}

# get from table earlier
colnames(my_table) = c("state", "new_cases", "total_cases")
data_state = my_table  # not in order
# order according to negeri
loc_negeri = rep(0, length(negeri))
for (i in 1:length(negeri)) {
  loc_negeri[i] = grep(negeri[i], data_state$state, ignore.case = T)
}
loc_negeri
# rearrange data_state
for (i in 1:length(negeri)) {
  data_state[i,] = my_table[loc_negeri[i],]
}
data_state

# order for deaths
# order according to negeri
loc_negeri1 = rep(0, length(negeri))
for (i in 1:length(negeri)) {
  loc_negeri1[i] = grep(negeri[i], new_deaths_state$state, ignore.case = T)
}
loc_negeri1
# rearrange death counts
data_state_deaths = new_deaths_state[,-1]
for (i in 1:length(negeri)) {
  data_state_deaths[i,] = new_deaths_state[loc_negeri1[i], -1]
}
data_state_deaths

# add death counts
data_state$new_deaths = c(data_state_deaths[,2], sum(data_state_deaths[,2]))
data_state

# add new sheet to pre-existing xls, change to your file name
write.xlsx2(data_state, "covid-19_my_state.xls", sheetName = paste0(format(as.Date(my_date), "%Y%m%d")), append = T, showNA = F, row.names = F)

