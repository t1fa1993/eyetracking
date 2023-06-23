import re

def get_trial_start_line(trial_end_time, input_lines):
    for line in reversed(input_lines):
        if line.startswith("MSG") and "fix_off tar_on" in line:
            values = line.split()
            trial_start_time = values[1]
            if trial_start_time < trial_end_time:
                return line
    return None

def calculate_average_coordinates(start_time, end_time, input_lines):
    total_x = 0
    total_y = 0
    count = 0
    is_within_range = False

    for line in input_lines:
        if line.startswith(start_time):
            is_within_range = True
            values = line.split()
            x = float(values[1])
            y = float(values[2])
            total_x += x
            total_y += y
            count += 1

        if is_within_range and line.startswith(end_time):
            break

        if is_within_range and not line.startswith(start_time):
            values = line.split()
            x = float(values[1])
            y = float(values[2])
            total_x += x
            total_y += y
            count += 1

    if count > 0:
        average_x = total_x / count
        average_y = total_y / count
        return average_x, average_y
    else:
        return None, None

def process_files(input_file, matching_file, output_file, blink_file):
    with open(matching_file, 'r') as file:
        matching_lines = file.readlines()

    with open(input_file, 'r') as file:
        input_lines = file.readlines()

    with open(blink_file, 'r') as file:
        blink_lines = file.readlines()

    with open(output_file, 'w') as file:
        trial_start_line = None

        for line in matching_lines:
            if line.startswith("MSG"):
                values = line.split()
                if len(values) > 2 and values[2] == "fix_off" and values[3] == "tar_on":
                    trial_end_time = values[1]
                    trial_start_line = get_trial_start_line(trial_end_time, blink_lines)
                    if trial_start_line:
                        file.write(trial_start_line)
                elif len(values) > 2 and values[2] == "start_trial" and values[3] == "fix_on":
                    file.write(line)
                else:
                    file.write(line)
            elif line.startswith("ESACC"):
                # code for calculating average coordinates
                file.write(line)

input_file = "/users/yiyichen/desktop/sub_18_full.asc"
matching_file = "/users/yiyichen/desktop/latency filtered/old/sub_18_filtered_data.txt"
output_file = "/users/yiyichen/desktop/sub_18_matched_data_new.txt"
blink_file = "/users/yiyichen/desktop/no_blinks/sub_18 copy.txt"

process_files(input_file, matching_file, output_file, blink_file)
