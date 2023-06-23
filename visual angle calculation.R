library(readr)
library(dplyr)

# Read the input file
data <- read_lines("/users/yiyichen/desktop/combined data/sub_3_grouped_trials.txt")

# Database to store trial information
trial_data <- data.frame(
  Trial_Info = character(),
  Distractor_Location = character(),
  Target_Location = character(),
  AVG_Midpoint_X = numeric(),
  AVG_Midpoint_Y = numeric(),
  Saccade_Start_X = numeric(),
  Saccade_Start_Y = numeric(),
  Saccade_End_X = numeric(),
  Saccade_End_Y = numeric(),
  stringsAsFactors = FALSE
)

# Function to calculate visual angle along the x-axis
calculate_visual_angle_xaxis <- function(start_x, start_y, end_x, end_y) {
  # Calculate the visual angle along the x-axis
  angle_rad1 <- atan2(start_y, start_x)
  angle_rad2 <- atan2(end_y, end_x)
  angle_deg1 <- angle_rad1 * 180 / pi
  angle_deg2 <- angle_rad2 * 180 / pi
  
  visual_angle <- abs(angle_deg2 - angle_deg1)
  return(visual_angle)
}

# Iterate through the lines
for (i in seq_along(data)) {
  line <- trimws(data[i])
  
  if (startsWith(line, "MSG") && grepl("start_trial fix_on", line)) {
    trial_info <- strsplit(line, " ")[[1]]
    trial_data[nrow(trial_data) + 1, "Trial_Info"] <- paste(trial_info[2], trial_info[3], trial_info[5], trial_info[6], trial_info[7], trial_info[8], trial_info[9], sep = " ")
    trial_data[nrow(trial_data), "Distractor_Location"] <- paste(as.numeric(trial_info[10]) + 1280, -(as.numeric(trial_info[11])) - 720, sep = ", ")
    trial_data[nrow(trial_data), "Target_Location"] <- paste(as.numeric(trial_info[12]) + 1280, -(as.numeric(trial_info[13])) - 720, sep = ", ")
  }
  
  # Extract AVG information
  if (startsWith(line, "AVG") && !grepl("tar_on", line)) {
    avg_info <- strsplit(line, "\t")[[1]]
    trial_data[nrow(trial_data), "AVG_Midpoint_X"] <- as.numeric(avg_info[4])
    trial_data[nrow(trial_data), "AVG_Midpoint_Y"] <- -(as.numeric(avg_info[5]))
  }
  
  # Extract ESACC information
  if (startsWith(line, "ESACC")) {
    esacc_info <- strsplit(line, "\t ")[[1]]
    trial_data[nrow(trial_data), "Saccade_Start_X"] <- as.numeric(esacc_info[2])
    trial_data[nrow(trial_data), "Saccade_Start_Y"] <- -(as.numeric(esacc_info[3]))
    trial_data[nrow(trial_data), "Saccade_End_X"] <- as.numeric(esacc_info[4])
    trial_data[nrow(trial_data), "Saccade_End_Y"] <- -(as.numeric(esacc_info[5]))
  }
}

# Calculate visual angle for each trial
trial_data <- trial_data %>%
  mutate(
    Visual_Angle_AVG = calculate_visual_angle_xaxis(Saccade_Start_X, Saccade_Start_Y, AVG_Midpoint_X, AVG_Midpoint_Y),
    Visual_Angle_End = calculate_visual_angle_xaxis(Saccade_Start_X, Saccade_Start_Y, Saccade_End_X, Saccade_End_Y)
  )

# Extract x-coordinate from Target_Location column
trial_data$target_location_x <- as.numeric(sub("^(.*),.*$", "\\1", trial_data$Target_Location))

# Filter out trials where the saccade moves in the opposite direction of the target
trial_data <- trial_data %>%
  filter(
    !(
      (Saccade_End_X < 1280 & Saccade_End_X < target_location_x) |
        (Saccade_End_X > 1280 & Saccade_End_X > target_location_x)
    )
  )


# Remove rows with NA data for saccade start and end X, Y
trial_data <- trial_data %>%
  filter(complete.cases(Saccade_Start_X, Saccade_Start_Y, Saccade_End_X, Saccade_End_Y))

# Print the trial data
print(trial_data)



library(openxlsx)

