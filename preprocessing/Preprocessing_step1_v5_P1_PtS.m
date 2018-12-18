% Preprocessing level 1. This level of preprocessing includes: changing
% sampling rate, applying filters, faster, ICA, Adjust, etc.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This is a EEG data preprocessing script. This script uses EEGLAB, an open
% source EEG data analysis toolbox.

% This script loads in continuous (.set) files from hard drive and performs a set
% of preprocessing steps (removing bad channel, filtering, ICA, Adjust, etc.)

% last updated on 4/17/2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
Individualized_Info_v12_P1_PtS();
%% Initiate directories of location to save data
cd 'E:\PTS_study_VS\Visit1\Scripts\Preprocessing\'
Directories_Variable_Info_v5();

%% Open EEGlab
eeglab; % run EEGLAB

% Note that no ICA component is rejected here. Some ICs are only
% marked as bad here. Component rejection will be done at the next
% level of preprocessing.


for s=1:length(subject_list)
    
    %subject=num2str(subject_list(s)); % Change dataset ID number to string
    
    subject=subject_list{s}; % Dataset ID is string. So, no need for num2str
    
    fprintf('\n\n\n*** Processing subject %d (%s) ***\n\n\n', s, subject);
    
    % Load dataset in eeglab
    EEG=pop_loadset('filename',[subject '.set'], 'filepath', data_location);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    % Import event markers
    EEG = eeg_checkset( EEG );
    EEG = pop_importevent( EEG, 'event',[event_location '\'  subject '.csv'] ,'fields',{'latency' 'type'},'timeunit',0.001,'align',0);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    % Adjust video markers for task related offset
    if EEG.srate < 500
        for j=1:length(EEG.event)
            EEG.event(j).latency=EEG.event(j).latency+(36/1000)*EEG.srate;
        end
    else
        for j=1:length(EEG.event)
            EEG.event(j).latency=EEG.event(j).latency+(18/1000)*EEG.srate;
        end
    end
        
    % Change sampling rate of data
    if sampling_rate ~= floor(EEG.srate)
        EEG = eeg_checkset( EEG );
        EEG = pop_resample( EEG, sampling_rate); % Data resampled at 500Hz
    end
    
    % Find latency of last point at which data is discontinuous
    % Check if number of break cnt markers is 2 for all participants. 
    % If > 2, then change the 2 below.
    disconMarkers = find(strcmp({EEG.event.type}, 'break cnt'));
    if length(disconMarkers)> 3
        error('More than 2 break cnt markers. Check your data. Should be 2.');
    else
        EEG.event(disconMarkers(end)).latency;
        EEG = eeg_checkset( EEG );
    end
    
    % Reject all data prior to last discontinuous event
    % Change end to 2 if Eprime was restarted
    EEG = eeg_eegrej( EEG, [1 EEG.event(disconMarkers(end)).latency] );
    EEG = eeg_checkset( EEG );
    
    
    % Read the lalency of cap remove
    capremMarkers = find(strcmp({EEG.event.type}, 'CAPS'));
    if ~isempty(capremMarkers)
        % Reject all data prior to last discontinuous event
        EEG = eeg_eegrej( EEG, [EEG.event(capremMarkers).latency EEG.event(end).latency]);
        EEG = eeg_checkset( EEG );
    end
    
    % Delete boundary marker inserted from break cnt rejection
    BoundMarker = find(strcmp({EEG.event.type}, 'boundary'));
    if length(BoundMarker)>1
        error('More than 1 boundary marker. Check your data. Shound be 1');
    else
        EEG = pop_editeventvals(EEG,'delete',BoundMarker);
        EEG = eeg_checkset( EEG );
    end
    
    %%
    % Filter data
%     Calculate filder order using the formula: m = dF / (df / fs), where m = filter order, 
%     df = transition band width, dF = normalized transition width, fs = sampling rate
%     dF is specific for the window type. Hamming window dF = 3.3
    
    high_transband = highpass; % High pass transition band
    low_transband = 10; % Low pass transition band
    
    hp_fl_order = 3.3 / (high_transband / EEG.srate);
    lp_fl_order = 3.3 / (low_transband / EEG.srate);
    
    % Round filter order to next higher even integer. Filter order is always even integer.
    if mod(floor(hp_fl_order),2) == 0
        hp_fl_order=floor(hp_fl_order);
    elseif mod(floor(hp_fl_order),2) == 1
        hp_fl_order=floor(hp_fl_order)+1;
    end
    
    if mod(floor(lp_fl_order),2) == 0
        lp_fl_order=floor(lp_fl_order)+2;
    elseif mod(floor(lp_fl_order),2) == 1 
        lp_fl_order=floor(lp_fl_order)+1;
    end
    
    % Calculate cutoff frequency    
    high_cutoff = highpass/2;
    low_cutoff = lowpass + (low_transband/2);
    
    % Performing highpass filtering
    EEG = eeg_checkset( EEG );
    EEG = pop_firws(EEG, 'fcutoff', high_cutoff, 'ftype', 'highpass', 'wtype', 'hamming', 'forder', hp_fl_order, 'minphase', 0);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    
    % pop_firws() - filter window type hamming ('wtype', 'hamming')
    % pop_firws() - applying zero-phase (non-causal) filter ('minphase', 0)
    
    % Performing lowpass filtering
    EEG = eeg_checkset( EEG );
    EEG = pop_firws(EEG, 'fcutoff', low_cutoff, 'ftype', 'lowpass', 'wtype', 'hamming', 'forder', lp_fl_order, 'minphase', 0);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    % pop_firws() - transition band width: 10 Hz
    % pop_firws() - filter window type hamming ('wtype', 'hamming')
    % pop_firws() - applying zero-phase (non-causal) filter ('minphase', 0) 
    
    %%
    
    % The reference channel, Cz, is not present in dataset. But, a
    % reference channel is needed to run Faster. So, one channel is added
    % back in the dataset.
    EEG.nbchan=EEG.nbchan+1;
    
    % Add data value in the new channel. The new channel is initialized with zero
    EEG.data(end+1,:)=0;
    
    % Check whether channel location file is present in the dataset. If not,
    % script stops running. If yes, labels the newly added channel as Cz.
    if isempty(EEG.chanlocs)==1
        error('Dataset does not have channel location file');
    else
        EEG.chanlocs(end+1).labels = ' Cz';
    end
    
    [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    % Initially there were 128 channels in the dataset. Since Cz has been
    % added, the dataset now has 129 channels. Import the file that contains
    % scalp locations of 129 channels.
    EEG=pop_chanedit(EEG, 'load',{ch129_locations 'filetype' 'autodetect'});
    EEG = eeg_checkset( EEG );
    
    %%
    % Delete outer layer of the channels
    if strcmp(delete_outlyr, 'yes')==1
        nbchans=cell(1,EEG.nbchan);
    for i=1:EEG.nbchan
        nbchans{i}= EEG.chanlocs(i).labels;
    end
        
    if EEG.nbchan == 65
    RemChans={'E23', 'E55', 'E61', 'E62', 'E63', 'E64'};
    elseif EEG.nbchan == 129
    RemChans={'E17' 'E38' 'E43' 'E44' 'E48' 'E49' 'E113' 'E114' 'E119' 'E120' 'E121' 'E125' 'E126' 'E127' 'E128' 'E56' 'E63' 'E68' 'E73' 'E81' 'E88' 'E94' 'E99' 'E107'};    
    end
    
    [chans,chansidx] = ismember(RemChans, nbchans);
    RemChans_Idx = chansidx(chansidx ~= 0);
    
    EEG = eeg_checkset( EEG );
    EEG = pop_select( EEG,'nochannel', RemChans_Idx);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    end
    
    % Run faster to find bad channels
    list_properties = channel_properties(EEG, 1:EEG.nbchan, EEG.nbchan); % Add length of
    % channels and specify reference channel. Here 105, which is Cz.
    
    FASTbadIdx=min_z(list_properties);
    FASTbadChans=find(FASTbadIdx==1);
    
    % Reject channels that are bad as identified by Faster
    EEG = pop_select( EEG,'nochannel', FASTbadChans);
    
    % Save the number of bad channels in a separate file for each subject
    subject_name=[subject '_Faster_Bad_Channels.mat'];
    save([bad_channels subject_name],'FASTbadChans');
    
    % Cz was required as a reference channel to run faster. Now that faster
    % has been done Cz can be removed from dataset. Removing Cz makes ICA
    % simpler and is needed to run ADJUST. Cz can be added back later and
    % interpolated with clean data if necessary.
    
    % Remove Cz
    EEG = eeg_checkset( EEG );
    EEG = pop_select( EEG,'nochannel',{'Cz'});
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    % Give a name to the dataset and save on hard drive
    EEG = eeg_checkset( EEG );
    EEG = pop_editset(EEG, 'setname', [subject '_Faster_Filter']);
    EEG = pop_saveset( EEG, 'filename',[subject '_Faster_Filter'],'filepath', filtered_data);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    % Remove the saved dataset from EEGLAB memory
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
    
end

%%
% In this analysis protocol, a copy of the dataset is made and ICA is
% performed in the copied data. Subsequently, ICA weights are transformed
% from the copied data to the main data.

% First make copy of the dataset and prepare the copied data for ICA.
% Preparation includes performing 1Hz high filter, segmenting the continuous
% data into 1 second epoch, rejecting artifacted epochs.


for s=1:length(subject_list)
    
    subject=subject_list{s};
    % subject=num2str(subject_list(s));
    
    fprintf('\n\n\n*** Processing subject %d (%s) ***\n\n\n', s, subject);
    
    % Load filtered dataset
    EEG=pop_loadset('filename',[subject '_Faster_Filter.set'], 'filepath', filtered_data);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    % Make a copy of the EEG dataset just loaded
    EEG = eeg_checkset( EEG );
    [ALLEEG EEG CURRENTSET] = pop_copyset( ALLEEG, 1, 2);
    
    % Perform highpass filter at 1Hz on copied dataset
    transband = hp_fl_4ICA;
    fl_cutoff = transband/2;
    fl_order = 3.3 / (transband / EEG.srate);
    
    if mod(floor(fl_order),2) == 0
        fl_order=floor(fl_order);
    elseif mod(floor(fl_order),2) == 1
        fl_order=floor(fl_order)+1;
    end
    
    EEG = eeg_checkset( EEG );
    EEG = pop_firws(EEG, 'fcutoff', fl_cutoff, 'ftype', 'highpass', 'wtype', 'hamming', 'forder', fl_order, 'minphase', 0);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    %%
    % Insert temporary/dummy event marker 1 second apart on continuous data
    % and epoch data time locked to the dummy marker
    
    % Convert time window into samples or data points
    time_samples = event_time_window*EEG.srate;
    
    % Calculate total number of event markers
    event_numbers= 1:floor(length(EEG.data)/time_samples)-1; %  End before last  event to avoid out of boundary error
    
    % Calculate time point for each event marker
    event_times = [0 event_numbers*time_samples]; % Start at 0 to include 0-1 second time window
    
    % Insert the temporary event markers (999) on continuous data
    for i=1:length(event_numbers)
        EEG.event(i).type=event_type;
        EEG.event(i).latency=event_times(i);
    end
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    % Epoch to the inserted 1s markers
    EEG = eeg_checkset( EEG );
    EEG = pop_epoch( EEG, {event_type}, [0 event_time_window], 'newname', [subject '_dummy_epoched_Copy'], 'epochinfo', 'yes');
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
%% Now find bad channels and delete them from dataset
	vol_thrs = [-1000 1000]; % [lower upper] threshold limit(s) in mV.
	emg_thrs = [-100 30]; % [lower upper] threshold limit(s) in dB.
	emg_freqs_limit = [20 40]; % [lower upper] frequency limit(s) in Hz.
    
	numChans =EEG.nbchan; % Find the number of channels
	numEpochs =EEG.trials; % Find the number of epochs
	chanCounter = 1;
	badChans = [];
	badEpochOutput = [];
    
	if strcmp(delete_chan, 'yes')==1
	for ch=1:numChans
   	 
    	% Find artifaceted epochs by detecting outlier voltage
    	EEG = pop_eegthresh(EEG,1, ch, vol_thrs(1), vol_thrs(2), EEG.xmin, EEG.xmax, 0, 0);
    	EEG = eeg_checkset( EEG );
   	 
    	% 1     	: data type (1: electrode, 0: component)
    	% 0     	: Display with previously marked rejections? (0: no, 1: yes)
    	% 0     	: Reject marked trials? (0: no, 1:yes)
   	 
    	% Find artifaceted epochs by using thresholding of frequencies in
    	% the data. This method mainly rejects muscle movement (EMG) artifacts
    	EEG = pop_rejspec( EEG, 1,'elecrange',ch ,'method','fft','threshold', emg_thrs, 'freqlimits', emg_freqs_limit, 'eegplotplotallrej', 0, 'eegplotreject', 0);
    	[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
   	 
    	% method            	: method to compute spectrum (fft)
    	% threshold         	: [lower upper] threshold limit(s) in dB.
    	% freqlimits        	: [lower upper] frequency limit(s) in Hz.
    	% eegplotplotallrej 	: 0 = Do not superpose rejection marks on previous marks stored in the dataset.
    	% eegplotreject     	: 0 = Do not reject marked trials (but store the  marks.
   	 
    	% Find number of artifacted epochs
    	EEG = eeg_checkset( EEG );
    	EEG = eeg_rejsuperpose( EEG, 1, 1, 1, 1, 1, 1, 1, 1);
    	artifacted_epochs=EEG.reject.rejglobal;
   	 
    	% Find bad channel / channel with more than 20% artifacted epochs
    	if sum(artifacted_epochs) > (numEpochs*cutoff_pcnt/100)
        	badChans(chanCounter) = ch;
        	badEpochOutput(chanCounter) = sum(artifacted_epochs);
        	chanCounter=chanCounter+1;
    	end   
	end
    
	% Reject bad channel - channel with more than 20% artifacted epochs
	EEG = eeg_checkset( EEG );
	EEG = pop_select( EEG,'nochannel', badChans);
    
	% Save which channels are deleted for each subject.
	subject_name=[subject '_Bad_Channels.mat'];
	file_name=[Bad_Channels, subject_name];
	save(file_name,'badChans');
    end

    % Find total epochs
    total_epochs = EEG.trials;
    % Number of channels
    numChans=EEG.nbchan;
    
    %%
    % Now find the artifacted epochs across all channels and reject them
    % before doing ICA.
    
    % Find artifaceted epochs by detecting outlier voltage after rejection of bad channels
    EEG = pop_eegthresh(EEG,1, 1:numChans, vol_thrs(1), vol_thrs(2), EEG.xmin, EEG.xmax,0,0);
    EEG = eeg_checkset( EEG );
    
    % Find artifaceted epochs by using thresholding of frequencies in the data.
    EEG = pop_rejspec( EEG, 1,'elecrange',1:numChans ,'method','fft','threshold',emg_thrs ,'freqlimits',emg_freqs_limit ,'eegplotplotallrej',0,'eegplotreject',0);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    % Find the number of artifacted epochs and reject them
    EEG = eeg_checkset( EEG );
    EEG = eeg_rejsuperpose( EEG, 1, 1, 1, 1, 1, 1, 1, 1);
    reject_artifacted_epochs = EEG.reject.rejglobal;
    EEG = pop_rejepoch( EEG, reject_artifacted_epochs ,0);
    
    % Find the number of rejected epochs
    reject_epoch = sum(reject_artifacted_epochs);
    
    % Give a name to the copied dataset and save after cleaning
    EEG = eeg_checkset( EEG );
    EEG = pop_editset(EEG, 'setname', [subject '_ready_for_ICA_Copy']);
    EEG = pop_saveset( EEG, 'filename',[subject '_ready_for_ICA_Copy.set'],'filepath', copied_data);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
    
    sub_num=regexp(subject,'\d*','Match');
    sub_num=cell2mat(sub_num);
    sub_num=str2double(sub_num);
    dlmwrite(reject_copied_data, [sub_num total_epochs reject_epoch], '-append');
    
end

%%
% All the datasets are copied and prepared for ICA. Now ICA will be
% performed on the copied dataset ICA weights will be transformed from
% copied data to the original data

cd (ICA_copied_data)

for s=1:length(subject_list)
    
    %subject=num2str(subject_list(s));
    subject=subject_list{s};
    
    fprintf('\n\n\n*** Processing subject %d (%s) ***\n\n\n', s, subject);
    
    % Load copied dataset that has been prepared for ICA
    EEG=pop_loadset('filename',[subject '_ready_for_ICA_Copy.set'], 'filepath', copied_data);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    % Run ICA
    EEG = eeg_checkset( EEG );
    EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1, 'stop', 1E-7, 'interupt','off');
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    % EEG:          EEGLAB data
    % icatype:      ICA algorithm to use (runica)
    % extended:     perform tanh() "extended-ICA" with sign estimation
    %                every N training blocks (0: no, 1: yes (recomended))
    % interupt:     press button to interupt ICA
    
    % Give dataset a name  and save it after ICA
    EEG = eeg_checkset( EEG );
    EEG = pop_editset(EEG, 'setname', [subject '_ICA_Copy']);
    EEG = pop_saveset( EEG, 'filename',[subject '_ICA_Copy.set'],'filepath', ICA_copied_data);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    % Now find the ICA weights that would be transfered to the original dataset
    ICA_WINV=EEG.icawinv;
    ICA_SPHERE=EEG.icasphere;
    ICA_WEIGHTS=EEG.icaweights;
    ICA_CHANSIND=EEG.icachansind;
    
    % Run adjust to find bad ICA components and save which ICs are bad
    cd(Adjust_Data)
    badIC = ADJUST(EEG, [subject, '_Study1_ADJUST_report']);
    badIC_file_name = [ICA_copied_data subject '_Bad_IC'];
    save (badIC_file_name, 'badIC'); % For each subject A .mat file
    % containing bad IC numbers is saved in ICA_Copied_Data folder
    
    % Remove the copied dataset from EEGLab memory/datset list
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
    
    %%
    % Now transfer the ICA weights of the copied dataset to the original dataset
    
    % Load the original dataset
    EEG=pop_loadset('filename', [subject '_Faster_Filter.set'], 'filepath', filtered_data);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    % Find the bad channels to be removed
    if strcmp(delete_chan, 'yes')==1
    bad_channel_file=load([Bad_Channels subject '_Bad_Channels.mat']);
    bad_channel_number= bad_channel_file.badChans;
    
    % Remove bad channles from dataset
    EEG = eeg_checkset( EEG );
    EEG = pop_select( EEG,'nochannel', bad_channel_number);
    end
    
    % Transfer the ICA weights of the copied dataset to the original dataset
    EEG.icawinv= ICA_WINV;
    EEG.icasphere=ICA_SPHERE;
    EEG.icaweights=ICA_WEIGHTS;
    EEG.icachansind=ICA_CHANSIND;
    
    % Give a name to the original dataset now that ICA weights has been added and save it
    EEG = eeg_checkset( EEG );
    EEG = pop_editset(EEG, 'setname', [subject '_ICA_Original']);
    EEG = pop_saveset( EEG, 'filename',[subject '_ICA_Original.set'],'filepath', ICA_original_data);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    % Clear ICA weights of the copied dataset from matlab workspace because
    % overwriting might lead to erroneous results
    clear ICA_WINV;
    clear ICA_SPHERE;
    clear ICA_WEIGHTS;
    clear ICA_CHANSIND;
    clear bad_channel_number;
    
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
    
end

%%
% After ICA, Adjust was run on the copied dataset and Adjust found
% some artifacted ICs. Now mark those ICs as artifacted in original dataset

cd (ICA_copied_data)

for s=1:length(subject_list)
    
    %subject=num2str(subject_list(s));
    
    subject = subject_list{s};
    %
    fprintf('\n\n\n*** Processing subject %d (%s) ***\n\n\n', s, subject);
    
    % Load copied dataset in which ICA was done
    EEG=pop_loadset('filename',[subject '_ICA_Copy.set'], 'filepath', ICA_copied_data);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    % Mark the bad ICs found by ADJUST
    Adjust_File=load([ICA_copied_data subject '_Bad_IC.mat']);
    bad_ICs=Adjust_File.badIC;
    
    for ic=1:length(bad_ICs)
        EEG.reject.gcompreject(1, bad_ICs(ic))=1;
    end
    
    % Give a name to the dataset after marking ICs picked up by ADJUST and save
    EEG = eeg_checkset( EEG );
    EEG = pop_editset(EEG, 'setname', [subject '_Adjust']);
    EEG = pop_saveset( EEG, 'filename',[subject '_Adjust.set'],'filepath', Adjust_Data);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
    
end