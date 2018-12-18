%% Variables for Mirror System Analysis

% Check if the folder to save clean data exists, if not, create it
if exist([output_dir 'Filter_Faster\'], 'dir') == 0
    mkdir([output_dir 'Filter_Faster\'])
end

filtered_data = [output_dir 'Filter_Faster\'];

% Check if the folder to save copied data exists, if it doesn't exist, create it
if exist([output_dir 'Copied_Data\'], 'dir') == 0
    mkdir([output_dir 'Copied_Data\'])
end

% Location of folder created above to save the copied dataset
copied_data=[output_dir 'Copied_Data\'];

% Check if the folder to save bad channel files exists, if not, create it
if exist([output_dir 'Bad_Channels\'], 'dir') == 0
    mkdir([output_dir 'Bad_Channels\'])
end

% % Indicate the location of folder created above to save the bad channel files
bad_channels = [output_dir 'Bad_Channels\'];


% Check if the folder to save copied data after ICA exists, if not, create it
if exist([output_dir 'ICA_Copied_Data\'], 'dir') == 0
    mkdir([output_dir 'ICA_Copied_Data\'])
end

% Location of folder created above to save the copied data after ICA
ICA_copied_data = [output_dir 'ICA_Copied_Data\'];

% Check if the folder to save original data with ICA weights exists, if not, create it
if exist([output_dir 'ICA_Original_Data\'], 'dir') == 0
    mkdir([output_dir 'ICA_Original_Data\'])
end

% Location of folder created above to save the ICA dataset
ICA_original_data = [output_dir 'ICA_Original_Data\'];


% Check if the folder to save Adjust data exists, if not, create it
if exist([output_dir 'Adjust_Data\'], 'dir') == 0
    mkdir([output_dir 'Adjust_Data\'])
end

% % Location of folder created above to save the ICA dataset
Adjust_Data = [output_dir 'Adjust_Data\'];

% Check if the folder to component removed data exsits, if not, create it
if exist([output_dir 'Component_Removed\'], 'dir') == 0
    mkdir([output_dir 'Component_Removed\'])
end

% Location of folder to save component removed dataset
Comp_Rem_Data = [output_dir 'Component_Removed\'];

% Check if the folder to save epoched data exsits, if not, create it
if exist([output_dir 'Epoch_Data\'], 'dir') == 0
    mkdir([output_dir 'Epoch_Data\'])
end

% Location of folder to save epoched dataset
Epoched_Data = [output_dir 'Epoch_Data\'];

% Check if the folder to save epoched matched data exsits, if not, create it
if exist([output_dir 'Epoch_Matched\'], 'dir') == 0
    mkdir([output_dir 'Epoch_Matched\'])
end

% Location of folder to save epoched dataset
Epoched_Matched_Data = [output_dir 'Epoch_Matched\'];

% Check if the folder to save CSD transformed data exsits, if not, create it
if exist([output_dir 'Epoch_Matched_CSD\'], 'dir') == 0
    mkdir([output_dir 'Epoch_Matched_CSD\'])
end

% Location of folder to save epoched dataset
CSD_Data = [output_dir 'Epoch_Matched_CSD\'];

% Check if the folder to save non epoch-mathced CSD transformed data exsits, if not, create it
if exist([output_dir 'CSD_avgbase\'], 'dir') == 0
    mkdir([output_dir 'CSD_avgbase\'])
end

% Location of folder to save epoched dataset
CSD_avgbase = [output_dir 'CSD_avgbase\'];

% Check if the folder to save fft data exsits, if not, create it
if exist([output_dir 'FFT_data\'], 'dir') == 0
    mkdir([output_dir 'FFT_data\'])
end

% Location of folder to save epoched dataset
FFT_data = [output_dir 'FFT_data\'];

% Check if the folder to save CSD transformed data exsits, if not, create it
if exist([output_dir 'Time_Frequency_Data\'], 'dir') == 0
    mkdir([output_dir 'Time_Frequency_Data\'])
end

% Location of folder to save epoched dataset
TFR_Data = [output_dir 'Time_Frequency_Data\'];

% Check if the folder to save CSD transformed data exsits, if not, create it
if exist([output_dir 'Flex_Time_Frequency_Data\'], 'dir') == 0
    mkdir([output_dir 'Flex_Time_Frequency_Data\'])
end

% Location of folder to save epoched dataset
Flex_TFR_Data = [output_dir 'Flex_Time_Frequency_Data\'];

% Check if the folder to save CSD transformed data exsits, if not, create it
if exist([output_dir '6_28_Time_Frequency_Data\'], 'dir') == 0
    mkdir([output_dir '6_28_Time_Frequency_Data\'])
end

% Location of folder to save epoched dataset
TFR_Data_628 = [output_dir '6_28_Time_Frequency_Data\'];

% Check if the folder to save TFR clustered data exsits, if not, create it
if exist([TFR_Data 'Clustered\'], 'dir') == 0
    mkdir([TFR_Data 'Clustered\'])
end

% Location of folder to save TFR clustered dataset
TFR_Clustered_Data = [TFR_Data 'Clustered\'];

% Check if the folder to save TFR clustered data exsits, if not, create it
if exist([Flex_TFR_Data 'Clustered\'], 'dir') == 0
    mkdir([Flex_TFR_Data 'Clustered\'])
end

% Location of folder to save TFR clustered dataset
Flex_TFR_Clustered_Data = [Flex_TFR_Data 'Clustered\'];

% Check if the folder to save TFR clustered data exsits, if not, create it
if exist([TFR_Data_628 'Clustered\'], 'dir') == 0
    mkdir([TFR_Data_628 'Clustered\'])
end

% Location of folder to save TFR clustered dataset
TFR_Clustered_Data_628 = [TFR_Data_628 'Clustered\'];

% Check if the folder to save stats data exists, if not, create it
if exist([TFR_Data 'StatsTest\'], 'dir') == 0
    mkdir([TFR_Data 'StatsTest\'])
end

% Location of folder to save stats tests
Stats_data = [TFR_Data 'StatsTest\'];

% Check if the folder to save stats data exists, if not, create it
if exist([Flex_TFR_Data 'StatsTest\'], 'dir') == 0
    mkdir([Flex_TFR_Data 'StatsTest\'])
end

% Location of folder to save stats tests
Stats_flex_data = [Flex_TFR_Data 'StatsTest\'];

% Check if the folder to save stats data exists, if not, create it
if exist([TFR_Data_628 'StatsTest\'], 'dir') == 0
    mkdir([TFR_Data_628 'StatsTest\'])
end

% Location of folder to save stats tests
Stats_flex_data_628 = [TFR_Data_628 'StatsTest\'];

% Check if the folder to save figures exists, if not, create it
if exist([output_dir 'Figures\'], 'dir') == 0
    mkdir([output_dir 'Figures\'])
end

% Location of folder to save figures
Figures = [output_dir 'Figures\'];

% Folder to save text file
 if exist([output_dir 'Export_data\'], 'dir') == 0
    mkdir([output_dir 'Export_data\'])
 end

 % Location of folder to save figures
Export_data = [output_dir 'Export_data\'];


