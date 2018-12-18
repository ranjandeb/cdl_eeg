
cd 'E:\PTS_study_VS\Visit2\Scripts\Preprocessing\'

for s=1:length(subject_list)
    %subject=num2str(subject_list(s));
    subject = subject_list{s};
    fprintf('\n\n\n*** Processing subject %d (%s) ***\n\n\n', s, subject);
    
    % Load the component removed dataset in which video-based bad
        % trials are excluded
    EEG=pop_loadset('filename',[subject '_Component_Removed_and_VideobasedExcl_rounded.set'], 'filepath', Comp_Rem_Data);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    for trl_type = 1:length(trial_type) % go through experimental and baseline condition separately
        
        % Load the component removed dataset in which video-based bad
        % trials are excluded
        EEG=pop_loadset('filename',[subject '_Component_Removed_and_VideobasedExcl_rounded.set'], 'filepath', Comp_Rem_Data);
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
        
        %%
        % Keep only the time locking event markers and delete all other event markers
        if  strcmp(trial_type{trl_type},'experimental')
            EEG = eeg_checkset( EEG );
            EEG = pop_selectevent( EEG, 'type', experimental_markers, 'deleteevents','on');
            [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
            
            
            % creat epoch of specific length and time lock to event of interest
            EEG = eeg_checkset( EEG );
            EEG = pop_epoch( EEG, experimental_markers, extended_epoch_length_experimental, 'epochinfo', 'yes');
            [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
            
        elseif strcmp(trial_type{trl_type},'baseline')
            EEG = eeg_checkset( EEG );
            EEG = pop_selectevent( EEG, 'type', baseline_markers, 'deleteevents','on');
            [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
            
            
            % creat epoch of specific length and time lock to event of interest
            EEG = eeg_checkset( EEG );
            EEG = pop_epoch( EEG, baseline_markers, extended_epoch_length_baseline, 'epochinfo', 'yes');
            [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        end
        % Count the trial numbers
        Total_Trials = EEG.trials;
        
        Exclusion_Info.(['a' subject]).(trial_type{trl_type}).Total_Trials = Total_Trials;
        
        Artifact_Rej_Reref_v1()
        
    end
end
save([output_dir 'Exclusion_Info'],'Exclusion_Info');
  