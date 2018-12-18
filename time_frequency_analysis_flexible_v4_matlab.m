%% Perform time frequency calculation

Directories_Variable_Info_v6();

%% Locations
% Data_Location = CSD_avgbase;
Data_Location = CSD_Data;
Save_Data = TFR_Data;

%% define baseline time window
baseline_woi = epoch_length_baseline.*1000;

%% frequency parameters
min_freq =  freqOI(1);
max_freq = freqOI(end);

% frequencies vector
frex = logspace(log10(min_freq), log10(max_freq), num_frex);

%% wavelet cycles - variable : min 4 max 10
range_cycles = [ 3 10 ];
cylvec = logspace(log10(range_cycles(1)), log10(range_cycles(end)), num_frex)./ (2*pi*frex);

%% Loop through all subjects
for sub=1:length(subject_list)
    
    % load data
    subject = subject_list{sub};
    
    EEGbase = pop_loadset('filename',[subject '_Epoched_Matched_CSD_' trial_type{1} '.set'],'filepath', CSD_Data);
    EEG = pop_loadset('filename',[subject '_Epoched_Matched_CSD_' trial_type{2} '.set'],'filepath', CSD_Data);
    
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
    for cond_idx=1:length(condition_label)
        if isempty(find(strcmp({EEG.event.type}, all_match_exp_markers{cond_idx}))) == 1
            continue;
        end
        EEG_cond = pop_selectevent( EEG, 'type', {all_match_exp_markers{cond_idx}},'deleteevents','off','deleteepochs','on','invertepochs','off');
        EEG_cond_base = pop_selectevent( EEGbase, 'type', {all_match_base_markers{cond_idx}},'deleteevents','off','deleteepochs','on','invertepochs','off');
        
        %% baseline time indices
        basetimeidx   = dsearchn(EEG_cond_base.times', baseline_woi'); % baseline indecies
        if EEG_cond_base.times(1)>baseline_woi(1)-10 || EEG_cond_base.times(end)<baseline_woi(end)+10
            error('Your baseline sucks');
        end
        
        %% initialize output time-frequency data
        tf_data = zeros( length(frex), nData, EEG_cond.nbchan);
        
        %% Run wavelet convolution
        for ch=1:EEG_cond.nbchan % Loop through all channels
            
            for fi=1:length(frex) % loop through all frequencies
                
                cond_temppow = zeros(nData, EEG_cond.trials);
                base_temppow = zeros(nData, EEG_cond_base.trials);
                
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
                    cond_temppow (:,trl) = abs(trial_data_conv).^2;
                    
                end
                
                %% Loop through all baseline trials
                for trl=1:EEG_cond_base.trials
                    
                    base_trial_data = fft(squeeze(EEG_cond_base.data(ch,:,trl)), nConv);
                    
                    %% run convolution
                    base_trial_data_conv = ifft(waveletX .* base_trial_data);
                    base_trial_data_conv = base_trial_data_conv(half_wave+1:end-half_wave);
                    
                    %% compute power
                    base_temppow (:,trl) = abs(base_trial_data_conv).^2;
                    
                end
                %% Power average all trials
                cond_timefreqs(fi,:,:) = cond_temppow;
                base_timefreqs(fi,:,:) = base_temppow;
                
            end
            %% power data of all channels
            cond_tf_data(:,:,:,ch) = cond_timefreqs;
            base_tf_data(:,:,:,ch) = base_timefreqs;
        end
        %         Condspecific.(conditions{cond_idx}).cond_tf_data = cond_tf_data;
        %         Condspecific.(conditions{cond_idx}).base_tf_data = base_tf_data;
        
        if strcmp(baseline_normalize, baseline_type{1})==1
            
            %% Power average all trials
            cond_tempow_avgtrl = squeeze(mean(cond_tf_data, 3));
            base_tempow_avgtrl = squeeze(mean(base_tf_data, 3));
            
            for chan=1:size(cond_tf_data, 4)
                for freq=1:size(cond_tf_data, 1)
                    cond_tfreqs(freq,:) = 10*log10( cond_tempow_avgtrl(freq,:,chan) ./ mean(base_tempow_avgtrl(freq,basetimeidx(1):basetimeidx(end), chan)) );
                end
                timefreqs_data(:,:,chan)=cond_tfreqs;
            end
            time = EEG.times;
            frequency = frex;
            save_name = [Save_Data, subject, '_timefreqs_' conditions{cond_idx}];
            save(save_name, 'timefreqs_data', 'time', 'frequency', 'channel_location', '-v7.3');
            clear base_tempow_avgtrl cond_tempow_avgtrl cond_tfreqs timefreqs_data time frequency
            
            %% baseline normalization single trails / baseline power of same trial
        elseif strcmp(baseline_normalize, baseline_type{2})==1
            
            %% Baseline normalization
            timefreqs_data_indivtrls = [];
            for ch=1:size(cond_tf_data, 4)
                for trl=1:size(cond_tf_data, 3)
                    for fi=1:size(cond_tf_data, 1)
                        timefreqs(fi,:) = 10*log10( cond_tf_data(fi,:,trl,ch) ./ mean(base_tf_data(fi,basetimeidx(1):basetimeidx(end),trl,ch)) );
                    end
                    timefreqs_trl(:,:,trl) = timefreqs;
                end
                timefreqs_data_indivtrls(:,:,:,ch) = timefreqs_trl;
            end
            
            timefreqs_data = squeeze(mean(timefreqs_data_indivtrls,3));
            
            time = EEG.times;
            frequency = frex;
            save_name = [Save_Data, subject, '_timefreqs_' conditions{cond_idx}];
            save(save_name, 'timefreqs_data', 'time', 'frequency', 'channel_location', '-v7.3');
            clear base_tempow_avgtrl cond_tempow_avgtrl cond_tfreqs timefreqs_data time frequency
        end
        
        %% power data of all conditions
        
        Condspecific.(conditions{cond_idx}).cond_tf_data=cond_tf_data;
        Condspecific.(conditions{cond_idx}).base_tf_data =base_tf_data;
