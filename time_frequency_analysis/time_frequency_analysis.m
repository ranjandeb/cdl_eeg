%% Perform time frequency calculation
function time_frequency_analysis(study_info)

%% define baseline time window
baseline_woi = study_info.baseline_woi.*1000;

%% frequency parameters
min_freq = study_info.FOI(1);
max_freq = study_info.FOI(end);

% frequencies vector
frex = logspace(log10(min_freq), log10(max_freq), study_info.num_frex);
if strcmp(study_info.freq_space,'linear')
    frex = linspace(min_freq, max_freq, study_info.num_frex);
end

%% wavelet cycles - variable : min 4 max 10
range_cycles = [3 10];
cylvec = logspace(log10(range_cycles(1)), log10(range_cycles(end)), study_info.num_frex)./ (2*pi*frex);

% Initialize excluded and included subjects
excluded={};
included=study_info.participant_info.participant_id;

% Apply exclusion criteria
for i=1:length(study_info.tf_exclude_subjects)
    eval(sprintf('[excluded, included]=%s(study_info, excluded, included);', study_info.tf_exclude_subjects{i}));
end

%% Loop through all subjects
for s=1:size(study_info.participant_info,1)
    
    % Get subject ID from study info
    subject=study_info.participant_info.participant_id{s};

    % If subject not excluded
    if find(strcmp(included, subject))

        % Where to put processed (derived) data
        subject_output_data_dir=fullfile(study_info.output_dir, subject, 'eeg');
        tf_output_dir=fullfile(subject_output_data_dir, 'tf');
        if exist(tf_output_dir,'dir')~=7
            mkdir(tf_output_dir);
        end
    
        fprintf('\n\n\n*** Processing subject %d (%s) ***\n\n\n', s, subject);
    
        condition_EEG={};
        condition_EEGbase={};
    
        if strcmp(study_info.baseline_type,'epoch_matched')
            EEG = pop_loadset('filename', sprintf('%s_11_Epoched_Matched_CSD_experimental.set', subject),...
                'filepath', subject_output_data_dir);
            EEGbase = pop_loadset('filename', sprintf('%s_11_Epoched_Matched_CSD_baseline.set', subject),...
                'filepath', subject_output_data_dir);
        else
            EEG = pop_loadset('filename', sprintf('%s_11_Referenced_Epoched_CSD_experimental.set', subject),...
                'filepath', subject_output_data_dir);
        end
    
        cond_epochs=[];
        for cond_idx=1:length(study_info.experimental_conditions)
            for epoch_idx=1:length(EEG.epoch)
                epoch=EEG.epoch(epoch_idx);
                ref_evt_idx=find(cell2mat(epoch.eventlatency)==0);
                field_vals=epoch.(sprintf('event%s', lower(study_info.experimental_event_condition_fields{cond_idx})));
                if strcmp(field_vals{ref_evt_idx}, study_info.experimental_event_condition_field_values{cond_idx})
                    cond_epochs(end+1)=epoch_idx;
                end
            end
            if length(cond_epochs)>0
                condition_EEG{cond_idx}=pop_select(EEG, 'trial', cond_epochs);
                if strcmp(study_info.baseline_type,'epoch_matched')
                    condition_EEGbase{cond_idx}=pop_select(EEGbase, 'trial', cond_epochs);
                end
            end
        end
    
        %% Get some data parameters
        channel_location = EEG.chanlocs;
        
        %% wavelet parameters
        srate=EEG.srate; % sampling rate
        wavtime = -1:1/srate:1; % length of wavelet
        half_wave = (length(wavtime)-1)/2;
        
        %% FFT parameters
        nWave = length(wavtime);
        nData = EEG.pnts;
        nConv = nWave + nData - 1;
        
        %% Compute time-frequency for each condition
        for cond_idx=1:length(study_info.experimental_conditions)
            
            EEG_cond = condition_EEG{cond_idx};
            if strcmp(study_info.baseline_type,'epoch_matched')
                EEG_cond_base = condition_EEGbase{cond_idx};
                %% baseline time indices
                basetimeidx   = dsearchn(EEG_cond_base.times', baseline_woi'); % baseline indecies
                if EEG_cond_base.times(1)>baseline_woi(1)-10 || EEG_cond_base.times(end)<baseline_woi(end)+10
                    error('Your baseline sucks');
                end
            else
                %% baseline time indices
                basetimeidx   = dsearchn(EEG_cond.times', baseline_woi'); % baseline indecies
                if EEG_cond.times(1)>baseline_woi(1)-10 || EEG_cond.times(end)<baseline_woi(end)+10
                    error('Your baseline sucks');
                end
            end
            
            cond_tf_data=zeros(length(frex),nData, EEG_cond.trials,EEG_cond.nbchan);
            if strcmp(study_info.baseline_type,'epoch_matched')
                base_tf_data=zeros(length(frex),nData, EEG_cond_base.trials,EEG_cond.nbchan);
            end
            
            %% Run wavelet convolution
            for ch=1:EEG_cond.nbchan % Loop through all channels
                
                for fi=1:length(frex) % loop through all frequencies
                    
                    %% Create wavelate
                    wavelet  = exp(2*1i*pi*frex(fi).*wavtime) .* exp(-wavtime.^2./(2*cylvec(fi)^2));
                    waveletX = fft(wavelet, nConv); % fft of wavelet
                    waveletX = waveletX ./ max(waveletX); % normalize fft of wavelet
                    
                    %% Loop through all trials
                    for trl=1:EEG_cond.trials
                        
                        trial_data = fft(squeeze(EEG_cond.data(ch,:,trl)), nConv);
                        
                        %% run convolution
                        trial_data_conv = ifft(waveletX .* trial_data);
                        trial_data_conv = trial_data_conv(half_wave+1:end-half_wave);
                        
                        %% compute power
                        cond_tf_data(fi,:,trl,ch) = abs(trial_data_conv).^2;
                        
                    end
                    
                    if strcmp(study_info.baseline_type,'epoch_matched')
                        %% Loop through all baseline trials
                        for trl=1:EEG_cond_base.trials
                            
                            base_trial_data = fft(squeeze(EEG_cond_base.data(ch,:,trl)), nConv);
                            
                            %% run convolution
                            base_trial_data_conv = ifft(waveletX .* base_trial_data);
                            base_trial_data_conv = base_trial_data_conv(half_wave+1:end-half_wave);
                            
                            %% compute power
                            base_tf_data(fi,:,trl,ch) = abs(base_trial_data_conv).^2;
                            
                        end
                    end
                end
            end
            
            %% baseline normalization using mean of trials within condition
            if strcmp(study_info.baseline_normalize, 'within_condition')
                
                %% Power average all trials
                cond_tempow_avgtrl = squeeze(mean(cond_tf_data, 3));
                if strcmp(study_info.baseline_type,'epoch_matched')
                    base_tempow_avgtrl = squeeze(mean(base_tf_data, 3));
                else
                    base_tempow_avgtrl = cond_tempow_avgtrl;
                end
                
                %% initialize output time-frequency data
                timefreqs_data = zeros(length(frex), nData, EEG_cond.nbchan);
                for chan=1:size(cond_tf_data, 4)
                    for freq=1:size(cond_tf_data, 1)
                        timefreqs_data(freq,:,chan) = 10*log10(cond_tempow_avgtrl(freq,:,chan) ./ mean(base_tempow_avgtrl(freq,basetimeidx(1):basetimeidx(end), chan),2));
                    end
                end
                time = EEG.times;
                frequency = frex;
                
                time_idx=intersect(find(time>=study_info.epoch_length_experimental(1)*1000),find(time<=study_info.epoch_length_experimental(2)*1000));
                time=time(time_idx);
                timefreqs_data=timefreqs_data(:,time_idx,:);
                
                save_name = fullfile(tf_output_dir, sprintf('%s_timefreqs_%s_%s.mat', subject, study_info.baseline_normalize, study_info.experimental_conditions{cond_idx}));
                save(save_name, 'timefreqs_data', 'time', 'frequency', 'channel_location', '-v7.3');
                clear base_tempow_avgtrl cond_tempow_avgtrl cond_tfreqs timefreqs_data time frequency
                
            %% baseline normalization single trials / baseline power of same trial
            elseif strcmp(study_info.baseline_normalize, 'single_trial')
                
                %% initialize output time-frequency data
                timefreqs_data = zeros(length(frex), nData, EEG_cond.trials, EEG_cond.nbchan);
                for ch=1:EEG_cond.nbchan
                    for trl=1:EEG_cond.trials
                        for fi=1:length(frex)
                            if strcmp(study_info.baseline_type,'epoch_matched')
                                timefreqs_data(fi,:,trl,ch) = 10*log10(cond_tf_data(fi,:,trl,ch) ./ mean(base_tf_data(fi,basetimeidx(1):basetimeidx(end),trl,ch),2));
                            else
                                timefreqs_data(fi,:,trl,ch) = 10*log10(cond_tf_data(fi,:,trl,ch) ./ mean(cond_tf_data(fi,basetimeidx(1):basetimeidx(end),trl,ch),2));
                            end
                            
                        end
                    end
                end
                
                % Average over trials
                timefreqs_data = squeeze(mean(timefreqs_data,3));
                
                time = EEG.times;
                frequency = frex;
                
                time_idx=intersect(find(time>=study_info.epoch_length_experimental(1)*1000),find(time<=study_info.epoch_length_experimental(2)*1000));
                time=time(time_idx);
                timefreqs_data=timefreqs_data(:,time_idx,:);
                
                save_name = fullfile(tf_output_dir, sprintf('%s_timefreqs_%s_%s.mat', subject, study_info.baseline_normalize, study_info.experimental_conditions{cond_idx}));
                save(save_name, 'timefreqs_data', 'time', 'frequency', 'channel_location', '-v7.3');
                clear base_tempow_avgtrl cond_tempow_avgtrl cond_tfreqs timefreqs_data time frequency
            end
            
            %% power data of all conditions
            
            Condspecific.(study_info.experimental_conditions{cond_idx}).cond_tf_data=cond_tf_data;
            if strcmp(study_info.baseline_type,'epoch_matched')
                Condspecific.(study_info.experimental_conditions{cond_idx}).base_tf_data =base_tf_data;
            end
            
            clear base_trial_data base_trial_data_conv base_temppow base_timefreqs base_tf_data ...
                tf_data cond_trial_data cond_trial_data_conv cond_temppow cond_timefreqs cond_tf_data
        end
        
        
        
        %% baseline normalization using mean of all trials in all conditions
        if strcmp(study_info.baseline_normalize, 'across_condition')
            
            base_temppow_avgtrl=[];
            start_t_idx=1;
            for cond = 1:length(study_info.experimental_conditions)
                if strcmp(study_info.baseline_type,'epoch_matched')
                    base_tf_data=Condspecific.(study_info.experimental_conditions{cond}).base_tf_data;
                    base_temppow_avgtrl(:,:,start_t_idx:start_t_idx+size(base_tf_data,3)-1,:) = base_tf_data;                
                    start_t_idx=start_t_idx+size(base_tf_data,3);
                else
                    base_tf_data=Condspecific.(study_info.experimental_conditions{cond}).cond_tf_data;
                    base_temppow_avgtrl(:,:,start_t_idx:start_t_idx+size(base_tf_data,3)-1,:) = base_tf_data;                
                    start_t_idx=start_t_idx+size(base_tf_data,3);
                end
            end
            
            base_temppow_avgtrl = squeeze(mean(base_temppow_avgtrl, 3));
            
            for cond = 1:length(study_info.experimental_conditions)
                cond_tf_temppow = squeeze(mean(Condspecific.(study_info.experimental_conditions{cond}).cond_tf_data,3));
                
                %% Baseline normalization
                timefreqs_data = zeros(length(frex),nData,EEG_cond.nbchan);
                for ch=1:EEG_cond.nbchan
                    for fi=1:length(frex)
                        timefreqs_data(fi,:,ch) = 10*log10( cond_tf_temppow(fi,:,ch) ./ mean(base_temppow_avgtrl(fi,basetimeidx(1):basetimeidx(end), ch),2) );
                    end
                end
                
                %% save data
                time = EEG.times;
                frequency = frex;
                
                time_idx=intersect(find(time>=study_info.epoch_length_experimental(1)*1000),find(time<=study_info.epoch_length_experimental(2)*1000));
                time=time(time_idx);
                timefreqs_data=timefreqs_data(:,time_idx,:);
                
                save_name = fullfile(tf_output_dir, sprintf('%s_timefreqs_%s_%s.mat', subject, study_info.baseline_normalize, study_info.experimental_conditions{cond}));
                save(save_name, 'timefreqs_data', 'time', 'frequency', 'channel_location', '-v7.3');
                
            end
            clear base_tempow_avgtrl cond_tempow_avgtrl cond_tfreqs timefreqs_data time frequency
        end
    end
end
