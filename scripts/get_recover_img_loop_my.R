# OCR number of recovered COVID-19 from KPK Website

# To get data from previous dates

# Libraries
library(rvest)
library(tesseract)
library(magick)
library(magrittr)
library(stringr)

# Date
first_date = as.Date("2020-10-14")
last_date = Sys.Date()
# last_date = as.Date("2020-10-16")  # if you want other date in yyyy-mm-dd format
my_dates = first_date:last_date; my_dates = as.Date(my_dates, origin = "1970-01-01")
# my_dates = "2020-10-17"

# set empty data
data_kel_temp = NULL
data_state_temp = NULL

# loop
for (i in 1:length(my_dates)) { # start loop
  i = i  # for debug purpose only
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
  if (my_dates[i] == "2020-10-14") {
    img_link = "https://kpkesihatan.files.wordpress.com/2020/10/whatsapp-image-2020-10-15-at-5.04.04-pm.jpeg"
  }
  
  # Read image, for all states
  img_data = image_read(img_link)
  
  # Read for one state, e.g. Kelantan
  # size 80x22 at pixel left upper 200,348
  # change for other states
  state = "KELANTAN"
  img_data_kelantan = img_data %>% image_scale("794x446") %>% image_crop("80x22+200+348") %>% image_resize("2000x")
  img_data_kelantan
  # OCR
  recover_data = image_ocr(img_data_kelantan, language = "msa") %>% str_extract_all("[:digit:]", simplify = T) %>%
    str_c(collapse = "") %>% as.numeric()
  data_recover_kelantan = data.frame(date=my_dates[i], state=state, recover=recover_data)
  data_recover_kelantan
  data_kel_temp  = rbind(data_kel_temp, data_recover_kelantan)
  
  
  # Read data for all states, more difficult
  img_data_state = img_data
  # if (image_info(img_data_state)$width < 794) {image_data_state = image_scale("794x446")} # will stop here if in loop
  img_data_state = image_resize(img_data_state, "2000x")
  img_data_state
  # OCR
  recover_img = image_ocr(img_data_state, language = "msa")
  recover_data = str_split(recover_img, "[\n]", simplify = T)  # split at \n
  recover_data = recover_data[grep("kes", recover_data)]  # extract index with kes
  recover_data = str_c(recover_data, collapse = " ")
  recover_data_state = as.numeric(str_split(recover_data, "kes", simplify = T)[1:15])
  # Supposed to be 16, but WP KL & WP PUTRAJAYA combined in the image
  state_all = c("Perlis", "Kedah", "Pulau Pinang", "Perak", "Selangor",
                "WP Kuala Lumpur/Putrajaya", "Negeri Sembilan", "Melaka", "Johor", "Pahang",
                "Terengganu", "Kelantan", "Sabah", "Sarawak", "WP Labuan")
  state_all = str_to_upper(state_all)
  data_recover_state = data.frame(date=rep(my_dates[i],length(recover_data_state)), state=state_all, recover=recover_data_state)
  data_recover_state
  data_state_temp  = rbind(data_state_temp, data_recover_state)
} # end loop
data_kel_temp
data_state_temp

# Save to csv
write.csv(data_kel_temp, "covid-19_my_recover_kel.csv", row.names = F)
write.csv(data_state_temp, "covid-19_my_recover.csv", row.names = F)
