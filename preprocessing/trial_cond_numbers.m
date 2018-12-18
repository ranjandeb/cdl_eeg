% Perform time frequency calculation
% Directories_Variable_Info();

% open EEGLab
eeglab;

for s=1:length(subject_list)
    
    subject = subject_list{s};
    
    % Load pre-processed dataset
    
    EEG=pop_loadset('filename',[subject '_Epoched_Matched_CSD_' trial_type{1} '.set'],'filepath', CSD_Data);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG_base =EEG;
    
    %%
    trls_left(s,1) = sum(strcmp(all_match_base_markers{1},{EEG_base.event.type}));
    trls_left(s,2) = sum(strcmp(all_match_base_markers{2},{EEG_base.event.type}));
    trls_left(s,3) = sum(strcmp(all_match_base_markers{3},{EEG_base.event.type}));
    
%     trls_left(s,1) = sum(strcmp(baselines{1},{EEG_base.event.type}));
%     trls_left(s,2) = sum(strcmp(baselines{2},{EEG_base.event.type}));
%     trls_left(s,3) = sum(strcmp(baselines{3},{EEG_base.event.type}));
    
end