# About "covid-19-malaysia"
This repository hosts the code for the Covid-19 Situation in Malaysia dashboard. This is accessible from:
- https://healthdata.usm.my:3939/content/174
- https://wnarifin.github.io/covid-19-malaysia/ (no longer updated as of 3/8/2021) -- utilize only data shared by MoH

It also contains:

- Rmd to generate the dashboard
- datasets in .csv formats
- **scripts/** folder contains useful scripts that I used to scrape the data from the official press release on Covid-19 in Malaysia (described here: [Gist](https://gist.github.com/wnarifin/a608e60b6d35fdb369ee8133b30d36ab)).

**Updates**
- As of 23 July 2021, MOH, MOSTI & CITF started sharing data in github at https://github.com/MoH-Malaysia/covid19-public. So, some of the scripts with web scraping code are no longer useful.
- ~~Data integrated with the data from MOH, new workflow updated in the script. Original script renamed to "scrape_version"~~
- ~~Recovery data and imported cases are still scraped as usual~~
