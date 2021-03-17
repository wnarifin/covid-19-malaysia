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

my_date = Sys.Date()
# my_date = "2021-03-16"  # for specific date
my_day = format(as.Date(my_date), "%d")
my_day_no = as.numeric(my_day)
my_mo = format(as.Date(my_date), "%m")
my_mo_no = as.numeric(my_mo)
my_mo_list = c("januari", "februari", "mac", "april", "mei", "jun", "julai", "ogos", "september", "oktober", "november", "disember")
# === 2021 ===
kpk_url = paste0("https://kpkesihatan.com/2021/", my_mo, "/", my_day, "/kenyataan-akhbar-kpk-", my_day_no,
"-", my_mo_list[my_mo_no], "-2021-situasi-semasa-jangkitan-penyakit-coronavirus-2019-covid-19-di-malaysia/")
# uncomment this line for 2020
# kpk_url = paste0("https://kpkesihatan.com/2020/", my_mo, "/", my_day, "/kenyataan-akhbar-kpk-", my_day_no,
# "-", my_mo_list[my_mo_no], "-2020-situasi-semasa-jangkitan-penyakit-coronavirus-2019-covid-19-di-malaysia/")
# ===
# kpk_url1 = paste0("https://kpkesihatan.com/2020/", my_mo, "/", my_day, "/kenyataan-akhbar-", my_day_no,
#                  "-", my_mo_list[my_mo_no], "-2020-situasi-semasa-jangkitan-penyakit-coronavirus-2019-covid-19-di-malaysia/")
# date: 2020-04-16, no -kpk
# https://kpkesihatan.com/2020/04/16/kenyataan-akhbar-16-april-2020-situasi-semasa-jangkitan-penyakit-coronavirus-2019-covid-19-di-malaysia/
# kpk_url1 = "https://kpkesihatan.com/2020/05/13/kenyataan-akhbar-kpk-13-may-2020-situasi-semasa-jangkitan-penyakit-coronavirus-2019-covid-19-di-malaysia/"
# 2020-05-13, may instead of mei
# date: 2020-05-28
# kpk_url1 = "https://kpkesihatan.com/2020/05/28/situasi-semasa-jangkitan-penyakit-coronavirus-2019-covid-19-di-malaysia/"
# date: 2020-06-18
# kpk_url1 = "https://kpkesihatan.com/2020/06/18/kenyataan-akhbar-kpk-situasi-semasa-jangkitan-penyakit-coronavirus-2019-covid-19-di-malaysia/"
# date: 2020-07-16
# kpk_url1 = "https://kpkesihatan.com/2020/07/16/kenyataan-akhbar-kkm-16-julai-2020-situasi-semasa-jangkitan-penyakit-coronavirus-2019-covid-19-di-malaysia/"
# date: 2020-07-26
# kpk_url1 = "https://kpkesihatan.com/2020/07/26/kenyataan-akhbar-kementerian-kesihatan-malaysia-situasi-semasa-jangkitan-penyakit-coronavirus-2019-covid-19-di-malaysia/"
# date: 2020-11-19
# kpk_url1 = "https://kpkesihatan.com/2020/11/19/kenyataan-akhbar-kpk-19-november-2020-situasi-semasa-jangkitan-penyakit-coronavirus-2019-covid-19-di-malaysia/"
# date: 2020-12-10, funny the date is 10-dis but url is 9-dis
kpk_url1 = "https://kpkesihatan.com/2020/12/10/kenyataan-akhbar-kpk-9-disember-2020-situasi-semasa-jangkitan-penyakit-coronavirus-2019-covid-19-di-malaysia-2/"

# page
# slow internet:
# system("rm temp.html")
# system(paste("aria2c -c", kpk_url, "-o temp.html")) # for slow internet
# kpk_page = try(read_html("temp.html"), T)
# if (class(kpk_page) == "try-error") {
#   system(paste("aria2c -c", kpk_url1, "-o temp.html"))
#   kpk_page = try(read_html("temp.html"), T)} else {kpk_page}
# normal:
kpk_page = try(read_html(kpk_url), T)
if (class(kpk_page) == "try-error") {kpk_page = try(read_html(kpk_url1), T)} else {kpk_page}
# test loaded
str(kpk_page)  # make sure html page is loaded, not error

