% Perform time frequency calculation
% Directories_Variable_Info();

% open EEGLab
eeglab;

for s=1:length(subject_list)
    
    subject = subject_list{s};
    
    % Load pre-processed dataset
    
    EEG=pop_loadset('filename',[subject '_Referenced_Epoched_CSD_' trial_type{1} '.set'],'filepath', CSD_avgbase);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG_base =EEG;
    
    %%
    trls_left(s,1) = sum(strcmp(baselines{1},{EEG_base.event.type}));
    trls_left(s,2) = sum(strcmp(baselines{2},{EEG_base.event.type}));
    trls_left(s,3) = sum(strcmp(baselines{3},{EEG_base.event.type}));
    
end

for s=1:length(subject_list)
    
    subject = subject_list{s};
    
    % Load pre-processed dataset
    
    EEG=pop_loadset('filename',[subject '_Referenced_Epoched_CSD_' trial_type{2} '.set'],'filepath', CSD_avgbase);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG_exp =EEG;
    
    %%
    trls_left(s,4) = sum(strcmp(conditions{1},{EEG_exp.event.type}));
    trls_left(s,5) = sum(strcmp(conditions{2},{EEG_exp.event.type}));
    trls_left(s,6) = sum(strcmp(conditions{3},{EEG_exp.event.type}));
    
end