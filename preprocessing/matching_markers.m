% This function matches baseline and experimental epochs that corresponds
% to each other (only used if study_info.baseline_type='epoched_matched')
% Parameters
%       study_info = study information structure (created with
%          init_study_info)
%       preprocessing_info = table of preprocessing information
% Returns
%       preprocessing_info = table of preprocessing information updated
%          with number of trials before and after matching
function preprocessing_info=matching_markers(study_info,...
    preprocessing_info)

%% Open EEGlab
[ALLEEG, EEG, CURRENTSET] = eeglab; % run EEGLAB

for s=1:size(study_info.participant_info,1)
    
    % Get subject ID from study info
    subject=study_info.participant_info.participant_id{s};
    
    % Where to put processed (derived) data
    subject_output_data_dir=fullfile(study_info.output_dir, subject,...
        'eeg');
    
    fprintf('\n\n\n*** Processing subject %d (%s) ***\n\n\n', s, subject);
    
    % Load the experimental dataset    
    EEG = eeg_checkset(EEG);
    fname=sprintf('%s_09_Referenced_Epoched_experimental.set', subject);
    EEG = pop_loadset('filename', fname, 'filepath',...
        subject_output_data_dir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
    
    Trials_Before_Match=EEG.trials;
    
    % Load experimental EEG structure in a temporary struuct
    EEG_exp=EEG;
    
    % Load baseline dataset
    EEG = eeg_checkset(EEG);
    fname=sprintf('%s_09_Referenced_Epoched_baseline.set', subject);
    EEG = pop_loadset('filename', fname, 'filepath',...
        subject_output_data_dir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
    
    % Load baseline EEG structure in a temporary struucture
    EEG_base=EEG;    
    
    % Update event types based on type=study_info.base_exp_match_marker
    for i=1:length(EEG_exp.event)
        for j=1:length(EEG_base.event)
            for m = 1:length(study_info.baseline_exp_markers)
                if strcmp(EEG_exp.event(i).type, study_info.baseline_exp_markers{m}{2}) &&...
                        strcmp(EEG_base.event(j).type, study_info.baseline_exp_markers{m}{1}) &&...
                        EEG_exp.event(i).TrialNum == EEG_base.event(j).TrialNum
                    EEG_exp.event(i).type=study_info.base_exp_match_marker{m}{2};
                    EEG_base.event(j).type=study_info.base_exp_match_marker{m}{1};                    
                end
            end
        end
    end
    
    % Delete all unrelated markers
    EEG_exp = pop_selectevent(EEG_exp, 'type', study_info.all_match_exp_markers,...
        'deleteevents','on');
    EEG=EEG_exp;
    
    % Give a name to the dataset and save
    EEG = eeg_checkset(EEG);
    base_name=sprintf('%s_10_Epoched_Matched_experimental', subject);
    EEG = pop_editset(EEG, 'setname', base_name);
    EEG = pop_saveset(EEG, 'filename', sprintf('%s.set', base_name),...
        'filepath', subject_output_data_dir);
    [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    % Delete all unrelated markerss
    EEG_base = pop_selectevent( EEG_base, 'type',all_match_base_markers,...
        'deleteevents','on');
    EEG=EEG_base;
    
    % Give a name to the dataset and save
    EEG = eeg_checkset(EEG);
    base_name=sprintf('%s_10_Epoched_Matched_baseline', subject);
    EEG = pop_editset(EEG, 'setname', base_name);
    EEG = pop_saveset(EEG, 'filename', sprintf('%s.set', base_name),...
        'filepath', subject_output_data_dir);
    [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    preprocessing_info.TrialsBeforeMatch(s)=Trials_Before_Match;
    preprocessing_info.TrialsAfterMatch(s)=EEG.trials;
    
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
end
