%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This is a EEG data preprocessing script. This script uses EEGLAB, an open
% source EEG data analysis toolbox.

% This script loads in continuous (.set) files from hard drive and performs
% a set of preprocessing steps (removing bad channel, filtering, ICA, 
% Adjust, etc.)

% This script assumes that data is formatted according to BIDS version
% 1.1.1 and data files are in EEGLAB format

% last updated on 7/3/2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% Parameters
%       study_info = study information structure (created with
%          init_study_info)
function preprocess_all(study_info)

%% Preprocessing step 1 that runs the ICA and Adjust etc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DONE: Preprocessing_step1_v2()
preprocessing_step1(study_info)
% IMPORTANT: after running this step --> check automatically-detected IC
% components manually (1-35) and save that step as '_Adjust_checked',
% or set study_info.automatic_ica_rej to true

%% Preprocessing step 2 that excludes artifacts from the data etc.
% Mark bad trials based on video or excel
preprocessing_step2(study_info)

%% Preprocessing step 3 to epoch the data, reject artifact and rereference
preprocessing_step3(study_info)

%% calculate CSD transform
csd_transform(study_info);
