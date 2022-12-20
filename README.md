# Zong

Automated clustering of zebra finch song syllables from multiple tutors.

Installation
------------
1. Download Zong, unzip and copy files into MATLAB (version R2020a or later) directory.
2. Ensure Zong files are included on MATLAB path.

Usage
-----
1. Type 'zong' into MATLAB command line.
2. Click 'Create', select folder containing Tutors, then folder containing Tutees as prompted.
3. Fill in the row number of the bird/timepoint(s) you wish to compare each individual to in Comparison 1 (& 2 if performing multiple comparisons).
    * For large datasets with multiple timepoints, it may be more time efficient to hit 'Save' and open the refmatrix as a variable in MATLAB directly, where you can copy and paste values to multiple cells at once, then 'Load' the edited refmatrix back into the Zong interface.
4. Progress to the Syllable Cut panel to segment your recordings.
    1. If performing an analysis at the ‘motif’ level of segmentation, run through several birds from the drop-down menu and hit ‘Plot’ with default settings for each. Check that each motif is being detected correctly (has pink underline).
    2. If performing an analysis at the ‘Syllable’ level of segmentation in zebra finch song, navigate to the Parameters panel, hit ‘Save’ and load this variable into MATLAB so that you can record the specific settings that give an accurate segmentation result for each bird/timepoint. Navigate back to Syllable Cut and work through bird by bird using the drop-down menu. Start with the settings that worked for most birds (given below before parentheses).
        1. Threshold level extension: 2ms
        2. Minimum syllable spacing: 15ms (range: 10-30)
        3. Level above threshold: 0.025 (range: 0.15-0.025)
        4. Smoothing size: 60ms (range: 30-120)
        5. Threshold level: 10 (range: 6-15)
    3. Hit ‘plot’ and then use the magnification tool to zoom in and check how well the syllables are being picked out.
    4. If the result is not satisfactory, experiment with values given in the ranges above. Because there are several levers to pull which impact the segmentation results, there is an element of trial and error to begin with. It may be helpful to also have the sound file in question’s spectrogram open in another program eg: Adobe Audition to best visualize the syllables start/end points in some cases.
    5. When finished, save and reimport the Parameters variable back into Zong.
5. Navigate to the Similarity table. If performing a motif level analysis, or all your birds are well segmented using the same parameters, hit ‘Similarity’. If you are using the parameter table to store different per-bird segmentation parameters, check ‘Use Table’ and the hit ‘Similarity’.
    1. You will then be prompted to give a name to the output excel file containing all the statistics.
    2. We import into JMP Pro to perform analyses, but you can use the stats package of your choice.

Disclaimer
----------
This application uses code implementing the [YIN frequency estimator method](https://doi.org/10.1121/1.1458024).