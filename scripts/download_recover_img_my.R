# Download image only from 17/10/2020 till today

# Libraries
library(rvest)
library(tesseract)
library(magick)
library(magrittr)
library(stringr)

# Date
first_date = as.Date("2020-10-14")
last_date = Sys.Date()
# last_date = as.Date("2020-10-27")  # if you want other date in yyyy-mm-dd format
my_dates = first_date:last_date; my_dates = as.Date(my_dates, origin = "1970-01-01")
# my_dates = "2020-10-17"

# loop
for (i in 1:length(my_dates)) { # start loop
  i = 5  # for debug purpose only
  my_day = format(as.Date(my_dates[i]), "%d")
  my_day_no = as.numeric(my_day)
  my_mo = format(as.Date(my_dates[i]), "%m")
  my_mo_no = as.numeric(my_mo)
  # Set URL
  my_mo_list = c("januari", "februari", "mac", "april", "mei", "jun", "julai", "ogos", "september", "oktober", "november", "disember")
  kpk_url = paste0("https://kpkesihatan.com/2020/", my_mo, "/", my_day, "/kenyataan-akhbar-kpk-", my_day_no,
                   "-", my_mo_list[my_mo_no], "-2020-situasi-semasa-jangkitan-penyakit-coronavirus-2019-covid-19-di-malaysia/")
  # date: 2020-11-19
  kpk_url1 = "https://kpkesihatan.com/2020/11/19/kenyataan-akhbar-kpk-19-november-2020-situasi-semasa-jangkitan-penyakit-coronavirus-2019-covid-19-di-malaysia/"
  kpk_url

  kpk_page = try(read_html(kpk_url), T)
  if (class(kpk_page) == "try-error") {kpk_page = try(read_html(kpk_url1), T)} else {kpk_page}
  # test loaded
  str(kpk_page)  # make sure html page is loaded, not error

  # save image recover for record purpose
  img_node = html_nodes(kpk_page, "img")
  img_loc = grep("discaj", img_node, ignore.case = T)  # get node with discaj
  img_link = html_attr(img_node[img_loc], "data-orig-file")  # get the content of attribute in a tag
  img_ext = str_split(img_link, "[.]", simplify = T); img_ext = img_ext[length(img_ext)]  # get extension
  dld = try(download.file(img_link[1], destfile = paste0("recover_data_state/", my_dates[i], ".", img_ext)), T)
  if (class(dld) == "try-error") {next}
} # end loop

# problems
# 25/10/2020 is very weird, bcs has image for 26/10/2020?  -- delete 25/10 img
# 14/10/2020 is very weird, bcs has image for 15/10/2020?  -- have to save manual
# 18/10/2020 error if download by command have to save manual