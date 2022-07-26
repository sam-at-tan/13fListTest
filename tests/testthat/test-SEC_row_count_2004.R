test_that("Parsed row count equal to total row count per PDF list for 2004 Q1", {
  url_SEC <- "https://www.sec.gov/divisions/investment/13flists.htm"

  current_list_url <- rvest::html_attr(rvest::html_elements(
    rvest::read_html(url_SEC),'#block-secgov-content :nth-child(1)'
  )[[24]], "href")

  current_year <- stringr::str_sub(current_list_url,stringr::str_length(current_list_url)-9,stringr::str_length(current_list_url)-6) %>%
    as.integer()

  current_quarter <- stringr::str_sub(current_list_url,stringr::str_length(current_list_url)-4,stringr::str_length(current_list_url)-4) %>%
    as.integer()

  #if (missing(YEAR_)&current_year==0|missing(QUARTER_)&current_quarter==0) stop("Error: Unable to determine current year or quarter. Please supply YEAR and QUARTER in function call and report this error")


  YEAR_ <- 2004
  #  warning("Default year: ", YEAR_)

  QUARTER_ <- 1
  #  warning("Default quarter: ", QUARTER_)

  #0,0 supplied in function call
  if (YEAR_==0|QUARTER_==0) stop("Error: Please supply integer values for YEAR_ and QUARTER_ starting in 2004 Q1. Example: SEC_13F_list(2004, 1)")

  #Validating inputs to the function
  YEAR_ <- as.integer(YEAR_)
  QUARTER_ <- as.integer(QUARTER_)

  if (is.na(YEAR_)|is.na(QUARTER_)) stop("Error: Please supply integer values for YEAR_ and QUARTER_ starting in 2004 Q1. Example: SEC_13F_list(2004, 1)")

  if (YEAR_<2004) stop("Error: SEC_13F_list function only works with SEC list files starting at Q1 2004. Example: SEC_13F_list(2004, 1)")
  if (QUARTER_>4) stop("Error: Please, supply integer number for QUARTER_ in range between 1 and 4")

  if(current_year!=0) (if (YEAR_>current_year) stop (paste0("Error: no list available for year ",
                                                            YEAR_, ". Please, use integer number in range 2004..", current_year))
  )

  if(current_quarter!=0) (if (YEAR_==current_year&QUARTER_>current_quarter) stop (paste0("Error: no list available for year ",
                                                                                         YEAR_, " and quarter ", QUARTER_, ". Last available quarter for current year - ", current_quarter, "."))
  )

  if (YEAR_ == 2004 & QUARTER_ == 1)
  {
    file_name <- "13f-list.pdf"
    url_file <-
      paste0("https://www.sec.gov/divisions/investment/", file_name)
  }
  else
  {
    if (YEAR_ >= 2021 & QUARTER_ >= 2) {
      file_name <- paste0('13flist', YEAR_, 'q', QUARTER_, '.pdf')
      url_file <-
        paste0("https://www.sec.gov/files/investment/",
               file_name)
    } else {
      file_name <- paste0('13flist', YEAR_, 'q', QUARTER_, '.pdf')
      url_file <-
        paste0("https://www.sec.gov/divisions/investment/13f/",
               file_name)
    }
  }

  text <- pdftools::pdf_text(url_file)
  page_total_count <- min(which(!is.na(stringr::str_locate(text,"Total Count:")[,1])))
  total_count <- as.integer(gsub("[^0-9.-]", "", stringr::str_sub(text[page_total_count],stringr::str_locate(text[page_total_count],"Total Count: ")[2]+1)))

  total_count_parse <- dplyr::count(SEC13Flist::SEC_13F_list(2004,1))$n

  expect_equal(total_count, total_count_parse)
})