# Specify the file path and name for the Excel file
excel_file <- "/users/yiyichen/desktop/sub_3_visual angel calculation_new.xlsx"

# Save the trial_data dataframe as an Excel file
write.xlsx(trial_data, excel_file, rowNames = FALSE)



library(ggplot2)

# Reverse the y-axis scale
scale_y_reverse()

# Subset the first 20 trials
subset_data <- head(trial_data, 40)

# Generate individual plots for each trial
for (i in 1:nrow(subset_data)) {
  trial_info <- subset_data$Trial_Info[i]
  distractor_location <- strsplit(subset_data$Distractor_Location[i], ", ")[[1]]
  target_location <- strsplit(subset_data$Target_Location[i], ", ")[[1]]
  saccade_start <- c(as.numeric(subset_data$Saccade_Start_X[i]), as.numeric(subset_data$Saccade_Start_Y[i]))
  saccade_end <- c(as.numeric(subset_data$Saccade_End_X[i]), as.numeric(subset_data$Saccade_End_Y[i]))
  avg_midpoint <- c(as.numeric(subset_data$AVG_Midpoint_X[i]), as.numeric(subset_data$AVG_Midpoint_Y[i]))
  
  # Check if target and distractor locations are valid
  if (length(target_location) != 2 || length(distractor_location) != 2) {
    # Skip plotting if the locations are not valid
    next
  }
  
  # Extract x-coordinates
  fixation_x <- 1280
  target_x <- as.numeric(target_location[1])
  saccade_end_x <- saccade_end[1]
  
  # Check if saccade moves in the opposite direction
  if ((saccade_end_x < fixation_x && saccade_end_x < target_x) ||
      (saccade_end_x > fixation_x && saccade_end_x > target_x)) {
    # Skip plotting if saccade moves in the opposite direction
    next
  }
  
  # Create a new plot for each trial
  p <- ggplot() +
    # Fixation point at (0, 0)
    geom_point(aes(x = 1280, y = -720), color = "black", size = 5) +
    # Target location point
    geom_point(aes(x = target_x, y = as.numeric(target_location[2])), color = "blue", size = 5) +
    # Distractor location point
    geom_point(aes(x = as.numeric(distractor_location[1]), y = as.numeric(distractor_location[2])), color = "red", size = 5) +
    # Saccade start and end points
    geom_point(aes(x = saccade_start[1], y = saccade_start[2]), color = "green", size = 3) +
    geom_point(aes(x = saccade_end[1], y = saccade_end[2]), color = "green", size = 3) +
    # Average midpoint point
    geom_point(aes(x = avg_midpoint[1], y = avg_midpoint[2]), color = "orange", size = 3) +
    # Segments for saccade movement
    geom_segment(aes(x = saccade_start[1], xend = avg_midpoint[1], y = saccade_start[2], yend = avg_midpoint[2]),
                 color = "orange", linetype = "dashed") +
    geom_segment(aes(x = saccade_start[1], xend = saccade_end[1], y = saccade_start[2], yend = saccade_end[2]),
                 color = "green", linetype = "dashed") +
    # Labels for points
    geom_text(aes(label = "Fixation", x = 1280, y = -720), hjust = -0.1, vjust = 1.5) +
    geom_text(aes(label = "Target", x = target_x, y = as.numeric(target_location[2])), hjust = -0.1, vjust = 1.5) +
    geom_text(aes(label = "Distractor", x = as.numeric(distractor_location[1]), y = as.numeric(distractor_location[2])), hjust = -0.1, vjust = 1.5) +
    geom_text(aes(label = "Start", x = saccade_start[1], y = saccade_start[2]), hjust = -0.1, vjust = 1.5) +
    geom_text(aes(label = "End", x = saccade_end[1], y = saccade_end[2]), hjust = -0.1, vjust = 1.5) +
    geom_text(aes(label = "Midpoint", x = avg_midpoint[1], y = avg_midpoint[2]), hjust = -0.1, vjust = 1.5) +
    # Axes labels
    xlab("X") +
    ylab("Y") +
    # Set plot limits and aspect ratio
    xlim(0, 2560) +
    ylim(-1440, 0) +
    coord_equal()
  
  # Display the plot
  print(p)
  
  # Save the plot as an image file
  ggsave(filename = paste0("trial_", i, ".png"), plot = p, width = 8, height = 4, units = "in", dpi = 300)
}
