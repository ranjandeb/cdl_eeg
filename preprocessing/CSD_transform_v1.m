
eeglab;
Directories_Variable_Info_v6();

for s=1:length(subject_list)
    
    for trltype = 1:size(trial_type,2)
        %subject=num2str(subject_list(s));
        
        trodes=[];
        G=[];
        H=[];
        looping_CSD_final=[];
        
        subject = subject_list{s};
        
        fprintf('\n\n\n*** Processing subject %d (%s) ***\n\n\n', s, subject);
        
        % Load the component removed dataset
         EEG=pop_loadset('filename',[subject '_Epoched_Matched_'  trial_type{trltype} '.set'], 'filepath', Epoched_Matched_Data);
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
        
        %% Get usable list of electrodes from EEGlab data structure
        for site = 1:EEG.nbchan
            trodes{site}=(EEG.chanlocs(site).labels);
        end
        trodes=trodes';
        
        %% Get Montage for use with CSD Toolbox
        Montage=ExtractMontage(current_montage_path, trodes);
        MapMontage(Montage);
        
        %% Derive G and H!
        [G,H] = GetGH(Montage);
        
        %% claim memory to speed computations
        data = single(repmat(NaN,size(EEG.data))); % use single data precision
        
        %% Instruction set #1: Looping method of Jenny
        tic                                        % stopwatch on
        for ne = 1:length(EEG.epoch)               % loop through all epochs
            myEEG = single(EEG.data(:,:,ne));      % reduce data precision to reduce memory demand
            MyResults = CSD(myEEG,G,H);            % compute CSD for <channels-by-samples> 2-D epoch
            data(:,:,ne) = MyResults;              % assign data output
        end
        looping_CSD_final = double(data);          % final CSD data
        looping_time = toc;                         % stopwatch off
        
        data(:,:,:) = NaN;
        
        EEG.data=looping_CSD_final;
        
        %% Give a name to the dataset and save
        EEG = eeg_checkset( EEG );
        EEG = pop_editset(EEG, 'setname', [subject '_Epoched_Matched_CSD_' trial_type{trltype}]);
        EEG = pop_saveset( EEG, 'filename',[subject '_Epoched_Matched_CSD_' trial_type{trltype} '.set'],'filepath', CSD_Data);
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
        STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
    end
end

close all;