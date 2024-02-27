#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 input_file source_directory destination_folder"
    exit 1
fi

input_file="$1"
source_directory="$2"
destination_folder="$3"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: Input file '$input_file' not found."
    exit 1
fi

# Check if the source directory exists
if [ ! -d "$source_directory" ]; then
    echo "Error: Source directory '$source_directory' not found."
    exit 1
fi

# Check if the destination folder exists, create it if not
if [ ! -d "$destination_folder" ]; then
    mkdir -p "$destination_folder"
fi

# Extract run number from the input file
run_number=$(grep "run number" "$input_file" | awk '{print $NF}')

# Loop through each line in the input file
while IFS= read -r line || [[ -n "$line" ]]; do
    # Extract the two numbers from each line
    number1=$(echo "$line" | awk '{print $1}')
    number2=$(echo "$line" | awk '{print $2}')

    # Construct the string based on the format "HG_DiffTriggers_B$1_C$2"
    file_string="HG_DiffTriggers_B${number1}_C${number2}"

    # Move files with the constructed string to the destination folder
    files_to_move=$(find "$source_directory" -maxdepth 1 -type f -name "*$file_string*")
    
    for file in $files_to_move; do
        # Check if the file already exists in the destination folder
        if [ -e "$destination_folder/$(basename "$file")" ]; then
            echo "Warning: File '$file' already exists in '$destination_folder/'. Skipped."
        else
            mv "$file" "$destination_folder/"
            echo "Moved '$file' to '$destination_folder/'"
        fi
    done
done < "$input_file"

echo "File movement completed for run number $run_number."

