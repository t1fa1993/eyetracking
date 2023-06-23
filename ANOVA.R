library(readxl)

# Read the Excel file
data <- read_excel("/users/yiyichen/desktop/Visual_Angle_Combine_all_trials.xlsx")

# Filter the baseline condition trials with target hemifield as left or right
baseline_trials <- subset(data, Baseline == 1 & target_hemifield %in% c("left", "right"))

# Calculate the average Visual_Angle_AVG separately for left and right target hemifields
avg_visual_angle_left <- mean(baseline_trials$Visual_Angle_AVG[baseline_trials$target_hemifield == "left"])
avg_visual_angle_right <- mean(baseline_trials$Visual_Angle_AVG[baseline_trials$target_hemifield == "right"])

# Print the average Visual_Angle_AVG for left and right target hemifields
cat("Average Visual Angle for Left Target Hemifield:", avg_visual_angle_left, "\n")
cat("Average Visual Angle for Right Target Hemifield:", avg_visual_angle_right, "\n")

library(ggplot2)

# Filter the data for baseline = 0 trials
baseline_0_data <- subset(data, Baseline == 0)

# Convert factors to appropriate data types if necessary
baseline_0_data$Distractor.Type <- as.factor(baseline_0_data$Distractor)
baseline_0_data$Intrinsic.Value <- as.factor(baseline_0_data$Intrinsic_Value)

# Subset the data for the conditions of interest
condition1_data_remote <- subset(baseline_0_data, Intrinsic.Value == "high" & Distractor.Type == "remote")
condition1_data_close <- subset(baseline_0_data, Intrinsic.Value == "high" & Distractor.Type == "close")
condition2_data_remote <- subset(baseline_0_data, Intrinsic.Value == "low" & Distractor.Type == "remote")
condition2_data_close <- subset(baseline_0_data, Intrinsic.Value == "low" & Distractor.Type == "close")

# Calculate the mean and confidence intervals for each condition
condition1_remote_mean <- mean(condition1_data_remote$Visual_Angle_Diff)
condition1_remote_ci <- t.test(condition1_data_remote$Visual_Angle_Diff)$conf.int
condition1_close_mean <- mean(condition1_data_close$Visual_Angle_Diff)
condition1_close_ci <- t.test(condition1_data_close$Visual_Angle_Diff)$conf.int
condition2_remote_mean <- mean(condition2_data_remote$Visual_Angle_Diff)
condition2_remote_ci <- t.test(condition2_data_remote$Visual_Angle_Diff)$conf.int
condition2_close_mean <- mean(condition2_data_close$Visual_Angle_Diff)
condition2_close_ci <- t.test(condition2_data_close$Visual_Angle_Diff)$conf.int

# Create a data frame for plotting
plot_data <- data.frame(
  Condition = c("High Intrinsic + Remote", "High Intrinsic + Close", "Low Intrinsic + Remote", "Low Intrinsic + Close"),
  Mean = c(condition1_remote_mean, condition1_close_mean, condition2_remote_mean, condition2_close_mean),
  Lower_CI = c(condition1_remote_ci[1], condition1_close_ci[1], condition2_remote_ci[1], condition2_close_ci[1]),
  Upper_CI = c(condition1_remote_ci[2], condition1_close_ci[2], condition2_remote_ci[2], condition2_close_ci[2])
)

# Create the bar plot with error bars
ggplot(plot_data, aes(x = Condition, y = Mean)) +
  ggtitle("Saccade Trajectory Deviation - Overall") +
  geom_bar(stat = "identity", fill = c("gray70", "gray70", "gray30", "gray30")) +
  geom_errorbar(aes(ymin = Lower_CI, ymax = Upper_CI), width = 0.2, color = "black", linewidth = 0.5) +
  labs(x = "Condition", y = "Visual Angle (polar distance)") +
  theme_bw()

# Filter the data for baseline = 0 trials
baseline_0_data <- subset(data, Baseline == 0)

# Convert factors to appropriate data types if necessary
baseline_0_data$Distractor.Type <- as.factor(baseline_0_data$Distractor)
baseline_0_data$Intrinsic.Value <- as.factor(baseline_0_data$Intrinsic_Value)

# Conduct the within-subject ANOVA
model <- aov(Visual_Angle_Diff ~ Distractor.Type * Intrinsic.Value, data = baseline_0_data)

# Print the summary of the ANOVA
summary(model)

# Subset the data for the conditions of interest
condition1_data <- subset(baseline_0_data, Intrinsic.Value == "high" & Distractor.Type == "remote")
condition2_data <- subset(baseline_0_data, Intrinsic.Value == "high" & Distractor.Type == "close")
condition3_data <- subset(baseline_0_data, Intrinsic.Value == "low" & Distractor.Type == "remote")
condition4_data <- subset(baseline_0_data, Intrinsic.Value == "low" & Distractor.Type == "close")

# Conduct the t-tests
t_test_result1 <- t.test(condition1_data$Visual_Angle_Diff, condition2_data$Visual_Angle_Diff)
t_test_result2 <- t.test(condition1_data$Visual_Angle_Diff, condition3_data$Visual_Angle_Diff)
t_test_result3 <- t.test(condition1_data$Visual_Angle_Diff, condition4_data$Visual_Angle_Diff)

# Print the t-test results
print(t_test_result1)
print(t_test_result2)
print(t_test_result3)