# save image recover for record purpose
# it seems KKM no longer update recovery by states since 2020-12-30
# so code block below is commented out
# img_node = html_nodes(kpk_page, "img")
# img_loc = grep("discaj", img_node, ignore.case = T)  # get node with discaj
# if (length(img_loc) == 0) {img_loc = grep("sembuh", img_node, ignore.case = T)}  # get node with discaj
# if (length(img_loc) == 0) {img_loc = grep("picture1", img_node, ignore.case = T)}  # 2020-12-14
# if (length(img_loc) == 0) {img_loc = grep("whatsapp", img_node, ignore.case = T)}  # 2020-12-17
# if (length(img_loc) == 0) {img_loc = grep("3.png", img_node, ignore.case = T)}  # 2020-12-25? nondescriptive name
# if (length(img_loc) == 0) {img_loc = grep("29-dis-3", img_node, ignore.case = T)}  # 2020-12-29? nondescriptive name
# img_link = html_attr(img_node[img_loc], "data-orig-file")  # get the content of attribute in a tag
# img_ext = str_split(img_link, "[.]", simplify = T); img_ext = img_ext[length(img_ext)]  # get extension
# download.file(img_link, destfile = paste0("recover_data_state/img/", my_date, ".", img_ext))
# # system(paste0("wget -c ", img_link, " -O recover_data_state/", my_date, ".", img_ext))
# setwd("recover_data_state/recover_R/")
# source("get_recover_img_update_my.R")
# setwd("../../")

# table
# table, 1-malay, 2-english
# table_loc = grep("KES BAHARU", html_nodes(kpk_page, "table"), ignore.case = T)
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

# text
my_text = html_nodes(kpk_page, "p")
html_text(my_text)

loc = grep("kes.*yang telah pulih", html_text(my_text), ignore.case = T, perl = T)
# bcs somehow some guy add extra spaces between kes & yang which are not spaces!
if (!is.na(loc[2])) loc = loc[2]
# Method 1:
# pulih = html_nodes(my_text[loc], "strong")[grep("kes", html_nodes(my_text[loc], "strong"))] # not working, inconsistent <strong> placement
# pulih = html_nodes(my_text[loc], "strong")[1]
# recover = as.numeric(word(html_text(pulih, trim = T)))
# Method 2:
# pulih = str_split(html_text(my_text[loc]), "kes", simplify = T)[1]
pulih = str_split(html_text(my_text[loc]), "kes[.]", simplify = T)[1]
pulih_ = str_split(pulih, "terdapat", simplify = T)[2]
if (is.na(pulih_)) {pulih_ = str_split(pulih, "sebanyak", simplify = T)[2]}
recover = as.numeric(str_trim(pulih_))
if(is.na(recover)) {
  recover = str_split(str_trim(pulih_), " ", simplify = T);
  recover = as.numeric(str_remove_all(gsub("[()]", "", recover), ","))
} # remove comma from number > 1K
if(is.na(recover)) {
  recover = str_split(str_trim(pulih_), " ", simplify = T)[2];
  recover = as.numeric(str_remove_all(gsub("[()]", "", recover), ","))
} # sometime number preceded by other word than sebanyak
# they started to use sembuh 2020-11-19
loc1 = grep("kes.*yang telah pulih", html_text(my_text), ignore.case = T, perl = T)
# bcs somehow some guy add extra spaces between kes & yang which are not spaces!
if (is.na(loc1[2]) | is.na(recover)) {
  loc = grep("kes.*sembuh", html_text(my_text), ignore.case = T, perl = T)
  sembuh = str_split(html_text(my_text[loc]), "kes[,]", simplify = T)[1]
  sembuh_ = str_split(sembuh, "sebanyak", simplify = T)[2]
  recover = as.numeric(str_trim(sembuh_))
  if(is.na(recover)) {
    recover = str_split(str_trim(sembuh_), " ", simplify = T);
    recover = as.numeric(str_remove_all(gsub("[()]", "", recover), ","))
  } # remove comma from number > 1K
  if(is.na(recover)) {
    recover = str_split(str_trim(sembuh_), " ", simplify = T)[2];
    recover = as.numeric(str_remove_all(gsub("[()]", "", recover), ","))
  }
}
if (length(recover) > 1) {
  loc = grep("kes.*sembuh", html_text(my_text), ignore.case = T, perl = T)
  sembuh = str_split(html_text(my_text[loc]), "kes[.]", simplify = T)[1]
  sembuh_ = str_split(sembuh, "sebanyak", simplify = T)[2]
  recover = as.numeric(str_trim(sembuh_))
  if(is.na(recover)) {
    recover = str_split(str_trim(sembuh_), " ", simplify = T);
    recover = as.numeric(str_remove_all(gsub("[()]", "", recover), ","))
  } # remove comma from number > 1K
  if(is.na(recover)) {
    recover = str_split(str_trim(sembuh_), " ", simplify = T)[2];
    recover = as.numeric(str_remove_all(gsub("[()]", "", recover), ","))
  }
}

