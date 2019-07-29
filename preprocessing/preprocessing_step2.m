% Preprocessing level 2. This script performs second level of 
% preprocessing. This level of preprocessing includes: removing artifacted
% ICA components, labeling events and marking bad trials, and rounding 
% event latencies.
% Parameters
%       study_info = study information structure (created with
%          init_study_info)
function preprocessing_step2(study_info)

%% Open EEGlab
[ALLEEG, EEG, CURRENTSET] = eeglab; % run EEGLAB

preprocessing_info=readtable(fullfile(study_info.output_dir,...
    'preprocessing_info.csv'));

for s=1:size(study_info.participant_info,1)
    
    % Get subject ID from study info
    subject=study_info.participant_info.participant_id{s};
    
    % Where to put processed (derived) data
    subject_output_data_dir=fullfile(study_info.output_dir, subject,...
        'eeg');
    
    fprintf('\n\n\n*** Processing subject %d (%s) ***\n\n\n', s, subject);
    
    % Load the dataset in which Adjust was done and subsequently visually
    % inspected and artifactual components were identified
    
    fname=sprintf('%s_05_Adjust_checked.set',subject);
    if study_info.automatic_ica_rej
        fname=sprintf('%s_05_Adjust.set',subject);
    end
    EEG=pop_loadset('filename', fname, 'filepath'...
        , subject_output_data_dir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
    
    % Find ICs to be removed
    ICs_To_Remove=find(EEG.reject.gcompreject);
    preprocessing_info.TotalRejICAs(s)=length(ICs_To_Remove);
    
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
    
    % Load original dataset in which ICA weights were transfered from
    % copied dataset
    fname=sprintf('%s_04_ICA_Original.set', subject);
    EEG=pop_loadset('filename', fname, 'filepath',...
        subject_output_data_dir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
        
    % Remove ICs from dataset
    EEG = eeg_checkset(EEG);
    EEG = pop_subcomp(EEG, ICs_To_Remove, 0);
    [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    % Give a name to the dataset and save on hard drive
    EEG = eeg_checkset(EEG);
    base_name=sprintf('%s_06_Component_Removed',subject);
    EEG = pop_editset(EEG, 'setname', base_name);
    EEG = pop_saveset(EEG, 'filename', sprintf('%s.set',base_name),...
        'filepath', subject_output_data_dir);
    [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
end


%% 
for s=1:size(study_info.participant_info,1)
    
    % Get subject ID from study info
    subject=study_info.participant_info.participant_id{s};
    
    % Where to put processed (derived) data
    subject_output_data_dir=fullfile(study_info.output_dir, subject,...
        'eeg');    
    fprintf('\n\n\n*** Processing subject %d (%s) ***\n\n\n', s, subject);
    
    % Load the component removed dataset
    fname=sprintf('%s_06_Component_Removed.set',subject);
    EEG=pop_loadset('filename', fname, 'filepath',...
        subject_output_data_dir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
    
    % Label trial events with trial number
    EEG=label_trial_events(study_info, EEG);
    
    % Mark bad trials based on video coding
    if ~isempty(study_info.mark_bad_trials)
        for j=1:length(study_info.mark_bad_trials)
            eval(sprintf('[EEG, preprocessing_info]=%s(study_info, s, EEG, preprocessing_info);',...
                study_info.mark_bad_trials{j}));
        end
    end
     
    % Give a name to the dataset and save on hard drive
    EEG = eeg_checkset(EEG);
    base_name=sprintf('%s_07_Component_Removed_and_VideobasedExcl',...
        subject);
    EEG = pop_editset(EEG, 'setname', base_name);
    EEG = pop_saveset(EEG, 'filename', sprintf('%s.set',base_name),...
        'filepath', subject_output_data_dir);
    [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
     STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
end

for s=1:size(study_info.participant_info,1)
    
    % Get subject ID from study info
    subject=study_info.participant_info.participant_id{s};
    
    % Where to put processed (derived) data
    subject_output_data_dir=fullfile(study_info.output_dir, subject,...
        'eeg');    
    fprintf('\n\n\n*** Processing subject %d (%s) ***\n\n\n', s, subject);
    
    % Load the component removed dataset in which the movement and
    % not-looking are excluded based on the video
    fname=sprintf('%s_07_Component_Removed_and_VideobasedExcl.set',...
        subject);
    EEG=pop_loadset('filename', fname, 'filepath',...
        subject_output_data_dir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
    
    % round latencies to integers
    for i = 1:length(EEG.event)
        EEG.event(i).latency = round(EEG.event(i).latency);
    end
    
    % Give a name to the dataset and save on hard drive
    EEG = eeg_checkset(EEG);
    base_name=sprintf('%s_08_Component_Removed_and_VideobasedExcl_rounded',...
        subject);
    EEG = pop_editset(EEG, 'setname', base_name);
    EEG = pop_saveset(EEG, 'filename', sprintf('%s.set',base_name),...
        'filepath', subject_output_data_dir);
    [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
end    

writetable(preprocessing_info, fullfile(study_info.output_dir,...
    'preprocessing_info.csv'));