function compute_absolute_relative_power(study_info)

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

        tf_output_dir=fullfile(subject_output_data_dir, 'tf');

        %% Get channel location from dataset
        channel_location = EEG.chanlocs;

        %% Get parameters of EEG dataset
        data_length = EEG.pnts;
        srate = EEG.srate;
        nyquist = srate/2;
        freqs = linspace(0, nyquist, floor(data_length/2+1));

        for cond_idx=1:length(study_info.experimental_conditions)
            cond_epochs=[];
            for epoch_idx=1:length(EEG.epoch)
                epoch=EEG.epoch(epoch_idx);
                ref_evt_idx=find(cell2mat(epoch.eventlatency)==0);
                field_vals=epoch.(sprintf('event%s', lower(study_info.experimental_event_condition_fields{cond_idx})));
                if strcmp(field_vals{ref_evt_idx}, study_info.experimental_event_condition_field_values{cond_idx})
                    cond_epochs(end+1)=epoch_idx;
                end
            end
            if length(cond_epochs)>0
                EEGa=pop_select(EEG, 'trial', cond_epochs);

                % Initialize variables
                abs_freq_bands=[];
                rel_freq_bands=[];

                %% Loop through all channels
                for elec = 1:EEGa.nbchan

                    %% Initialize variables
                    trial_power=[];                        
                    for trl=1:EEGa.trials
                        %% Compute fourier coefficient
                        data=EEGa.data(elec,:,trl); %
                        data_hann=data.*hann(data_length)'; % apply hanning taper
                        data_fft=fft(data_hann); % % Fourier transform of data
                        data_pos_freq=data_fft(1:floor(data_length/2+1)); % get only positive frequencies
                        data_amp=abs(data_pos_freq); % get the amplitude of the frequencies
                        data_norma=data_amp/data_length; % normalizing amplitude by length of data to have them be in same scale as data
                        data_amp_pos_freq= 2*data_norma(2:end-1); % multiply amplitude by 2 because negative frequencies were removed
                        data_power=data_amp_pos_freq.^2; % power is amplitude square
                        trial_power(:,trl)=data_power; % Hold power in a frequency x trial matrix
                    end
                    chan_power=mean(trial_power, 2); % mean over trials (2nd dimensuion)
                    chan_power=log10(1+chan_power); % take natural log of power for better distribution

                    %% Find indecies of the frequencies
                    frequency=freqs(2:end-1); % Frequency range excluding DC and nyquest

                    for f_idx=1:length(study_info.freq_bands)
                        foi=study_info.freq_bands(f_idx).foi;
                        freq_idx=intersect(find(frequency>=foi(1)), find(frequency<=foi(2)));

                        %% Find power for each frequency band of interest
                        freq_power  = chan_power(freq_idx);

                        %% Calculate absolute power
                        abs_power =  mean(chan_power(freq_idx));

                        %% Hold absolute power of each channel in a channel x power matrix
                        abs_freq_bands(f_idx,elec, :) = abs_power;

                        %% Compute relative power
                        totalPower     = sum(chan_power(freq_idx));

                        rel_freq_bands(f_idx,elec, :) = sum(freq_power)/(totalPower);

                    end
                end

                %% Save absolute power for each subject
                save_name = fullfile(tf_output_dir, sprintf('freq_band_power_%s.mat', study_info.experimental_conditions{cond_idx}));
                freq_bands=study_info.freq_bands;
                save (save_name, 'frequency', 'channel_location', 'freq_bands', 'abs_freq_bands', 'rel_freq_bands');
            end
        end
    end
end
