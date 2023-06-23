library(stringr)
library(ggplot2)

# Read the data from a text file
data <- readLines("/users/yiyichen/desktop/no_blinks/sub_1 copy.txt")

# Initialize variables
keep_trial <- FALSE
filtered_data <- character()
current_trial <- character()
latencies <- numeric()
latency_threshold <- 80  # Latency threshold in milliseconds

# Iterate through the lines
for (line in data) {
  if (grepl("start_trial", line)) {
    keep_trial <- TRUE
    current_trial <- character()
    current_trial <- c(current_trial, line)  # Include the "start_trial fix_on" line
  } else if (grepl("ESACC", line) && keep_trial) {
    esacc_line <- line  # Store the ESACC line
    esacc_timestamp <- as.numeric(str_extract(line, "\\d+"))
  } else if (grepl("end_trial tar_off", line)) {
    end_trial_timestamp <- as.numeric(str_extract(line, "\\d+"))
    tar_on_timestamp <- end_trial_timestamp - 1020
    # Calculate the latency in milliseconds
    latency <- esacc_timestamp - tar_on_timestamp
    if (latency > latency_threshold) {
      # Store the latency along with the trial data
      current_trial <- c(current_trial, esacc_line, paste(line, latency))
      filtered_data <- c(filtered_data, current_trial)
      latencies <- c(latencies, latency)
    }
    keep_trial <- FALSE
  }
}

# Save the filtered data with latencies to a file
file_path <- "/users/yiyichen/desktop/sub_1_filtered_data_new.txt"
writeLines(filtered_data, file_path, useBytes = TRUE)

# Generate histogram of latency distribution
ggplot(data = data.frame(Latency = latencies), aes(x = Latency)) +
  geom_histogram(binwidth = 10, fill = "skyblue", color = "black") +
  labs(title = "Latency Distribution - Participant 1", x = "Latency (ms)", y = "Count")
