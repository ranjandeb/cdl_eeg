function time_frequency_cluster_analysis(study_info)

fname=fullfile(study_info.output_dir,...
    study_info.participant_info.participant_id{1}, 'eeg',...
    'final_channel_locations.mat');
load(fname);

%% Find indices of the channels
for clus_idx=1:length(study_info.clusters)
    study_info.clusters(clus_idx).chan_idx=[];
    for c=1:length(study_info.clusters(clus_idx).channels)
        chan_idx=find(strcmp({channel_location.labels},...
            study_info.clusters(clus_idx).channels{c}));
        study_info.clusters(clus_idx).chan_idx(end+1)=chan_idx;
    end
end

out_dir=fullfile(study_info.output_dir, 'tf');
if exist(out_dir,'dir')~=7
    mkdir(out_dir);
end

% Initialize excluded and included subjects
excluded={};
included=study_info.participant_info.participant_id;

% Apply exclusion criteria
for i=1:length(study_info.tf_exclude_subjects)
    eval(sprintf('[excluded, included]=%s(study_info, excluded, included);', study_info.tf_exclude_subjects{i}));
end

for cond = 1:length(study_info.experimental_conditions)
    %% Load all data in a matrix freq x time x channel x subjects
    tf_all = [];

    s_idx=1;    
    %% Loop through all subjects
    for s=1:size(study_info.participant_info,1)
    
        % Get subject ID from study info
        subject=study_info.participant_info.participant_id{s};

        % If subject not excluded
        if find(strcmp(included, subject))
            % Where to put processed (derived) data
            subject_output_data_dir=fullfile(study_info.output_dir,...
                subject, 'eeg');
            tf_output_dir=fullfile(subject_output_data_dir, 'tf');

            fname = fullfile(tf_output_dir, sprintf('%s_timefreqs_%s_%s.mat',...
                subject, study_info.baseline_normalize,...
                study_info.experimental_conditions{cond}));
            load(fname);            
            tf_all(:,:,:,s_idx) = timefreqs_data;
            s_idx=s_idx+1;
        end
    end
        
    for clus_idx=1:length(study_info.clusters)
        timefreqs_data = squeeze(mean(tf_all(:,:,study_info.clusters(clus_idx).chan_idx,:), 3));
        save_name = fullfile(out_dir, sprintf('time_freqs_%s_%s_%s.mat',...
            study_info.baseline_normalize,...
            study_info.experimental_conditions{cond},...
            study_info.clusters(clus_idx).name));
        save(save_name, 'timefreqs_data', 'time', 'frequency', 'included');
    end    
end
