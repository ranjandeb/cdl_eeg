%% Main Script walking through the steps for EEG analysis
% last updated 20 June 2018
% last changes: Ranjan adjusted scripts such that ICs are rejected visually
% on the copied dataset and only then weights are copied to the original
% dataset

clear % clear matlab workspace

% Make the folder that contains all the scripts current directory
cd 'E:\PTS_study_VS\Visit1\Scripts\Preprocessing\'

%% Initialize all variables that are specific to this site and project
Individualized_Info_v15_P1_PtS();

%%
cd 'E:\PTS_study_VS\Visit1\Scripts\Preprocessing\'
Directories_Variable_Info_v6();

%% Preprocessing step 1 that runs the ICA and Adjust etc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DONE: Preprocessing_step1_v2()
%this script calls "Preprocessing_step1()"
 Preprocessing_step1_v5_P1_PtS()
% IMPORTANT: after running this step --> check automatically-detected IC
% components manually (1-35) and save that step as '_Adjust_checked'

%% Preprocessing step 2 that excludes artifacts from the data etc.
% Mark bad trials based on video or excel
Preprocessing_step2_v6_P1_PtS()

%% Preprocessing step 3 to epoch the data, reject artifact and rereference
Preprocessing_step3_epoching_v1_P1_PtS()

%% Matching baseline and experimental markers
Matching_Markers_v1()
%no longer needed with flexible time frequency analysis

%% Extract Trial Information
Trial_Information_v2_P1_PtS();
%gives similar info to trial_cond_numbers

%% calculate CSD transform
CSD_transform_v1()
CSD_transform_avgbase_v1()

%% Before running TFR, check how many trials are left when splitting up conditions
trial_cond_numbers()
trial_cond_numbers_avgbase()
% Then adjust the participant list to exclude those participants with not
% enough trials

%% Calculate FFT (does not need to be done before TF)
compute_fft_power()

%% extract frequency information
Time_Frequency_Analysis_v4_local()
Time_Frequency_Analysis_v4()
Time_Frequency_Analysis_Flexible_v4()

%% Topoplots
% make topoplot
Topo_Plot_Time_Range_v3()
% 
%% TFR Plots and Tests
%% prepare channel clusters to produce TFR plots
%channel_cluster_timefreqs()
Channel_Cluster_v3()
Channel_Cluster_Flex_v3()
Channel_Cluster_crosshem()
% 
%% TFR Plot
Time_Frequency_Plot_1_v2()
Time_Frequency_Plot_Flexible_v2()
% 
% %% compute significance test for the chosen cluster
Compute_Time_Freqs_Signif_v3()
Compute_Time_Freqs_Signif_Flex_v1()
Compute_Time_Freqs_Signif_btw_condition_v1()
Compute_Time_Freqs_Signif_crosshem()
% 
% %% make TFR plot with significance mask
Signif_Time_Frequency_Plot_v3()
Signif_Time_Frequency_Plot_Flexible_v3()
Signif_Time_Frequency_Plot_crosshem()
% 
%
%% Export data file(s)
%
Write_Data_In_Text_File_v2()
Write_Data_In_Text_File_Flexible_v2()
Write_Data_In_Text_File_v2_crosshem()

%NOTE: IF CHANGING SUBJECT LIST FOR SUBGROUPS - MUST RERUN FROM CHANNEL
%CLUSTERS TO GET CORRECT DATA OUTPUT