%          cond_timefrex_data(:,:,:,:, cond_idx) = cond_tf_data;
%         base_timefrex_data(:,:,:,:, cond_idx) = base_tf_data;
        
        EEG_cond=[];
        EEG_cond_base=[];
        clear base_trial_data base_trial_data_conv base_temppow base_timefreqs base_tf_data ...
            tf_data cond_trial_data cond_trial_data_conv cond_temppow cond_timefreqs cond_tf_data
    end
    
    
    
    %% baseline normalization type 3
    
    if strcmp(baseline_normalize, baseline_type{3})==1
        
        % Condspecific.(conditions{cond_idx}).cond_tf_data
        % Condspecific.(conditions{cond_idx}).base_tf_data
        for cond = 1:length(condition_label)
            base_temppow_avgtrl_percond(:,:,:,cond) = squeeze(mean(Condspecific.(conditions{cond}).base_tf_data,3));
        
        end
        
        base_temppow_avgtrl = squeeze(mean(base_temppow_avgtrl_percond, 4));
        
        for cond = 1:length(condition_label)
            cond_tf_temppow = squeeze(mean(Condspecific.(conditions{cond}).cond_tf_data,3));
            
            %% Baseline normalization
            cond_time_frex_data = [];
            for ch=1:size(cond_tf_temppow, 3)
                cond_time_freqs = [];
                for fi=1:size(cond_tf_temppow, 1)
                    cond_time_freqs(fi,:) = 10*log10( cond_tf_temppow(fi,:,ch) ./ mean(base_temppow_avgtrl(fi,basetimeidx(1):basetimeidx(end), ch)) );
                end
                cond_time_frex_data(:,:,ch)=cond_time_freqs;
            end
            
            %% save data
            time = EEG.times;
            frequency = frex;
            timefreqs_data = cond_time_frex_data;
            save_name = [Save_Data, subject, '_timefreqs_globavg_' conditions{cond}];
            save(save_name, 'timefreqs_data', 'time', 'frequency', 'channel_location', '-v7.3');
            
        end
        clear base_tempow_avgtrl cond_tempow_avgtrl cond_tfreqs timefreqs_data time frequency
    end
end
