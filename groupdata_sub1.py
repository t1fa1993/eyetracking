import re

# Create a dictionary to store the grouped trials
trial_groups = {}

with open("/users/yiyichen/desktop/combined data/sub_1_matched_data.txt", "r") as file:
    current_trial = None
    current_trial_lines = []

    for line in file:
        if line.startswith("MSG"):
            if "start_trial fix_on" in line:
                match = re.search(r'start_trial fix_on \d+ (.*)$', line)
                if match:
                    trial_info = match.group(1)
                    if trial_info not in trial_groups:
                        trial_groups[trial_info] = []
                    current_trial = trial_info
                    current_trial_lines = [line.strip()]
                    trial_groups[current_trial].append(current_trial_lines)
                else:
                    current_trial = None
                    current_trial_lines = []
            elif current_trial is not None:
                current_trial_lines.append(line.strip())
        elif line.startswith("AVG") or line.startswith("ESACC"):
            if current_trial is not None:
                current_trial_lines.append(line.strip())
        elif current_trial is not None and line.startswith("MSG end_trial tar_off"):
            current_trial_lines.append(line.strip())

# Save the trial groups to a text file
with open("/users/yiyichen/desktop/combined data/sub_1_grouped_trials.txt", "w") as output_file:
    for trial, lines in trial_groups.items():
        output_file.write(f"Trial: {trial}\n")
        for line_group in lines:
            for line in line_group:
                output_file.write(line + "\n")
            output_file.write("\n")
