matched_data_file_path = "/users/yiyichen/desktop/intrim/matching with full asc file/sub_3_matched_data.txt"
copy_data_file_path = "/users/yiyichen/desktop/intrim/exclusing blinks/sub_3 copy.txt"
output_file_path = "/users/yiyichen/desktop/sub_3_output.txt"

# Read copy_data_file
with open(copy_data_file_path, 'r') as copy_file:
    copy_data = copy_file.readlines()

# Read matched_data_file
with open(matched_data_file_path, 'r') as matched_file:
    matched_data = matched_file.readlines()

# Find the line indices of "fix_off tar_on" in matched_data_file
fix_off_indices = [i for i, line in enumerate(matched_data) if "MSG" in line and "fix_off tar_on" in line]

# Find the indices of the MSG lines containing "start_trial fix_on" in copy_data_file
start_trial_indices = [i for i, line in enumerate(copy_data) if "MSG" in line and "start_trial fix_on" in line]

# Write the extracted lines and rest of the lines from matched_data_file to the output file
with open(output_file_path, 'w') as output_file:
    for i, start_trial_index in enumerate(start_trial_indices):
        output_file.writelines(copy_data[start_trial_index:start_trial_index+1])

        if i < len(fix_off_indices):
            fix_off_index = fix_off_indices[i]
            output_file.writelines(matched_data[fix_off_index:fix_off_index+1])

            # Find the next AVG line
            next_avg_index = fix_off_index
            while next_avg_index < len(matched_data) - 1 and not matched_data[next_avg_index].startswith("AVG"):
                next_avg_index += 1

            # Write the AVG and ESACC lines
            if next_avg_index < len(matched_data) - 1:
                output_file.writelines(matched_data[next_avg_index:next_avg_index+1])

                # Find the next ESACC line
                next_esacc_index = next_avg_index
                while next_esacc_index < len(matched_data) - 1 and not matched_data[next_esacc_index].startswith("ESACC"):
                    next_esacc_index += 1

                if next_esacc_index < len(matched_data) - 1:
                    output_file.writelines(matched_data[next_esacc_index:next_esacc_index+1])

print("Extraction completed and output file created.")
