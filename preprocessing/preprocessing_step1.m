% Preprocessing level 1. This level of preprocessing includes: changing
% sampling rate, applying filters, faster, ICA, Adjust, etc.
% Parameters
%       study_info = study information structure (created with
%          init_study_info)
function preprocessing_step1(study_info)

%% Open EEGlab
[ALLEEG, EEG, CURRENTSET] = eeglab; % run EEGLAB

% Create preprocessing information table - this will hold information on
% the number of channels and trials rejected at each preprocessing step for
% each subject.
preprocessing_info = table();
% Initialize with subject IDs
preprocessing_info.Subject=study_info.participant_info.participant_id;

% Note that no ICA component is rejected here. Some ICs are only
% marked as bad here. Component rejection will be done at the next
% level of preprocessing.
for s=1:size(study_info.participant_info,1)
    
    % Get subject ID from study info
    subject=study_info.participant_info.participant_id{s};
    
    % Where original raw data is located
    subject_raw_data_dir=fullfile(study_info.data_dir, subject, 'eeg');
    
    % Where to put processed (derived) data
    subject_output_data_dir=fullfile(study_info.output_dir, subject,...
        'eeg');
    if exist(subject_output_data_dir,'dir')~=7
        mkdir(subject_output_data_dir);
    end
    
    fprintf('\n\n\n*** Processing subject %d (%s) ***\n\n\n', s, subject);
    
    % Load dataset in eeglab
    fname=sprintf('%s_task-%s_eeg.set',subject, study_info.task);
    EEG=pop_loadset('filename', fname, 'filepath', subject_raw_data_dir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
    
    % Load BIDS-formatted subject events
    % Must include measured task-related delay in 'latency' column (0 if
    % no delay or not measured
    fname=fullfile(subject_raw_data_dir, ...
        sprintf('%s_task-%s_events.tsv', subject, study_info.task));
    events=readtable(fname, 'FileType','text','Delimiter','\t',...
        'TreatAsEmpty',{''});
    
    % Load BIDS-formatted subject channels
    fname=fullfile(subject_raw_data_dir,...
        sprintf('%s_task-%s_channels.tsv', subject, study_info.task));
    channels=readtable(fname, 'FileType','text','Delimiter','\t',...
        'TreatAsEmpty',{''});
    
    % Adjust video markers for task related and EGI anti-aliasing time
    % offset
    for j=1:length(EEG.event)
        % Interference markers are not affected by anti-alias filter effect
        % or task delay
        if ~find(strcmp(study_info.interference_markers, EEG.event(j).type))
            delay_pts=(events.latency(j)+study_info.EGI_AATF)/1000.0*EEG.srate;
            EEG.event(j).latency=round(EEG.event(j).latency+delay_pts);
        end
    end
    
    % Resample data
    if study_info.sample_rate ~= floor(EEG.srate)
        EEG = eeg_checkset(EEG);
        EEG = pop_resample(EEG, study_info.sample_rate);
    end
    
    if study_info.remove_before_last_boundary
        % Find latency of last point at which data is discontinuous
        % Check if number of break cnt markers is 2 for all participants.
        % If > 2, then change the 2 below.
        disconMarkers = find(strcmp({EEG.event.type}, 'break cnt'));
        
        % Reject all data prior to last discontinuous event
        % Change end to 2 if Eprime was restarted
        EEG = eeg_eegrej(EEG, [1 EEG.event(disconMarkers(end)).latency]);
        EEG = eeg_checkset(EEG);
    end
    
    % Read the latency of cap removal
    capremMarkers = find(strcmp({EEG.event.type},...
        study_info.cap_remove_event));
    if ~isempty(capremMarkers)
        % Reject all data after cap removal
        EEG = eeg_eegrej(EEG, [EEG.event(capremMarkers).latency EEG.pnts]);
        EEG = eeg_checkset(EEG);
    end
    
    % Delete boundary markers
    BoundMarker = find(strcmp({EEG.event.type}, 'boundary'));
    EEG = pop_editeventvals(EEG,'delete',BoundMarker);
    EEG = eeg_checkset(EEG);
    
    %%
    % Filter data
    %     Calculate filter order using the formula: m = dF / (df / fs),
    %     where m = filter order,
    %     df = transition band width, dF = normalized transition width,
    %     fs = sampling rate
    %     dF is specific for the window type. Hamming window dF = 3.3    
    high_transband = study_info.highpass; % High pass transition band
    low_transband = 10; % Low pass transition band    
    hp_fl_order = 3.3 / (high_transband / EEG.srate);
    lp_fl_order = 3.3 / (low_transband / EEG.srate);
    
    % Round filter order to next higher even integer. Filter order is
    % always an even integer.
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
    high_cutoff = study_info.highpass/2;
    low_cutoff = study_info.lowpass + (low_transband/2);
    
    % Performing highpass filtering
    EEG = eeg_checkset(EEG);
    EEG = pop_firws(EEG, 'fcutoff', high_cutoff, 'ftype', 'highpass',...
        'wtype', 'hamming', 'forder', hp_fl_order, 'minphase', 0);
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
    
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %    
    % pop_firws() - filter window type hamming ('wtype', 'hamming')
    % pop_firws() - applying zero-phase (non-causal) filter ('minphase', 0)
    
    % Performing lowpass filtering
    EEG = eeg_checkset(EEG);
    EEG = pop_firws(EEG, 'fcutoff', low_cutoff, 'ftype', 'lowpass',...
        'wtype', 'hamming', 'forder', lp_fl_order, 'minphase', 0);
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
    
    % pop_firws() - transition band width: 10 Hz
    % pop_firws() - filter window type hamming ('wtype', 'hamming')
    % pop_firws() - applying zero-phase (non-causal) filter ('minphase', 0)
    
    %%    
    % The reference channel, Cz, is not present in dataset. But, a
    % reference channel is needed to run Faster. So, one channel is added
    % back in the dataset.
    EEG.nbchan=EEG.nbchan+1;
    
    % Add data value in the new channel. The new channel is initialized
    % with zero
    EEG.data(end+1,:)=0;
    
    % Check whether channel location file is present in the dataset. If
    % not, script stops running. If yes, labels the newly added channel as
    % Cz.
    if isempty(EEG.chanlocs)==1
        error('Dataset does not have channel location file');
    else
        EEG.chanlocs(end+1).labels = ' Cz';
    end
    
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    % Save number of initial channels to preprocessing info
    preprocessing_info.NumInitChannels(s)=EEG.nbchan;
    
    % Since Cz has been added, the dataset now has one more channels. 
    % Import the file that contains scalp locations of the intial channels
    % including Cz
    EEG = pop_chanedit(EEG, 'load',...
        {study_info.init_channel_locations 'filetype' 'autodetect'});
    EEG = eeg_checkset(EEG);
    
    %%
    % Delete outer layer of the channels
    if strcmp(study_info.delete_outlyr, 'yes')==1
        nbchans=cell(1,EEG.nbchan);
        for i=1:EEG.nbchan
            nbchans{i}= EEG.chanlocs(i).labels;
        end
        
        if EEG.nbchan == 65
            RemChans={'E23', 'E55', 'E61', 'E62', 'E63', 'E64'};
        elseif EEG.nbchan == 129
            RemChans={'E17' 'E38' 'E43' 'E44' 'E48' 'E49' 'E113' 'E114'...
                'E119' 'E120' 'E121' 'E125' 'E126' 'E127' 'E128' 'E56'...
                'E63' 'E68' 'E73' 'E81' 'E88' 'E94' 'E99' 'E107'};
        end
        
        [~,chansidx] = ismember(RemChans, nbchans);
        RemChans_Idx = chansidx(chansidx ~= 0);
        
        EEG = eeg_checkset(EEG);
        EEG = pop_select(EEG,'nochannel', RemChans_Idx);
        [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
        
    end
    
    % Save modified (final) channel locations
    channel_location=EEG.chanlocs;
    fname=fullfile(subject_output_data_dir, 'final_channel_locations.mat');
    save(fname, 'channel_location');
    
    % Save number of channels to preprocessing info
    preprocessing_info.NumChannels(s)=EEG.nbchan;
    
    % Remove channels marked as bad
    nbchans=cell(1,EEG.nbchan);
    for i=1:EEG.nbchan
        nbchans{i}= EEG.chanlocs(i).labels;
    end
    RemChans=channels.name(find(strcmp(channels.status,'bad')));
    [~,chansidx] = ismember(RemChans, nbchans);
    RemChans_Idx = chansidx(chansidx ~= 0);
    EEG = eeg_checkset(EEG);
    EEG = pop_select(EEG,'nochannel', RemChans_Idx);
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
    preprocessing_info.InitNumBadChannels(s)=length(RemChans_Idx);    
    
    % Run FASTER to find bad channels and reject
    list_properties = channel_properties(EEG, 1:EEG.nbchan, EEG.nbchan);
    FASTbadIdx=min_z(list_properties);
    FASTbadChans=find(FASTbadIdx==1);
    preprocessing_info.FASTNumBadChannels(s)=length(FASTbadChans);
    EEG = pop_select(EEG,'nochannel', FASTbadChans);
    
    % Save the bad channels in a separate file for each subject
    fname=fullfile(subject_output_data_dir,...
        sprintf('%s_Faster_Bad_Channels.mat',subject));
    save(fname,'FASTbadChans');
    
    % Cz was required as a reference channel to run faster. Now that faster
    % has been done Cz can be removed from dataset. Removing Cz makes ICA
    % simpler and is needed to run ADJUST. Cz can be added back later and
    % interpolated with clean data if necessary.    
    EEG = eeg_checkset(EEG);
    EEG = pop_select(EEG,'nochannel',{'Cz'});
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
    
    % Give a name to the dataset and save
    EEG = eeg_checkset(EEG);
    base_name=sprintf('%s_01_Faster_Filter', subject);
    EEG = pop_editset(EEG, 'setname', base_name);
    EEG = pop_saveset(EEG, 'filename', sprintf('%s.set', base_name),...
        'filepath', subject_output_data_dir);
    [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    % Remove the saved dataset from EEGLAB memory
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
    
end

%%
% In this stage, a copy of the dataset is made and ICA is performed on the
% copied data. Subsequently, ICA weights are transformed from the copied
% data to the main data.

% First make copy of the dataset and prepare the copied data for ICA.
% Preparation includes performing 1Hz high filter, segmenting the 
% continuous data into 1 second epochs, rejecting artifacted epochs.

for s=1:size(study_info.participant_info,1)
    
    % Get subject ID from study info
    subject=study_info.participant_info.participant_id{s};
    
    % Where to put processed (derived) data
    subject_output_data_dir=fullfile(study_info.output_dir, subject,...
        'eeg');
    
    fprintf('\n\n\n*** Processing subject %d (%s) ***\n\n\n', s, subject);
    
    % Load filtered dataset
    fname=sprintf('%s_01_Faster_Filter.set', subject);
    EEG=pop_loadset('filename', fname, 'filepath',...
        subject_output_data_dir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
    
    % Make a copy of the EEG dataset just loaded
    EEG = eeg_checkset(EEG);
    [ALLEEG, EEG, CURRENTSET] = pop_copyset(ALLEEG, 1, 2);
    
    % Perform highpass filter at 1Hz on copied dataset
    transband = study_info.hp_fl_4ICA;
    fl_cutoff = transband/2;
    fl_order = 3.3 / (transband / EEG.srate);
    
    if mod(floor(fl_order),2) == 0
        fl_order=floor(fl_order);
    elseif mod(floor(fl_order),2) == 1
        fl_order=floor(fl_order)+1;
    end
    
    EEG = eeg_checkset(EEG);
    EEG = pop_firws(EEG, 'fcutoff', fl_cutoff, 'ftype', 'highpass',...
        'wtype', 'hamming', 'forder', fl_order, 'minphase', 0);
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
    
    %%
    % Insert temporary/dummy event marker 1 second apart on continuous data
    % and epoch data time locked to the dummy marker
    
    % Convert time window into samples or data points
    time_samples = study_info.event_time_window*EEG.srate;
    
    % Calculate total number of event markers
    % End before last event to avoid out of boundary error
    event_numbers= 1:floor(length(EEG.data)/time_samples)-1; 
    
    % Calculate time point for each event marker
    % Start at 0 to include 0-1 second time window
    event_times = [0 event_numbers*time_samples]; 
    
    % Insert the temporary event markers (999) on continuous data
    for i=1:length(event_numbers)
        EEG.event(i).type=study_info.event_type;
        EEG.event(i).latency=event_times(i);
    end
    [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    % Epoch to the inserted 1s markers
    EEG = eeg_checkset(EEG);
    EEG = pop_epoch(EEG, {study_info.event_type},...
        [0 study_info.event_time_window], 'newname',...
        sprintf('%s_dummy_epoched_Copy',subject), 'epochinfo', 'yes');
    [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    %% Now find bad channels and delete them from dataset
    vol_thrs = [-1000 1000]; % [lower upper] threshold limit(s) in mV.
    emg_thrs = [-100 30]; % [lower upper] threshold limit(s) in dB.
    emg_freqs_limit = [20 40]; % [lower upper] frequency limit(s) in Hz.
    
    numChans =EEG.nbchan;
    numEpochs =EEG.trials;
    badChans = [];
    badEpochOutput = [];
    
    % Delete bad channels
    if strcmp(study_info.delete_chan, 'yes')
        for ch=1:numChans
            
            % Find artifaceted epochs by detecting outlier voltage
            EEG = pop_eegthresh(EEG, 1, ch, vol_thrs(1), vol_thrs(2),...
                EEG.xmin, EEG.xmax, 0, 0);
            EEG = eeg_checkset(EEG);
            
            % 1     	: data type (1: electrode, 0: component)
            % 0     	: Display with previously marked rejections?
            %             (0: no, 1: yes)
            % 0     	: Reject marked trials? (0: no, 1:yes)
            
            % Find artifacted epochs by using thresholding of frequencies
            % in the data. This method mainly rejects muscle movement (EMG)
            % artifacts
            EEG = pop_rejspec(EEG, 1, 'elecrange', ch, 'method', 'fft',...
                'threshold', emg_thrs, 'freqlimits', emg_freqs_limit,...
                'eegplotplotallrej', 0, 'eegplotreject', 0);
            [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
            
            % method           	: method to compute spectrum (fft)
            % threshold        	: [lower upper] threshold limit(s) in dB.
            % freqlimits       	: [lower upper] frequency limit(s) in Hz.
            % eegplotplotallrej	: 0 = Do not superpose rejection marks on
            %                     previous marks stored in the dataset.
            % eegplotreject    	: 0 = Do not reject marked trials (but 
            %                     store the  marks.
            
            % Find number of artifacted epochs
            EEG = eeg_checkset(EEG);
            EEG = eeg_rejsuperpose(EEG, 1, 1, 1, 1, 1, 1, 1, 1);
            artifacted_epochs=EEG.reject.rejglobal;
            
            % Find bad channel / channel with more than 20% artifacted
            % epochs
            cutoff_epochs=numEpochs*study_info.cutoff_pcnt/100;
            if sum(artifacted_epochs) > cutoff_epochs
                badChans(end+1) = ch;
                badEpochOutput(end+1) = sum(artifacted_epochs);
            end
        end
        
        % Reject bad channel - channel with more than 20% artifacted epochs
        EEG = eeg_checkset(EEG);
        EEG = pop_select(EEG,'nochannel', badChans);
        
        % Save which channels are deleted for each subject.
        fname=fullfile(subject_output_data_dir,...
            sprintf('%s_Bad_Channels.mat', subject));
        save(fname,'badChans');
    end
    
    % Update preprocessing info
    preprocessing_info.ICANumBadChannels(s)=length(badChans);    
    preprocessing_info.InitPreICAEpochs(s)=EEG.trials;
    preprocessing_info.RejPreICAEpochs(s)=0;
    
    % Number of channels
    numChans=EEG.nbchan;
    
    %%
    % Now find the artifacted epochs across all channels and reject them
    % before doing ICA.
    if numChans>0
        % Find artifacted epochs by detecting outlier voltage after
        % rejection of bad channels
        EEG = pop_eegthresh(EEG,1, 1:numChans, vol_thrs(1), vol_thrs(2),...
            EEG.xmin, EEG.xmax,0,0);
        EEG = eeg_checkset(EEG);
        
        % Find artifacetd epochs by using thresholding of frequencies in
        % the data.
        EEG = pop_rejspec(EEG, 1,'elecrange',1:numChans ,'method','fft',...
            'threshold',emg_thrs,'freqlimits',emg_freqs_limit,...
            'eegplotplotallrej',0,'eegplotreject',0);
        [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
        % Find the number of artifacted epochs and reject them
        EEG = eeg_checkset(EEG);
        EEG = eeg_rejsuperpose(EEG, 1, 1, 1, 1, 1, 1, 1, 1);
        reject_artifacted_epochs = EEG.reject.rejglobal;
        EEG = pop_rejepoch(EEG, reject_artifacted_epochs ,0);
        
        % Find the number of rejected epochs
        reject_epoch = sum(reject_artifacted_epochs);
        
        % Give a name to the copied dataset and save after cleaning
        EEG = eeg_checkset(EEG);
        base_name=sprintf('%s_02_ready_for_ICA_Copy',subject);
        EEG = pop_editset(EEG, 'setname', base_name);
        EEG = pop_saveset(EEG, 'filename',sprintf('%s.set',base_name),...
            'filepath', subject_output_data_dir);
        [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
        STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
        
        preprocessing_info.RejPreICAEpochs(s)=reject_epoch;
    end
    
end

%%
% All the datasets are copied and prepared for ICA. Now ICA will be
% performed on the copied dataset ICA weights will be transformed from
% copied data to the original data
for s=1:size(study_info.participant_info,1)
    
    % Get subject ID from study info
    subject=study_info.participant_info.participant_id{s};
    
    % Where to put processed (derived) data
    subject_output_data_dir=fullfile(study_info.output_dir, subject,...
        'eeg');
    
    fprintf('\n\n\n*** Processing subject %d (%s) ***\n\n\n', s, subject);
    
    % Load copied dataset that has been prepared for ICA
    fname=sprintf('%s_02_ready_for_ICA_Copy.set', subject);
    EEG=pop_loadset('filename', fname, 'filepath',...
        subject_output_data_dir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
    
    % Run ICA
    EEG = eeg_checkset(EEG);
    EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,...
        'stop', 1E-7, 'interupt','off');
    [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    % EEG:          EEGLAB data
    % icatype:      ICA algorithm to use (runica)
    % extended:     perform tanh() "extended-ICA" with sign estimation
    %                every N training blocks (0: no, 1: yes (recomended))
    % interupt:     press button to interupt ICA
    
    % Give dataset a name  and save it after ICA
    EEG = eeg_checkset(EEG);
    base_name=sprintf('%s_03_ICA_Copy', subject);
    EEG = pop_editset(EEG, 'setname', base_name);
    EEG = pop_saveset(EEG, 'filename', sprintf('%s.set', base_name),...
        'filepath', subject_output_data_dir);
    [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    % Now find the ICA weights that will be transfered to the original
    % dataset
    ICA_WINV=EEG.icawinv;
    ICA_SPHERE=EEG.icasphere;
    ICA_WEIGHTS=EEG.icaweights;
    ICA_CHANSIND=EEG.icachansind;
    
    % Run adjust to find bad ICA components and save which ICs are bad
    adjust_report_fname=fullfile(subject_output_data_dir,...
        sprintf('%s_ADJUST_report.txt', subject));
    badIC = ADJUST(EEG, adjust_report_fname);
    % For each subject a .mat file containing bad IC numbers
    fname=fullfile(subject_output_data_dir,...
        sprintf('%s_Bad_IC.mat', subject));
    save (fname, 'badIC'); 
    
    % Save plot from adjusted ADJUST
    saveas(gcf, fullfile(subject_output_data_dir,...
        sprintf('%s_adjust_psds.png', subject)));
        
    % Remove the copied dataset from EEGLab memory/datset list
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
    
    %%
    % Now transfer the ICA weights of the copied dataset to the original
    % dataset
    
    % Load the original dataset
    fname=sprintf('%s_01_Faster_Filter.set', subject);
    EEG=pop_loadset('filename', fname, 'filepath',...
        subject_output_data_dir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
    
    % Find the bad channels to be removed
    if strcmp(study_info.delete_chan, 'yes')==1
        fname=fullfile(subject_output_data_dir,...
            sprintf('%s_Bad_Channels.mat', subject));
        bad_channel_file=load(fname);
        bad_channel_number= bad_channel_file.badChans;
        
        % Remove bad channels from dataset
        EEG = eeg_checkset(EEG);
        EEG = pop_select(EEG,'nochannel', bad_channel_number);
    end
    
    % Transfer the ICA weights of the copied dataset to the original
    % dataset
    EEG.icawinv= ICA_WINV;
    EEG.icasphere=ICA_SPHERE;
    EEG.icaweights=ICA_WEIGHTS;
    EEG.icachansind=ICA_CHANSIND;
    
    % Give a name to the original dataset now that ICA weights has been
    % added and save it
    EEG = eeg_checkset(EEG);
    base_name=sprintf('%s_04_ICA_Original', subject);
    EEG = pop_editset(EEG, 'setname', base_name);
    EEG = pop_saveset(EEG, 'filename', sprintf('%s.set', base_name),...
        'filepath', subject_output_data_dir);
    [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
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
for s=1:size(study_info.participant_info,1)
    
    % Get subject ID from study info
    subject=study_info.participant_info.participant_id{s};
    
    % Where to put processed (derived) data
    subject_output_data_dir=fullfile(study_info.output_dir, subject,...
        'eeg');
    
    fprintf('\n\n\n*** Processing subject %d (%s) ***\n\n\n', s, subject);
    
    % Load copied dataset in which ICA was done
    fname=sprintf('%s_03_ICA_Copy.set', subject);
    EEG=pop_loadset('filename', fname, 'filepath',...
        subject_output_data_dir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);
    
    % Mark the bad ICs found by ADJUST
    fname=fullfile(subject_output_data_dir,...
        sprintf('%s_Bad_IC.mat', subject));
    Adjust_File=load(fname);
    bad_ICs=Adjust_File.badIC;
    preprocessing_info.ADJUSTRejICAs(s)=length(bad_ICs);
    
    for ic=1:length(bad_ICs)
        EEG.reject.gcompreject(1, bad_ICs(ic))=1;
    end
    
    % Give a name to the dataset after marking ICs picked up by ADJUST and
    % save
    EEG = eeg_checkset(EEG);
    base_name=sprintf('%s_05_Adjust', subject);
    EEG = pop_editset(EEG, 'setname', base_name);
    EEG = pop_saveset(EEG, 'filename', sprintf('%s.set', base_name),...
        'filepath', subject_output_data_dir);
    [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
    
end

writetable(preprocessing_info,...
    fullfile(study_info.output_dir, 'preprocessing_info.csv'));
