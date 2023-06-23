import re

# Read the data file
with open('/users/yiyichen/desktop/combined data/sub_1_matched_data.txt', 'r') as file:
    lines = file.readlines()

# Group the trials
grouped_trials = {}
current_trial = None

for line in lines:
    if line.startswith("MSG"):
        if "start_trial fix_on" in line:
            # Extract the trial information after "start_trial fix_on <trial_number>"
            trial_info = re.search(r'start_trial fix_on \d+ (.*)$', line).group(1)
            if trial_info not in grouped_trials:
                grouped_trials[trial_info] = []
            current_trial = [line.strip()]
            grouped_trials[trial_info].append(current_trial)
        else:
            current_trial.append(line.strip())
    else:
        current_trial.append(line.strip())

# Save the grouped trials to a text file
output_file = '/users/yiyichen/desktop/combined data/sub_1_grouped_trials.txt'
with open(output_file, 'w') as file:
    for trial_info, trials in grouped_trials.items():
        file.write(f"Trials with info '{trial_info}':\n")
        for trial in trials:
            file.write('\n'.join(trial))
            file.write('\n\n')

print(f"Grouped trials saved to '{output_file}'.")