# from text not reliable, page often mention kes baharu everywhere
# loc = grep("kes baharu yang telah dilaporkan", html_text(my_text), ignore.case = T)
# loc = grep("kes baharu", html_text(my_text), ignore.case = T)
# baru = html_nodes(my_text[loc], "strong")[1]
# new_cases = as.numeric(word(html_text(baru, trim = T)))
new_cases = my_table[17, 2]  # more reliable from table

loc = grep("dirawat di Unit Rawatan Rapi", html_text(my_text), ignore.case = T)
if(length(loc) == 0) {loc = grep("dirawat di.*Unit Rawatan Rapi", html_text(my_text), ignore.case = T)}
# Method 1:
# urr = html_nodes(my_text[loc], "strong")[grep("kes positif", html_nodes(my_text[loc], "strong"))] # not working, inconsistent <strong> placement
# urr = html_nodes(my_text[loc], "strong")[1]
# icu = as.numeric(word(html_text(urr, trim = T)))
# problematic day, 3/5/2020, use:
# urr = html_nodes(my_text[loc], "strong")[2]
# icu = as.numeric(word(html_text(urr, trim = T)))
# Method 2:
urr = str_split(html_text(my_text[loc]), "kes", simplify = T)[1]
# urr = str_split(html_text(my_text[loc]), "kes positif", simplify = T)[1]
urr1 = str_split(urr, "seramai", simplify = T)[2]
if(is.na(urr1)) {urr1 = str_split(urr, "sebanyak", simplify = T)[2]}
if(is.na(urr1)) {urr1 = str_split(urr, "terdapat", simplify = T)[2]}
if(is.na(urr1)) {urr1 = str_split(urr, "hanya", simplify = T)[2]}
if(is.na(urr1)) {urr1 = str_split(urr, "bahawa", simplify = T)[2]}
if(str_trim(urr1) == "tiada") {urr1 = 0}
if(is.na(as.numeric(str_trim(urr1)))) {urr1 = str_split(str_trim(urr1), " ", simplify = T)[2]}
if(is.na(urr1)) {urr1 = str_split(urr, ",", simplify = T)[2]}
urr1 = str_trim(urr1)
icu = as.numeric(gsub("[()]", "", urr1))

# loc = grep("kes memerlukan bantuan pernafasan", my_text, ignore.case = T)
# loc = grep("memerlukan bantuan pernafasan", my_text, ignore.case = T)
loc = grep("memerlukan bantuan pernafasan", my_text, ignore.case = T)[1]
bantuan = grep("bantuan", str_split(html_text(my_text[loc]), " ", simplify = T))
# support = as.numeric(word(html_text(my_text[loc]), bantuan - 3))
support = word(html_text(my_text[loc]), bantuan - 3)
# str_extract(str_split(html_text(my_text[loc]), " ", simplify = T), "\\d+")  # will implement str_extract here in code revision
if(support == "kes") {support = word(html_text(my_text[loc]), bantuan - 4)}
# --- cannot split issues:
# 28/10
if(support == "di") {support = 25}
# 29/10 also cannot split, can't even detect sentence by if!
if (my_date == "2020-10-29") {support = 23}
# 2/12
if(support == "mana") {support = 47}
# 19/12, "(ICU), di" cannot be detected
if(my_date == "2020-12-19") {support = 56}
# 20/12, "(ICU), di" cannot be detected
if(my_date == "2020-12-20") {support = 57}
# 5/1, 9/1 "cannot separate text & number"
if(my_date == "2021-01-05") {support = 52}
if(my_date == "2021-01-09") {support = 82}
# ---
if(support == "tiada" | support == "Tiada") {support = 0}
if(support == "Kedua-dua") {support = 2}
if(support == "dan") {support = 1}
support = as.numeric(str_remove_all(gsub("[()]", "", support), ","))
if(is.na(support) == T) {
  support = word(html_text(my_text[loc]), bantuan - 2)
  support = as.numeric(str_remove_all(gsub("[()]", "", support), ","))}  # sometimes word split doesn't work
