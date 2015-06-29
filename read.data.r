# Exploring the Drawbridge Data
devicename <- Sys.info()
devicename <- devicename[["nodename"]]
if (devicename == 'YUQINLAPTOP') {
  data.path <- "E:/Workspace/R/ICDM2015"
  output.path <- "C:/Users/Yuqin/Google Drive/Sharing/ICDM2015/Data"
} else if (devicename == 'ALPHA-GJNZ322') {
  data.path <- "C:/Projects/ICDM2015/Raw_Data"
  output.path <- "C:/Users/Yuqin/Google Drive/Sharing/ICDM2015/Data"
}
setwd(data.path)
install.packages("readr")
library(readr)
train <- read_csv(file.path(data.path, "dev_train_basic.csv"))
cat("There are ", nrow(train), " devices in the device train file")
test <- read_csv(file.path(data.path, "dev_test_basic.csv"))
cat("There are ", nrow(test), " devices in the device test file")
device <- rbind(train, test)
cat("There are", length(unique(device$device_type)), "unique device types")
cat("There are", length(unique(device$device_os)), "unique device operating systems")
cat("There are", length(unique(device$country)), "unique countries")
cookie <- read_csv(file.path(data.path, "cookie_all_basic.csv"))

read_bad_csv <- function(file_name, bad_col=3, n_max=-1) {
  f_in <- file(file_name)
  lines <- readLines(f_in, n=n_max)
  close(f_in)
  temp_csv_1 <- tempfile()
  f_out_1 <- file(temp_csv_1, "w")
  writeLines(gsub("\\{|\\}", '"', lines), f_out_1)
  close(f_out_1)
  data <- read_csv(temp_csv_1, col_names=FALSE)
  temp_csv_2 <- tempfile()
  f_out_2 <- file(temp_csv_2, "w")
  for (i in 1:nrow(data)) {
    bad_lines <- strsplit(substr(data[i,bad_col], 2, nchar(data[i,bad_col])-1), "\\),\\(")[[1]]
    if (bad_col==1) {
      lines <- paste(bad_lines,
                     paste0(as.character(data[i,2:ncol(data)]), collapse=","),
                     sep=",")
    } else if (bad_col<ncol(data)) {
      lines <- paste(paste0(as.character(data[i,1:bad_col-1]), collapse=","),
                     bad_lines,
                     paste0(as.character(data[i,bad_col+1:ncol(data)]), collapse=","),
                     sep=",")
    } else {
      lines <- paste(paste0(as.character(data[i,1:ncol(data)-1]), collapse=","),
                     bad_lines,
                     sep=",")
    }
    writeLines(lines, f_out_2)
  }
  close(f_out_2)
  return(read_csv(temp_csv_2))
}

ip <- read_bad_csv(file.path(data.path, "id_all_ip.csv"), bad_col=3, n_max = 10000)
property <- read_bad_csv(file.path(data.path, "id_all_property.csv"), bad_col=3, n_max = 10000)
agg <- read_csv(file.path(data.path, "ipagg_all.csv"), n_max=100)
property_category <- read_bad_csv(file.path(data.path, "property_category.csv"), bad_col=2)
cat("There are", length(unique(property_category$property_id)), "unique properties")
cat("There are", length(unique(property_category$category_id)), "unique categories")
sample_submission <- read_csv(file.path(data.path, "sampleSubmission.csv"))
write_csv(sample_submission, "sample_submission.csv")
