eeglab % run eeglab

%% Initiate Variables
Directories_Variable_Info_v6() % This function contains list of subjects and directory locations

% Check if variable Exclusion_Info exists already. If yes, load it.
if exist([output_dir 'Exclusion_Info.mat']) == 2
    load([output_dir 'Exclusion_Info'],'Exclusion_Info');
end

for s=1:length(subject_list)
    
    subject = subject_list{s};
    
    fprintf('\n\n\n*** Processing subject %d (%s) ***\n\n\n', s, subject);
    
    % Load the component removed dataset
    
    EEG = eeg_checkset( EEG );
    EEG = pop_loadset('filename',[subject '_Referenced_Epoched_' trial_type{2} '.set'],'filepath', Epoched_Data);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    Trials_Before_Match=EEG.trials;
    
    % Load exeperimental EEG structure in a temporary struucture
    EEG_exp=EEG;
    
    EEG = eeg_checkset( EEG );
    EEG = pop_loadset('filename',[subject '_Referenced_Epoched_' trial_type{1} '.set'],'filepath',Epoched_Data);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    % Load baseline EEG structure in a temporary struucture
    EEG_base=EEG;
    
    
    for i=1:length(EEG_exp.event)
        for j=1:length(EEG_base.event)
            for m = 1:length(baseline_exp_markers)
                if strcmp(EEG_exp.event(i).type, baseline_exp_markers{m}{2}) && strcmp(EEG_base.event(j).type, baseline_exp_markers{m}{1}) && EEG_exp.event(i).TrialNum == EEG_base.event(j).TrialNum
                    EEG_exp.event(i).type=base_exp_match_marker{m}{2};
                    EEG_base.event(j).type=base_exp_match_marker{m}{1};
                    
                end
            end
        end
    end
    
    EEG_exp = pop_selectevent( EEG_exp, 'type',all_match_exp_markers ,'deleteevents','on');
    EEG=[];
    EEG=EEG_exp;
    
    % Give a name to the dataset and save
    EEG = eeg_checkset( EEG );
    EEG = pop_editset(EEG, 'setname', [subject '_Epoched_Matched_' trial_type{2}]);
    EEG = pop_saveset( EEG, 'filename',[subject '_Epoched_Matched_'  trial_type{2} '.set'],'filepath', Epoched_Matched_Data);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    % Delete all unrelated markers
    EEG_base = pop_selectevent( EEG_base, 'type',all_match_base_markers,'deleteevents','on');
    
    EEG=[];
    EEG=EEG_base;
    
    Trials_After_Match=EEG.trials;
%    Exclusion_Info.(subject).RemainingTrials = Trials_After_Match;
    
    % Give a name to the dataset and save
    EEG = eeg_checkset( EEG );
    EEG = pop_editset(EEG, 'setname', [subject '_Epoched_Matched_'  trial_type{1}]);
    EEG = pop_saveset( EEG, 'filename',[subject '_Epoched_Matched_'  trial_type{1} '.set'],'filepath', Epoched_Matched_Data);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    Trials_After_Match=EEG.trials;
    sub_num=regexp(subject,'\d*','Match');
    sub_num=cell2mat(sub_num);
    sub_num=str2num(sub_num);
    dlmwrite('Trials_Matched_Epoches.csv', [sub_num Trials_Before_Match Trials_After_Match], '-append');
    
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
end
%save([output_dir 'Exclusion_Info'],'Exclusion_Info');