if (is.na(loc)) {support = 0}

# search for <li>
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

# search for <li> for death count
loc = grep("Kes kematian", my_li)
new_deaths = length(loc)
# cannot use this method starting from 8/10
# need to write new method, count table rows
# search for death table
if (my_date > "2020-10-07") {
  # table_deaths_loc = grep("KEMATIAN", html_nodes(kpk_page, "table"), ignore.case = T)  # will capture another table
  table_deaths_loc = grep("KES.*KEMATIAN", html_nodes(kpk_page, "table"), ignore.case = T, perl = T)
  # if (length(table_deaths_loc) == 0) {table_deaths_loc = grep("KES.*KEMATIAN", html_nodes(kpk_page, "table"), ignore.case = T, perl = T)}
  if (length(table_deaths_loc) == 0) {table_deaths_loc = grep("NO.*KEMATIAN", html_nodes(kpk_page, "table"), ignore.case = T, perl = T)}
  if (length(table_deaths_loc) == 0) {table_deaths_loc = grep(".*NO.*KEMATIAN", html_nodes(kpk_page, "table"), ignore.case = T, perl = T)}
  if (length(table_deaths_loc) == 0) {table_deaths_loc = grep("LATAR BELAKANG", html_nodes(kpk_page, "table"), ignore.case = T, perl = T)}
  my_deaths = html_nodes(kpk_page, "table")[table_deaths_loc]
  my_table_deaths = html_table(my_deaths, fill = T, header = T)
  my_table_deaths = as.data.frame(my_table_deaths)
  # str(my_table_deaths)
  new_deaths = nrow(my_table_deaths)
}

# data frame
data_all = data.frame(date=my_date, location="Malaysia", new_cases=new_cases, new_deaths=new_deaths, 
                      total_cases=NA, total_deaths=NA, recover=recover, total_recover=NA, 
                      icu=icu, support=support)
data_all
data_all$date = as.Date(data_all$date)
# this one for all is very good, 100% accuracy

# read prexisting xls first, the append new row to existing dataframe
data_temp = read_xls("covid-19_my_full.xls")
data_temp = as.data.frame(data_temp)
data_temp = rbind(data_temp, data_all); tail(data_temp)
data_temp = as.data.frame(data_temp)
# write to xls, change to your file name
if (sum(sapply(c(new_cases, new_deaths, recover, icu, support), is.na)) == 0) {
  write.xlsx2(data_temp, "covid-19_my_full.xls", sheet = "main", showNA = F, row.names = F)
}

# === state ===

