% This function converts epoched data to current source density values
% using CSD toolbox
function csd_transform(study_info)

%% Open EEGlab
[ALLEEG, EEG, CURRENTSET] = eeglab; % run EEGLAB

for s=1:size(study_info.participant_info,1)
    
    % Get subject ID from study info
    subject=study_info.participant_info.participant_id{s};
    
    % Where to put processed (derived) data
    subject_output_data_dir=fullfile(study_info.output_dir, subject,...
        'eeg');
    
    fprintf('\n\n\n*** Processing subject %d (%s) ***\n\n\n', s, subject);
    
    for trltype = 1:length(study_info.trial_type)
        
        % Load the epoched dataset (filename depends on whether
        % epoch matching was done
        fname=sprintf('%s_09_Referenced_Epoched_%s.set', subject,...
            study_info.trial_type{trltype});
        if strcmp(study_info.baseline_type,'epoch_matched')
            fname=sprintf('%s_10_Epoched_Matched_%s.set', subject,...
            study_info.trial_type{trltype});
        end        
        EEG=pop_loadset('filename', fname, 'filepath',...
            subject_output_data_dir);
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
        
        %% Get usable list of electrodes from EEGlab data structure
        trodes=[];        
        for site = 1:EEG.nbchan
            trodes{site}=(EEG.chanlocs(site).labels);
        end
        trodes=trodes';
        
        %% Get Montage for use with CSD Toolbox
        Montage=ExtractMontage(study_info.current_montage_path, trodes);
        MapMontage(Montage);
        
        %% Derive G and H!
        [G,H] = GetGH(Montage);
        
        %% claim memory to speed computations
        data = single(repmat(NaN,size(EEG.data))); % use single data precision
        
        %% Instruction set #1: Looping method of Jenny
        for ne = 1:length(EEG.epoch)               % loop through all epochs
            myEEG = single(EEG.data(:,:,ne));      % reduce data precision to reduce memory demand
            MyResults = CSD(myEEG,G,H);            % compute CSD for <channels-by-samples> 2-D epoch
            data(:,:,ne) = MyResults;              % assign data output
        end
        EEG.data=double(data);                     % final CSD data
        
        %% Give a name to the dataset and save
        EEG = eeg_checkset( EEG );
        out_name=sprintf('%s_11_Referenced_Epoched_CSD_%s', subject,...
            study_info.trial_type{trltype});
        if strcmp(study_info.baseline_type,'epoch_matched')
            out_name=sprintf('%s_11_Epoch_Matched_CSD_%s', subject,...
                study_info.trial_type{trltype});
        end
        EEG = pop_editset(EEG, 'setname', out_name);
        EEG = pop_saveset(EEG, 'filename', sprintf('%s.set', out_name),...
            'filepath', subject_output_data_dir);
        [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
        STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
    end
end

close all;