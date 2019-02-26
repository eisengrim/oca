# filename: scrape_oca.R
# author:   kody crowell
# date:     feb 25 2019

# load libs (**install if not found)
require(XML)
require(RCurl)

# set working directory (**change to desired download location)
setwd("~/workspace/oca/")

# master url
master <- "https://www.provincialadvocate.on.ca"

# list of publication pages
urls <- c("https://www.provincialadvocate.on.ca/publications/external-reports",
         "https://www.provincialadvocate.on.ca/publications/legislative-submissions",
         "https://www.provincialadvocate.on.ca/publications/annual-reports",
         "https://www.provincialadvocate.on.ca/publications/partnership-reports",
         "https://www.provincialadvocate.on.ca/publications/advocacy-reports",
         "https://www.provincialadvocate.on.ca/publications/initiative-reports")

for (url in urls){
  # scrape html and parse for pdf files
  page   <- getURL(url)
  parsed <- htmlParse(page)
  links  <- xpathSApply(parsed, path="//a", xmlGetAttr, "href")
  inds   <- grep("*.pdf", links)
  links  <- unlist(links[inds])

  # regex match file path
  regex_match <- regexpr("[^/]+$", links, perl=TRUE)
  destination <- regmatches(links, regex_match)

  # download all files found, pausing between downloads to prevent overload
  for(i in seq_along(links)){
    download.file(paste0(master, links[i]), destfile=destination[i])
    Sys.sleep(runif(1, 1, 5))
  }
}
