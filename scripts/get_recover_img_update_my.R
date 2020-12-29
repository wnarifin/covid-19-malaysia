# OCR number of recovered COVID-19 from KPK Website

# Libraries
library(rvest)
library(tesseract)
library(magick)
library(magrittr)
library(stringr)

# do not run if part of data_update_state_html script
# ===
# # Date
# my_date = Sys.Date()
# # my_date = "2020-11-24"  # if you want other date in yyyy-mm-dd format
# my_day = format(as.Date(my_date), "%d")
# my_day_no = as.numeric(my_day)
# my_mo = format(as.Date(my_date), "%m")
# my_mo_no = as.numeric(my_mo)
# # Set URL
# my_mo_list = c("januari", "februari", "mac", "april", "mei", "jun", "julai", "ogos", "september", "oktober", "november", "disember")
# kpk_url = paste0("https://kpkesihatan.com/2020/", my_mo, "/", my_day, "/kenyataan-akhbar-kpk-", my_day_no,
#                  "-", my_mo_list[my_mo_no], "-2020-situasi-semasa-jangkitan-penyakit-coronavirus-2019-covid-19-di-malaysia/")
# 
# # Get the page
# kpk_page = read_html(kpk_url)
# str(kpk_page)  # make sure HTML page is loaded

# # Get image for daily number recovered
# img_node = html_nodes(kpk_page, "img")
# img_loc = grep("discaj", img_node, ignore.case = T)  # get node with discaj
# img_link = html_attr(img_node[img_loc], "data-orig-file")  # get the content of attribute in a tag
# ===

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
data_recover_kelantan = data.frame(date=my_date, state=state, recover=recover_data)
data_recover_kelantan

# Read data for all states, more difficult
# img_data_state = img_data %>% image_scale("794x446") %>% image_resize("2000x")
img_data_state = img_data %>% image_resize("2000x") %>% image_enhance() %>% image_modulate(brightness = 140)
img_data_state
# OCR
recover_img = image_ocr(img_data_state, language = "msa")
recover_data = str_split(recover_img, "[\n]", simplify = T)  # split at \n
recover_data = recover_data[grep("kes", recover_data)]  # extract index with kes
recover_data = str_c(recover_data, collapse = " ")
recover_data_state = as.numeric(str_split(recover_data, "kes", simplify = T)[1:15])
if (my_date == "2020-12-21") {
  recover_data = recover_data %>% str_remove_all("kes") %>% str_remove_all(",") %>% str_remove_all("[|]")
  recover_data_state = na.omit(as.numeric(str_split(recover_data, " ", simplify = T)))
}
# Supposed to be 16, but WP KL & WP PUTRAJAYA combined in the image
state_all = c("Perlis", "Kedah", "Pulau Pinang", "Perak", "Selangor",
              "WP Kuala Lumpur/Putrajaya", "Negeri Sembilan", "Melaka", "Johor", "Pahang",
              "Terengganu", "Kelantan", "Sabah", "Sarawak", "WP Labuan")
state_all = str_to_upper(state_all)
data_recover_state = data.frame(date=rep(my_date,length(recover_data_state)), state=state_all, recover=recover_data_state)
data_recover_state

# Read existing & save to csv
data_kel_temp = read.csv("covid-19_my_recover_kel.csv"); data_kel_temp$date = as.Date(data_kel_temp$date)
data_state_temp = read.csv("covid-19_my_recover.csv"); data_state_temp$date = as.Date(data_state_temp$date)
data_kel_temp = rbind(data_kel_temp, data_recover_kelantan); data_kel_temp
data_state_temp = rbind(data_state_temp, data_recover_state); data_state_temp
write.csv(data_kel_temp, "covid-19_my_recover_kel.csv", row.names = F)
write.csv(data_state_temp, "covid-19_my_recover.csv", row.names = F)
