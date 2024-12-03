# Define directories
input_dir="/mnt/c/GitHub/FPO_capstone/Data_Visualization/subj_data/cluster_data"  # Text file location
output_dir="/mnt/c/GitHub/FPO_capstone/Data_Visualization/subj_data/afni_data"   # New output location
resampled_dir="/mnt/c//GitHub/FPO_capstone/Data_Visualization/subj_data/resampledMasks"  # Resampled mask files location

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Loop through each text file in the input directory
for file in "$input_dir"/*.txt; do
    filename=$(basename "$file" .txt)

    # Extract subject ID from the filename (assuming subj03, subj04, etc.)
    subj_id=$(echo "$filename" | grep -o 'subj[0-9]\+')

    # Define the resampled master file for each subject without .BRIK or .HEAD
    master="$resampled_dir/mask${subj_id:4}_RESAMPLED+tlrc"

    output_file="$output_dir/$filename+tlrc"

    # Run the 3dUndump command using the subject-specific master file
    3dUndump -prefix "$output_file" -master "$master" -xyz "$file"

    if [ $? -ne 0 ]; then
        echo "Conversion failed for $file"
    else
        echo "Converted $file to AFNI format: $output_file"
    fi

done

echo "All conversions completed."