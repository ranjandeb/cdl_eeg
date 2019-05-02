%% Artifact rejection

% Correct for DC offset, using the average of the whole epoch
EEG = eeg_checkset( EEG );
EEG = pop_rmbase( EEG, [ ]);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

% Check whether the list of channels to check for artifact rejection are present in dataset
if strcmp(interp_chan, 'yes')==1
    
    nbchans=cell(1,EEG.nbchan);
    for i=1:EEG.nbchan
        nbchans{i}= EEG.chanlocs(i).labels;
    end
    
    if EEG.nbchan < 65
        chan_to_check = {'E1', 'E2', 'E5', 'E10', 'E11', 'E17'};
    elseif EEG.nbchan > 65
        chan_to_check = {'E1', 'E8', 'E14', 'E21', 'E25', 'E32', 'E17'};
    end
    
    [chans,chansidx] = ismember(chan_to_check, nbchans);
    
    %% Get indecies of the frontal channels to check.
    chan_to_check_idx = chansidx(chansidx ~= 0);
    
    % If no channel from the list present in the data, print the error message
    if isempty(chan_to_check_idx) ==1
        error('No channel from the list present in the dataset');
    end
    
    %% Find artifaceted epochs by detecting outlier voltage in the specified
    % channels list and remore epoch if artifacted in those channels
    for ch =1:length(chan_to_check_idx)
        EEG = pop_eegthresh(EEG,1, chan_to_check_idx(ch), volthrs_low, volthrs_up, EEG.xmin, EEG.xmax,0,0);
        EEG = eeg_checkset( EEG );
        EEG = eeg_rejsuperpose( EEG, 1, 1, 1, 1, 1, 1, 1, 1);
        EEG = pop_rejepoch( EEG, (EEG.reject.rejthresh) ,0);
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    end
    
    %% Interpolate artifacted data for all reaming channels
    numChans = EEG.nbchan;
    badChans = zeros(numChans, EEG.trials);
    
    %% Find artifacted epochs by detecting outlier voltage but don't remove
    for ch=1:numChans
        EEG = pop_eegthresh(EEG,1, ch, volthrs_low, volthrs_up, EEG.xmin, EEG.xmax,0,0);
        EEG = eeg_checkset( EEG );
        EEG = eeg_rejsuperpose( EEG, 1, 1, 1, 1, 1, 1, 1, 1);
        badChans(ch,:) = EEG.reject.rejglobal;
    end
    
    %% Find how many epochs there are
    numEpochs = EEG.trials;
    tmpData = zeros(EEG.nbchan, EEG.pnts, EEG.trials);
    
    %% Loop through each epoch, select it, run interp, save data
    for e = 1:numEpochs
        % Initialize variables EEGe and EEGe_interp;
        EEGe = [];
        EEGe_interp = [];
        badChanNum = [];
        
        %% select only this epoch (e)
        EEGe = pop_selectevent( EEG, 'epoch', e, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
        badChanNum = find(badChans(:,e)==1); % find which channels are bad for this epoch
        EEGe_interp = eeg_interp(EEGe, badChanNum); % interpolate the bad chans for this epoch
        tmpData(:,:,e) = EEGe_interp.data; % store interpolated data into matrix
    end
    
    % Now that all of the epochs have been interpolated, write the data back to the main file
    EEG.data = tmpData;
    
    %% If more than 10% of channels in a epoch were interpolated in a epoch, reject that epoch
    % Find total number of channels
    numchan=EEG.nbchan;
    i=1;
    badepoch=[];
    for ei = 1:numEpochs
        % Find how many channels are bad in a epoch
        NumbadChan = badChans(:,ei);
        if sum(NumbadChan) > floor((numchan/percent_chan))
            badepoch (i)= ei;
            i=i+1;
        end
    end
    
    %% Delete the epochs in which more than 10% channels were interpolated
    EEG = pop_rejepoch( EEG, badepoch, 0);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
else
    EEG = eeg_checkset( EEG );
    EEG = pop_eegthresh(EEG,1, [1:EEG.nbchan], volthrs_low, volthrs_up, EEG.xmin, EEG.xmax,0,0);
    EEG = eeg_checkset( EEG );
    EEG = eeg_rejsuperpose( EEG, 1, 1, 1, 1, 1, 1, 1, 1);
    EEG = pop_rejepoch( EEG, (EEG.reject.rejthresh) ,0);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
end

% Bring back deleted channels and interpolate data
        EEG = eeg_interp(EEG, channel_location);
        EEG = eeg_checkset(EEG);
        
        % Rereference data to average of all channels
        EEG = eeg_checkset( EEG );
        EEG = pop_reref( EEG, reref);
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
        % Give a name to the dataset after marking ICs picked up by ADJUST and save
        EEG = eeg_checkset( EEG );
        EEG = pop_editset(EEG, 'setname', [subject '_Referenced_Epoched_' trial_type{trl_type}]);
        EEG = pop_saveset( EEG, 'filename',[subject '_Referenced_Epoched_'  trial_type{trl_type} '.set'],'filepath', Epoched_Data);
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
        Trials_After_Rej=EEG.trials;
        sub_num=regexp(subject,'\d*','Match');
        sub_num=cell2mat(sub_num);
        sub_num=str2double(sub_num);
        dlmwrite(numtrl_bfafartrej, [sub_num trl_type Total_Trials Trials_After_Rej], '-append');
        
        Exclusion_Info.(['a' subject]).(trial_type{trl_type}).Trials_After_Rej = Trials_After_Rej;