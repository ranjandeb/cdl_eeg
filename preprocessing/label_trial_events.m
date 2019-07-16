% This script puts trial number to all the event markers. It does not
% delete any event from data. It also does not mark an event as good or
% bad. It just gives an additional level to the event marker, which
% can be used to exclude unwanted trials from analysis.
% Parameters
%       study_info = study information structure (created with
%          init_study_info)
%       EEG = subject's eeg data
% Returns
%       EEG = subject's eeg data with trial numbers added
function EEG=label_trial_events(study_info, EEG)

% Add a new field 'TrialNum' in EEGLAB event list and assign the value
% 'NaN'
EEG = pop_editeventfield(EEG, 'indices',...
    strcat('1:', int2str(length(EEG.event))), 'TrialNum','NaN');

%% Baseline trials
if ~isempty(find(strcmp(study_info.trial_type,'baseline'), 1))
    k=1;
    for i=1:length(EEG.event)
        if find(strcmp(study_info.baseline_event_types, EEG.event(i).type))
            EEG.event(i).TrialNum = k;
            k=k+1;
        end
    end
end

%% Experimental trials
if strcmp(study_info.baseline_type,'epoch_matched')
    %% Add trial number depending on baseline
    trl_num = NaN;
    for i=1:length(EEG.event)
        if ~isnan(EEG.event(i).TrialNum)
            trl_num = EEG.event(i).TrialNum;
        else
            EEG.event(i).TrialNum = trl_num;
        end
        
    end
else
    k=1;
    for i=1:length(EEG.event)
        if find(strcmp(study_info.experimental_event_types,EEG.event(i).type))
            EEG.event(i).TrialNum = k;
            k=k+1;
        end
    end
end

%%


