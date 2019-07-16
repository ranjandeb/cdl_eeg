% This function marks bad trials based on video interference markers
% It marks trials as bad (but does not remove them) by changing the event
% type values to end with '_bad' (so they are not found by the following
% epoching steps). Trials are rejected if the time within a trial marked
% as NOAT (not attending to screen) or MVMT (movement) exceeds certain
% thresholds
% Parameters
%       study_info = study information structure (created with
%          init_study_info)
%       s = subject index in list of subjects
%       EEG = subject's eeg data
%       preprocessing_info = table of preprocessing information
% Returns
%       EEG = subject's eeg data with bad trials marked
%       preprocessing_info = table of preprocessing information updated
%          with number of trials removed for subject
function [EEG, preprocessing_info]=mark_bad_trials(study_info, s,...
    EEG, preprocessing_info)

% Mark bad if percentage of time in trial not attending to screen exceeds
% this (0 if must attend for whole trial)
noat_perc_thresh=20;
% Mark bad if percentage of time in trial moving exceeds this (0 no
% movements allowed)
mvmt_perc_thresh=10;

% List of indices of bad trials
bad_trials=[];

% Get epoch duration (in seconds) and sample rate
epoch_dur_s=diff(study_info.epoch_length_experimental);
fs=EEG.srate;

% Epoch the data (across conditions)
EEG_epochs = pop_epoch( EEG, unique(study_info.experimental_event_types),...
    study_info.epoch_length_experimental, 'epochinfo', 'yes');

% Initialize preprocessing info
preprocessing_info.NoAtTrials(s)=0;
preprocessing_info.MvmtTrials(s)=0;

% If epoching cuts through an interference event (because they can have a
% long duration), the interference event does not appear in epochs after
% the epoch it started in. This adds those interefence events back
for trl_idx=1:length(EEG_epochs.epoch)
    epoch=EEG_epochs.epoch(trl_idx);
    
    % Determine the event in this epoch that defines the trial
    ref_evt_idx=find(cell2mat(epoch.eventlatency)==0);
    
    % Figure out the start of the trial relative to the start of the
    % unepoched data (in data points)
    start_epoch_latency_pts=round(EEG.event(find([EEG.event.TrialNum]==epoch.eventTrialNum{ref_evt_idx})).latency-study_info.epoch_length_experimental(1)*1/fs);
    
    % Find NOAT and MVMT events in the original (unepoched)data
    for evt_idx=1:length(EEG.event)        
        if strcmp(EEG.event(evt_idx).type,'NOAT') || strcmp(EEG.event(evt_idx).type,'MVMT')
            % If event starts before epoch start latency and ends after
            if EEG.event(evt_idx).latency<start_epoch_latency_pts && EEG.event(evt_idx).latency+EEG.event(evt_idx).duration>start_epoch_latency_pts
                % Add a new event to this epoch starting from the beginning
                % of the epoch
                new_evt_start_latency_ms=study_info.epoch_length_experimental(1)*1000;
                % The duration will be the duration of the interference
                % event minus the portion that occured before the start of
                % the epoch (but no longer than the epoch duration)
                new_evt_duration_ms=min([epoch_dur_s*fs EEG.event(evt_idx).duration-(start_epoch_latency_pts-EEG.event(evt_idx).latency)])/fs*1000;
                EEG_epochs.epoch(trl_idx).event(end+1)=length(EEG_epochs.epoch(trl_idx).event+1);
                EEG_epochs.epoch(trl_idx).eventtype{end+1}=EEG.event(evt_idx).type;
                EEG_epochs.epoch(trl_idx).eventlatency{end+1}=new_evt_start_latency_ms;
                EEG_epochs.epoch(trl_idx).eventurevent{end+1}=evt_idx;
                EEG_epochs.epoch(trl_idx).eventduration{end+1}=new_evt_duration_ms;
                EEG_epochs.epoch(trl_idx).eventdelay{end+1}=0;
                EEG_epochs.epoch(trl_idx).eventactor{end+1}='n/a';
                EEG_epochs.epoch(trl_idx).eventgender{end+1}='n/a';
                EEG_epochs.epoch(trl_idx).eventemotion{end+1}='n/a';
                EEG_epochs.epoch(trl_idx).eventTrialNum{end+1}=NaN;
            end
        end
    end
end         
               
% Now determine the time in each trial coded as interference
for trl_idx=1:length(EEG_epochs.epoch)
    epoch=EEG_epochs.epoch(trl_idx);
    
    % Initialize time (ms) of NOAT and MVMT time coded in this trial
    noat_time=0;
    mvmt_time=0;
    
    % Add duration of all NOAT events in this trial to time in NOAT
    noat_idx=find(strcmp(epoch.eventtype,'NOAT'));
    for i=1:length(noat_idx)
        noat_time=noat_time+epoch.eventduration{noat_idx(i)};
    end
    
    % Add duration of all MVMT events in this trial to time in MVMT
    mvmt_idx=find(strcmp(epoch.eventtype,'MVMT'));
    for i=1:length(mvmt_idx)
        mvmt_time=mvmt_time+epoch.eventduration{mvmt_idx(i)};
    end
    
    % Bad trial if NOAT time exceeds threshold
    if noat_time/(epoch_dur_s*1000)*100>=noat_perc_thresh
        preprocessing_info.NoAtTrials(s)=preprocessing_info.NoAtTrials(s)+1;
        bad_trials(end+1)=trl_idx;
    % Bad trial if MVMT time exceeds threshold
    elseif mvmt_time/(epoch_dur_s*1000)*100>=mvmt_perc_thresh
        preprocessing_info.MvmtTrials(s)=preprocessing_info.MvmtTrials(s)+1;
        bad_trials(end+1)=trl_idx;
    end
end
    

%%
% Mark bad trials by adding '_bad' to the event type (so epoching will miss
% it)
for k=1:length(bad_trials)    
    for i=1:length(EEG.event)
        if strcmp(EEG.event(i).type, 'Stm+') && (EEG.event(i).TrialNum == bad_trials(k))
            EEG.event(i).type = [EEG.event(i).type '_bad'];
        end
    end
end
