library(eyelinker)
library(readxl)
library(ggplot2)

asc_file <- "/users/yiyichen/Desktop/sub_1.asc"
trial_data <- readLines(asc_file)

xlsx_file <- "/users/yiyichen/Desktop/visual_angle.xlsx"
visual_data <- read_excel(xlsx_file)

# Convert Y_coordinate column to numeric in visual_data
visual_data$Y_coordinate <- as.numeric(visual_data$Y_coordinate)
visual_data$X_coordinate <- as.numeric(visual_data$X_coordinate)
visual_data$T_Y_coordinate <- as.numeric(visual_data$T_Y_coordinate)
visual_data$T_X_coordinate <- as.numeric(visual_data$T_X_coordinate)

# Adjust the y-coordinates to negative values
visual_data$Y_coordinate <- -visual_data$Y_coordinate
visual_data$T_Y_coordinate <- -visual_data$T_Y_coordinate

# Initialize empty data frame to store matching trials
matching_trials <- data.frame(
  saccade_start_x = numeric(),
  saccade_start_y = numeric(),
  saccade_end_x = numeric(),
  saccade_end_y = numeric(),
  x = numeric(),
  y = numeric(),
  t_x = numeric(),
  t_y = numeric(),
  distractor_location = character(),
  distractor_distance = character(),
  distractor_item = character(),
  target_item = character(),
  target_location = character(),
  latency = numeric(),
  stringsAsFactors = FALSE
)

# Iterate over the ASC file
for (i in 1:length(trial_data)) {
  line <- trial_data[i]
  
  # Find the MSG line with the desired format ("end_trial tar_off")
  if (grepl("MSG", line) && grepl("end_trial tar_off", line)) {
    msg_fields <- strsplit(line, "\\s+")[[1]]
    target_on_time <- as.numeric(msg_fields[2]) - 1020
    
    # Find the ESACC line that occurs after target_on_time
    esacc_line <- NULL
    latency <- NA
    for (j in (i + 1):length(trial_data)) {
      line <- trial_data[j]
      
      if (grepl("ESACC", line)) {
        esacc_fields <- strsplit(line, "\\s+")[[1]]
        esacc_end_time <- as.numeric(esacc_fields[4])
        
        # Check if the ESACC line occurs right after target_on_time
        if (esacc_end_time > target_on_time) {
          esacc_line <- line
          latency <- esacc_end_time - target_on_time
          break
        }
      }
    }
    
    
    # Skip if no ESACC line is found
    if (is.null(esacc_line)) {
      next
    }
    
    # Find the MSG line with the desired format ("start_trial fix_on")
    for (k in (i - 1):1) {
      start_msg_line <- trial_data[k]
      
      if (grepl("MSG", start_msg_line) && grepl("start_trial fix_on", start_msg_line)) {
        match_fields <- strsplit(start_msg_line, "\\s+")[[1]]
        
        # Extract relevant information from the MSG line
        distractor_location <- match_fields[9]
        distractor_distance <- match_fields[6]
        distractor_item <- match_fields[10]
        target_item <- match_fields[11]
        target_location <- match_fields[7]
        
        # Find the matching row in visual_data
        match_row <- visual_data[visual_data$distractor_item == distractor_item &
                                   visual_data$target_item == target_item & 
                                   visual_data$disctractor_location == distractor_location &
                                   visual_data$distractor_distance == distractor_distance &
                                   visual_data$target_location == target_location, ]
        
        if (nrow(match_row) > 0) {
          saccade_start_x <- as.numeric(esacc_fields[6])
          saccade_start_y <- as.numeric(esacc_fields[7])
          saccade_end_x <- as.numeric(esacc_fields[8])
          saccade_end_y <- as.numeric(esacc_fields[9])
          x <- match_row$X_coordinate + 1280
          y <- match_row$Y_coordinate + 720
          t_x <- match_row$T_X_coordinate + 1280
          t_y <- match_row$T_Y_coordinate + 720
          
          # Append the matching trial data to the data frame
          matching_trials <- rbind(matching_trials, data.frame(
            saccade_start_x = saccade_start_x,
            saccade_start_y = saccade_start_y,
            saccade_end_x = saccade_end_x,
            saccade_end_y = saccade_end_y,
            x = as.numeric(x),
            y = as.numeric(y),
            t_x = as.numeric(t_x),
            t_y = as.numeric(t_y),
            distractor_location = distractor_location,
            distractor_distance = distractor_distance,
            distractor_item = distractor_item,
            target_item = target_item,
            target_location = target_location,
            latency = latency,
            stringsAsFactors = FALSE
          ))
        }
        break
      }
    }
  }
}


# Print the resulting matching trials data frame
print(matching_trials)

# Plot the first matching trial with legend
geom_path(aes(group = 1))
ggplot(matching_trials[1,], aes(x = x, y = y)) +
  geom_point(shape = "diamond", color = "purple", size = 3) +
  geom_point(aes(x = t_x, y = t_y), shape = "square", color = "black", size = 3) +
  geom_point(aes(x = 1280, y = 720), shape = "+", color = "black", size = 3) +
  geom_point(aes(x = saccade_start_x, y = saccade_start_y), shape = "*", color = "black", size = 3) +
  geom_point(aes(x = saccade_end_x, y = saccade_end_y), shape = "circle", color = "black", size = 3) +
  geom_segment(aes(x = saccade_start_x, y = saccade_start_y, xend = saccade_end_x, yend = saccade_end_y), color = "red") +
  geom_segment(aes(x = saccade_start_x, y = saccade_start_y, xend = t_x, yend = t_y), color = "purple") +
  geom_path(aes(group = interaction(saccade_start_x, saccade_start_y), color = "blue"), alpha = 0.8) +
  labs(x = "X-coordinate", y = "Y-coordinate") +
  annotate("text", x = x, y = y, label = "Distractor", vjust = -1) +
  annotate("text", x = t_x, y = t_y, label = "Target", vjust = -1) +
  annotate("text", x = 1280, y = 720, label = "Fixation Cross", vjust = -1) +
  annotate("text", x = saccade_start_x, y = saccade_start_y, label = "Start of Saccade", vjust = -1) +
  annotate("text", x = saccade_end_x, y = saccade_end_y, label = "End of Saccade", vjust = -1) +
  annotate("text", x = (saccade_start_x + saccade_end_x) / 2, y = (saccade_start_y + saccade_end_y) / 2, label = "Saccade Trajectory", color = "blue", vjust = -1) +
  annotate("text", x = (saccade_start_x + t_x) / 2, y = (saccade_start_y + t_y) / 2, label = "Straight Line to Target", color = "purple", vjust = -1) +
  annotate("text", x = (saccade_start_x + saccade_end_x) / 2, y = (saccade_start_y + saccade_end_y) / 2, label = "Straight Line from Start to End", color = "red", vjust = -2) +
  theme_minimal() +
  theme(legend.position = "bottom")