# get from <li> earlier
# deaths by state [trial]
negeri = c("Perlis", "Kedah", "Pulau Pinang", "Perak", "Selangor", "Negeri Sembilan", "Melaka", "Johor", "Pahang", "Terengganu", "Kelantan", "Sabah", "Sarawak", "Kuala Lumpur", "Putrajaya", "Labuan")
negeri_text = html_text(my_li[loc])
if (my_date > "2020-10-07") {
  negeri_text = my_table_deaths[,"Hospital"]
}
for (i in 1:new_deaths) {
  # replacements
  # take into account sometime they mention name with state
  # sometime they don't
  negeri_text = str_replace_all(negeri_text, "Pusat Perubatan Kuala Lumpur, Kuala Lumpur", "-, Kuala Lumpur")
  negeri_text = str_replace_all(negeri_text, "Pusat Perubatan Kuala Lumpur", "Kuala Lumpur")
  negeri_text = str_replace_all(negeri_text, "Hospital Tuaran, Sabah", "-, Sabah")
  negeri_text = str_replace_all(negeri_text, "Hospital Tuaran", "Sabah")
  negeri_text = str_replace_all(negeri_text, "Hospital Duchess of Kent, Sabah", "-, Sabah")
  negeri_text = str_replace_all(negeri_text, "Hospital Duchess of Kent", "Sabah")
  negeri_text = str_replace_all(negeri_text, "Hospital Queen Elizabeth, Sabah", "-, Sabah")
  negeri_text = str_replace_all(negeri_text, "Hospital Queen Elizabeth", "Sabah")
  negeri_text = str_replace_all(negeri_text, "Hospital Lahad Datu, Sabah", "-, Sabah")
  negeri_text = str_replace_all(negeri_text, "Hospital Lahad Datu", "Sabah")
  negeri_text = str_replace_all(negeri_text, "Hospital Semporna, Sabah", "-, Sabah")
  negeri_text = str_replace_all(negeri_text, "Hospital Semporna", "Sabah")
  negeri_text = str_replace_all(negeri_text, "Hospital Duchess of Kent Sandakan, Sabah", "-, Sabah")
  negeri_text = str_replace_all(negeri_text, "Hospital Duchess of Kent Sandakan", "Sabah")
  negeri_text = str_replace_all(negeri_text, "Hospital Tawau, Sabah", "-, Sabah")
  negeri_text = str_replace_all(negeri_text, "Hospital Tawau", "Sabah")
  negeri_text = str_replace_all(negeri_text, "Hospital Sultanah Bahiyah, Alor Setar, Kedah", "-, Kedah")
  negeri_text = str_replace_all(negeri_text, "Hospital Sultanah Bahiyah, Alor Setar", "Kedah")
  negeri_text = str_replace_all(negeri_text, "Universiti Malaya", "Kuala Lumpur")
  negeri_text = str_replace_all(negeri_text, "Hospital Sungai Buloh, Selangor", "-, Selangor")
  negeri_text = str_replace_all(negeri_text, "Hospital Sungai Buloh", "Selangor")
  negeri_text = str_replace_all(negeri_text, "Hospital Selayang, Selangor", "-, Selangor")
  negeri_text = str_replace_all(negeri_text, "Hospital Selayang", "Selangor")
  negeri_text = str_replace_all(negeri_text, "Kuching, Sarawak", "-")
  negeri_text = str_replace_all(negeri_text, "daripada Perlis", "-")
  negeri_text = str_replace_all(negeri_text, "kluster hospital pakar Muar, Johor", "-")
  negeri_text = str_replace_all(negeri_text, "KKM di Sabah", "-")
}; negeri_text
if (my_date > "2020-10-13") {
  negeri_text = my_table_deaths[,"Negeri"]
}; negeri_text
for (i in 1:new_deaths) {
  negeri_text = str_replace_all(negeri_text, "WP Labuan", "Labuan")
  negeri_text = str_replace_all(negeri_text, "Wilayah Persekutuan Labuan", "Labuan") # doesn't work, another weird space
}; negeri_text
if (my_date == "2020-11-09") {negeri_text[5] = "Labuan"}  # weird space problem
negeri_text

# ---
negeri_cnt = matrix(rep(0, length(negeri)), nrow = new_deaths, ncol = length(negeri))
for (i in 1:new_deaths) {
  negeri_cnt[i,] = as.numeric(str_count(negeri_text[i], negeri) > 0)
  # make sure only 1 count per <li>
}
# to add more replacement list overtime
new_deaths_state = colSums(negeri_cnt); new_deaths_state
# problem when:
# - state name not mentioned
# - multiple deaths per state  # solved for count
# - multiple mention of state name in text -- partial

# get from table earlier
# starting 18/9, states listed by cumulative frequency, messed up all my codes
# my_table = my_table[-17, ]  # if want to write to xls
colnames(my_table) = c("state", "new_cases", "total_cases")
# my_table = cbind(date = rep(my_date, dim(my_table)[1]), my_table[,-1])
# my_table  # do not read state, names always inconsistent
# data_state = my_table[,-1]
# --- ori code before 18/9
# data_state = my_table
# data_state$new_deaths = c(new_deaths_state, sum(new_deaths_state))
# data_state
# ---
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
data_state$new_deaths = c(new_deaths_state, sum(new_deaths_state))
data_state

# add new sheet to pre-existing xls, change to your file name
write.xlsx2(data_state, "covid-19_my_state.xls", sheetName = paste0(format(as.Date(my_date), "%Y%m%d")), append = T, showNA = F, row.names = F)

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
