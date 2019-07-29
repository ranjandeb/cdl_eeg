% Preprocessing level 3. This script performs the third level of
% preprocessing after ICA. This level of preprocessing includes: epoching,
% DC offset correction, epoch rejection, and re-referencing.
% Parameters
%       study_info = study information structure (created with
%          init_study_info)
function preprocessing_step3(study_info)

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
    
    % Load final channel locations
    load(fullfile(subject_output_data_dir, 'final_channel_locations.mat'));
    
    % go through experimental and baseline condition separately
    for trl_type = 1:length(study_info.trial_type) 
        
        % Load the component removed dataset in which video-based bad
        % trials are excluded
        fname=sprintf('%s_08_Component_Removed_and_VideobasedExcl_rounded.set',...
            subject);
        EEG=pop_loadset('filename', fname, 'filepath',...
            subject_output_data_dir);
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0);
        
        if  strcmp(study_info.trial_type{trl_type},'experimental')
            % creat epoch of specific length and time lock to event of
            % interest
            EEG = eeg_checkset(EEG);
            EEG = pop_epoch(EEG,...
                unique(study_info.experimental_event_types),...
                study_info.extended_epoch_length_experimental,...
                'epochinfo', 'yes');
            [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
            
        elseif strcmp(study_info.trial_type{trl_type},'baseline')
            % creat epoch of specific length and time lock to event of
            % interest
            EEG = eeg_checkset(EEG);
            EEG = pop_epoch(EEG,...
                unique(study_info.baseline_event_types),...
                study_info.extended_epoch_length_baseline,...
                'epochinfo', 'yes');
            [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        end
        
        preprocessing_info.(sprintf('%sNumTrials', study_info.trial_type{trl_type}))(s)=EEG.trials;
    
        % Correct for DC offset, using the average of the whole epoch
        EEG = eeg_checkset(EEG);
        EEG = pop_rmbase(EEG, [ ]);
        [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

        % Check whether the list of channels to check for artifact
        % rejection are present in dataset
        if strcmp(study_info.interp_chan, 'yes')==1

            nbchans=cell(1,EEG.nbchan);
            for i=1:EEG.nbchan
                nbchans{i}= EEG.chanlocs(i).labels;
            end

            if EEG.nbchan < 65
                chan_to_check = {'E1', 'E2', 'E5', 'E10', 'E11', 'E17'};
            elseif EEG.nbchan > 65
                chan_to_check = {'E1', 'E8', 'E14', 'E21', 'E25', 'E32',...
                    'E17'};
            end

            [~, chansidx] = ismember(chan_to_check, nbchans);

            %% Get indecies of the frontal channels to check.
            chan_to_check_idx = chansidx(chansidx ~= 0);

            % If no channel from the list present in the data, print the
            % error message
            if isempty(chan_to_check_idx) ==1
                error('No channel from the list present in the dataset');
            end

            %% Find artifaceted epochs by detecting outlier voltage in the
            % specified channels list and remore epoch if artifacted in
            % those channels
            for ch =1:length(chan_to_check_idx)
                EEG = pop_eegthresh(EEG,1, chan_to_check_idx(ch),...
                    study_info.volthrs_low, study_info.volthrs_up,...
                    EEG.xmin, EEG.xmax,0,0);
                EEG = eeg_checkset(EEG);
                EEG = eeg_rejsuperpose(EEG, 1, 1, 1, 1, 1, 1, 1, 1);
                EEG = pop_rejepoch(EEG, (EEG.reject.rejthresh) ,0);
                [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
            end

            %% Interpolate artifacted data for all reaming channels
            numChans = EEG.nbchan;
            badChans = zeros(numChans, EEG.trials);

            %% Find artifacted epochs by detecting outlier voltage but
            % don't remove
            for ch=1:numChans
                EEG = pop_eegthresh(EEG,1, ch, study_info.volthrs_low,...
                    study_info.volthrs_up,EEG.xmin, EEG.xmax,0,0);
                EEG = eeg_checkset(EEG);
                EEG = eeg_rejsuperpose(EEG, 1, 1, 1, 1, 1, 1, 1, 1);
                badChans(ch,:) = EEG.reject.rejglobal;
            end

            tmpData = zeros(EEG.nbchan, EEG.pnts, EEG.trials);

            %% Loop through each epoch, select it, run interp, save data
            for e = 1:EEG.trials
                if EEG.trials>1
                    %% select only this epoch (e)
                    EEGe = pop_selectevent(EEG, 'epoch', e, 'deleteevents',...
                        'off', 'deleteepochs', 'on', 'invertepochs', 'off');
                else
                    EEGe=EEG;
                end
                % find which channels are bad for this epoch
                badChanNum = find(badChans(:,e)==1); 
                % interpolate the bad chans for this epoch
                EEGe_interp = eeg_interp(EEGe, badChanNum); 
                % store interpolated data into matrix
                tmpData(:,:,e) = EEGe_interp.data; 
            end

            % Now that all of the epochs have been interpolated, write the
            % data back to the main file
            EEG.data = tmpData;

            %% If more than 10% of channels in a epoch were interpolated
            % in a epoch, reject that epoch 
            % Find total number of channels
            numchan=EEG.nbchan;
            badepoch=[];
            for ei = 1:EEG.trials
                % Find how many channels are bad in a epoch
                NumbadChan = badChans(:,ei);
                if sum(NumbadChan) > floor((numchan/study_info.percent_chan))
                    badepoch(end+1)= ei;
                end
            end

            %% Delete the epochs in which more than 10% channels were
            % interpolated
            if length(badepoch)<EEG.trials
                EEG = pop_rejepoch(EEG, badepoch, 0);
                [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
            end

        else
            EEG = eeg_checkset(EEG);
            EEG = pop_eegthresh(EEG,1, 1:EEG.nbchan,...
                study_info.volthrs_low, study_info.volthrs_up,...
                EEG.xmin, EEG.xmax, 0, 0);
            EEG = eeg_checkset(EEG);
            EEG = eeg_rejsuperpose(EEG, 1, 1, 1, 1, 1, 1, 1, 1);
            EEG = pop_rejepoch(EEG, (EEG.reject.rejthresh) ,0);
            [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        end

        % Bring back deleted channels and interpolate data
        EEG = eeg_interp(EEG, channel_location);
        EEG = eeg_checkset(EEG);
        
        % Rereference data to average of all channels
        EEG = eeg_checkset(EEG);
        EEG = pop_reref(EEG, study_info.reref);
        [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
        % Give a name to the dataset and save
        EEG = eeg_checkset(EEG);
        base_name=sprintf('%s_09_Referenced_Epoched_%s',...
            subject, study_info.trial_type{trl_type});
        EEG = pop_editset(EEG, 'setname', base_name);
        EEG = pop_saveset(EEG, 'filename', sprintf('%s.set', base_name),...
            'filepath', subject_output_data_dir);
        [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
        preprocessing_info.(sprintf('%sNumTrialsAfterRej',...
            study_info.trial_type{trl_type}))(s)=EEG.trials;
    end
end

% Match baseline and experimental epochs
if strcmp(study_info.baseline_type,'epoch_matched')
    preprocessing_info=matching_markers(study_info, preprocessing_info);
end

writetable(preprocessing_info, fullfile(study_info.output_dir,...
    'preprocessing_info.csv'));
  