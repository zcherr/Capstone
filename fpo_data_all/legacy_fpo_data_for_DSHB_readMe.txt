This directory contains fMRI data of 8 participants from a Face Place Object task (collected in 2015). 
In this task, participants view 90 stimuli of either faces, places, or objects and their brain responses are collected.. The directory contains the following files:

1) fpo_tr5_allParticipants_stimuli.csv - Each row in this file is one of the 90 stimuli each participant saw, in the order they saw them. All participants are combined. The columns are as follows:
	block: what block the stimuli was in
	condition: either face, location, or object
	stimulus: the concept stimulus
	alpha_id: I (Ivette) am not 100% sure what this refers to
	filename: the actual stimulus image file
	category: again, either face, place, or object
	subject: which subject the data belongs to

2) fpo_tr5_allParticipants_coordinates.csv - Each row is a TLRC xyz coordinate of a voxel in a particular subject. There are thousands of rows (voxels) per subject. 
	First 3 columns: x,y,z coordinates
 	4th column: the subject the data belongs to

3) files in the generic form jlp##.csv - Each of these files is the brain response from a unique participant. Each row within a given file is the brain response for one of the 90 stimuli, and each column is a voxel response(I believe in the same order as the voxels in the coordinates file). The ## in the file name refers to the subject-- for example, jlp03.mat is the data for subject 3. 

