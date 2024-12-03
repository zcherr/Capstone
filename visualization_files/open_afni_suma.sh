# Navigate to the AFNI data directory
cd /mnt/c/GitHub/FPO_capstone/visualization_files/subj_data/afni_data || exit

# Open AFNI with NIML support
afni -niml &

# Wait for a moment to ensure AFNI opens before starting SUMA
sleep 10.0

# Open SUMA with the correct spec file and volume
suma -spec ~/.afni/data/suma_MNI_N27/MNI_N27_both.spec -sv /mnt/c/Github/FPO_capstone/visualization_files/subj_data/afni_data/MNI152_2009_template.nii.gz &

# Add a message indicating the setup is complete
echo "AFNI and SUMA are now open. Remember to link them by pressing 'T' in SUMA."