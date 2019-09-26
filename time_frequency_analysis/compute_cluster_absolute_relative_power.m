function compute_cluster_absolute_relative_power(study_info)

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

% Initialize excluded and included subjects
excluded={};
included=study_info.participant_info.participant_id;

% Apply exclusion criteria
for i=1:length(study_info.tf_exclude_subjects)
    eval(sprintf('[excluded, included]=%s(study_info, excluded, included);', study_info.tf_exclude_subjects{i}));
end

out_dir=fullfile(study_info.output_dir, 'tf');
s_idx=1;

for cond_idx=1:length(study_info.experimental_conditions)
    all_subjs_abs_freq_bands=[];
    all_subjs_rel_freq_bands=[];
    
    %% Loop through all subjects
    for s=1:size(study_info.participant_info,1)

        % Get subject ID from study info
        subject=study_info.participant_info.participant_id{s};

        % If subject not excluded
        if find(strcmp(included, subject))
            subject_output_data_dir=fullfile(study_info.output_dir, subject, 'eeg');
            tf_output_dir=fullfile(subject_output_data_dir, 'tf');                
            fname = fullfile(tf_output_dir, sprintf('freq_band_power_%s.mat', study_info.experimental_conditions{cond_idx}));
            if exist(fname,'file')==2
                load(fname);
                
                for clus_idx=1:length(study_info.clusters)
                    cluster_chans=study_info.clusters(clus_idx).chan_idx;
                    for f_idx=1:length(study_info.freq_bands)
                        cluster_band_abs_power=mean(abs_freq_bands(f_idx,cluster_chans),2);
                        cluster_band_rel_power=mean(rel_freq_bands(f_idx,cluster_chans),2);
                        all_subjs_abs_freq_bands(s_idx,clus_idx,f_idx)=cluster_band_abs_power;
                        all_subjs_rel_freq_bands(s_idx,clus_idx,f_idx)=cluster_band_rel_power;                                                
                    end
                end
                s_idx=s_idx+1;
            end
        end
    end        
    
    for clus_idx=1:length(study_info.clusters)
        cluster_name=study_info.clusters(clus_idx).name;
        abs_freq_bands=squeeze(all_subjs_abs_freq_bands(:,clus_idx,:));
        rel_freq_bands=squeeze(all_subjs_rel_freq_bands(:,clus_idx,:));
        
        %% Save absolute power for each subject
        save_name = fullfile(out_dir, sprintf('freq_band_power_%s_%s.mat', cluster_name, study_info.experimental_conditions{cond_idx}));
        freq_bands=study_info.freq_bands;
        save (save_name, 'frequency', 'freq_bands', 'abs_freq_bands', 'rel_freq_bands');
    end
end
                


% for cond = 1:length(condition_name)
% 
%     
%     %% load data
%     for sub = 1:length(subject_list)
%         data_file = [data_location, num2str(subject_list(sub)), '_16yr_power_', condition_name{cond}, '.mat'];
%         load(data_file);
%         
%         data = [abs_theta, abs_alpha1, abs_alpha2, abs_beta1, abs_beta2, rel_theta, rel_alpha1, rel_alpha2, rel_beta1, rel_beta2];
%         
%         %% load all subject data in a matrix
%         if sub == 1
%             power_all = zeros([ size(data) length(subject_list)  ]);
%         end
%         
%         power_all(:,:,sub) = data;
%     end
%     
%     %% make cluster
%     F3_power = []; F4_power = []; C3_power =[]; C4_power =[];
%     P3_power = []; P4_power = []; O1_power =[]; O2_power =[];
%     
%     for i=1:length(F3)
%         F3_power   (i,:,:)   =   power_all(F3_idx(i),:,:);
%         F4_power   (i,:,:)   =   power_all(F4_idx(i),:,:);
%     end
%     
%     for i=1:length(C3)
%         C3_power   (i,:,:)   =   power_all(C3_idx(i),:,:);
%         C4_power   (i,:,:)   =   power_all(C4_idx(i),:,:);
%         P3_power   (i,:,:)   =   power_all(P3_idx(i),:,:);
%         P4_power   (i,:,:)   =   power_all(P4_idx(i),:,:);
%     end
%     
%     O1_power   (i,:,:)   =   power_all(O1_idx,:,:);
%     O2_power   (i,:,:)   =   power_all(O2_idx,:,:);
%     
%     %% save data
%     
%     chan_power = [];
%     chan_power = squeeze(mean(F3_power, 1));
%     save_name = [save_data condition_name{cond}, '_F3_power'];
%     save (save_name, 'chan_power', 'frequency');
%     
%     chan_power = [];
%     chan_power = squeeze(mean(F4_power, 1));
%     save_name = [save_data condition_name{cond}, '_F4_power'];
%     save (save_name, 'chan_power', 'frequency');
%     
%     chan_power = [];
%     chan_power = squeeze(mean(C3_power, 1));
%     save_name = [save_data condition_name{cond}, '_C3_power'];
%     save (save_name, 'chan_power', 'frequency');
%     
%     chan_power = [];
%     chan_power = squeeze(mean(C4_power, 1));
%     save_name = [save_data condition_name{cond}, '_C4_power'];
%     save (save_name, 'chan_power', 'frequency');
%     
%     chan_power = [];
%     chan_power = squeeze(mean(P3_power, 1));
%     save_name = [save_data condition_name{cond}, '_P3_power'];
%     save (save_name, 'chan_power', 'frequency');
%     
%     chan_power = [];
%     chan_power = squeeze(mean(P4_power, 1));
%     save_name = [save_data condition_name{cond}, '_P4_power'];
%     save (save_name, 'chan_power', 'frequency');
%     
%     chan_power = [];
%     chan_power = squeeze(mean(O1_power, 1));
%     save_name = [save_data condition_name{cond}, '_O1_power'];
%     save (save_name, 'chan_power', 'frequency');
%     
%     chan_power = [];
%     chan_power = squeeze(mean(O2_power, 1));
%     save_name = [save_data condition_name{cond}, '_O2_power'];
%     save (save_name, 'chan_power', 'frequency');
% end
% 
% 
% 
