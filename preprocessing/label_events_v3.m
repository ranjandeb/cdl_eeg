% This script puts trial number to all the event markers. It does not
% delete any event from data. It also does not mark an event as good or
% bad. It just gives an additional level to the event marker, which
% can be used to exclude unwanted trials from analysis.


% Find the index of last event marker
lastevent_idx = length(EEG.event);

% Add a new field 'TrialNum' in EEGLAB event list and assign the value 'NaN'
EEG = pop_editeventfield( EEG, 'indices',  strcat('1:', int2str(length(EEG.event))), 'TrialNum','NaN');

%% Baseline trials
% Add trial number for observation pointing condition
if ~isempty(baseline_markers)
    for ii = 1:length(baseline_markers)
        k=1;
        
        for i=1:length(EEG.event)
            if strcmp(EEG.event(i).type, baseline_markers{ii})
                EEG.event(i).TrialNum = k;
                k=k+1;
            end
        end
    end
end
%% Add trial number depending on baseline
trl_num = NaN;
 for i=1:length(EEG.event)
     if ~isnan(EEG.event(i).TrialNum)
         trl_num = EEG.event(i).TrialNum;
     else
         EEG.event(i).TrialNum = trl_num;
     end
     
 end

%%


