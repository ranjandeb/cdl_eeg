% This function computes the number of trials in each condition and adds
% this information to preprocessing_info
% Parameters
%       study_info = study information structure (created with
%          init_study_info)
%       preprocessing_info = table of preprocessing information
% Returns
%       preprocessing_info = table of preprocessing information updated
%          with number of trials per condition added
function preprocessing_info=compute_trials_per_condition(study_info,...
    preprocessing_info)

for s=1:size(study_info.participant_info,1)
    
    % Get subject ID from study info
    subject=study_info.participant_info.participant_id{s};
    
    % Where to put processed (derived) data
    subject_output_data_dir=fullfile(study_info.output_dir, subject,...
        'eeg');
    
    fprintf('\n\n\n*** Processing subject %d (%s) ***\n\n\n', s, subject);
    
    % Determine name of data file to load (depends on if epoch matching
    % step is done)
    fname='';
    if strcmp(study_info.baseline_type,'epoch_matched')
        fname=sprintf('%s_11_Epoched_Matched_CSD_experimental.set',...
            subject);        
    else
        fname=sprintf('%s_11_Referenced_Epoched_CSD_experimental.set',...
            subject);
    end
    EEG = pop_loadset('filename', fname, 'filepath',...
        subject_output_data_dir);

    % Find trials from each condition
    for cond_idx=1:length(study_info.experimental_conditions)
        cond_epochs=[];
        for epoch_idx=1:length(EEG.epoch)
            epoch=EEG.epoch(epoch_idx);
            % Find epoch reference event with latency 0 (otherwise can be
            % fooled by multiple events with the same type due to overlap
            % in trials with large epoch widths
            ref_evt_idx=find(cell2mat(epoch.eventlatency)==0);
            % Get value of field defining experimental conditions for all
            % events in this epoch
            field_vals=epoch.(sprintf('event%s', lower(study_info.experimental_event_condition_fields{cond_idx})));
            % Check if field value for reference event matches condition
            % field value
            if strcmp(field_vals{ref_evt_idx}, study_info.experimental_event_condition_field_values{cond_idx})
                cond_epochs(end+1)=epoch_idx;
            end
        end
        preprocessing_info.(sprintf('%sConditionNumTrials', study_info.experimental_conditions{cond_idx}))(s)=length(cond_epochs);
    end
end
