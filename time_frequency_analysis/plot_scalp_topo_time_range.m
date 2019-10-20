function plot_scalp_topo_time_range(study_info, time_windows)

% Initialize excluded and included subjects
excluded={};
included=study_info.participant_info.participant_id;

% Apply exclusion criteria
for i=1:length(study_info.tf_exclude_subjects)
    eval(sprintf('[excluded, included]=%s(study_info, excluded, included);', study_info.tf_exclude_subjects{i}));
end

fname=fullfile(study_info.output_dir,...
    study_info.participant_info.participant_id{1}, 'eeg',...
    'final_channel_locations.mat');
load(fname);

figs=[];
for f_idx=1:length(study_info.freq_bands)
    figs(f_idx)=figure();
end
axes=[];
maxabs=[];
for f_idx=1:length(study_info.freq_bands)
    maxabs(f_idx)=-Inf;
end

for cond_idx=1:length(study_info.experimental_conditions)

    % Load all data in a matrix freq x time x channel x subjects
    tf_all_data=[];
    %% Loop through all subjects
    for s=1:size(study_info.participant_info,1)
    
        % Get subject ID from study info
        subject=study_info.participant_info.participant_id{s};
    
        % If subject not excluded
        if find(strcmp(included, subject))
            % Where to put processed (derived) data
            subject_output_data_dir=fullfile(study_info.output_dir, subject, 'eeg');
            tf_output_dir=fullfile(subject_output_data_dir, 'tf');
            fname = fullfile(tf_output_dir, sprintf('%s_timefreqs_%s_%s.mat', subject, study_info.baseline_normalize, study_info.experimental_conditions{cond_idx}));
            if exist(fname,'file')==2
                load(fname);
                tf_all_data(:, :, :, end+1)=timefreqs_data;
                clear timefreqs_data;
            end
        end
    end
    
    for f_idx=1:length(study_info.freq_bands)
        figure(figs(f_idx));
        foi=study_info.freq_bands(f_idx).foi;
        freq_idx=intersect(find(frequency>=foi(1)), find(frequency<=foi(2)));
        for t_idx=1:size(time_windows,1)
            woi=time_windows(t_idx,:);
            time_idx=intersect(find(time>=woi(1)), find(time<=woi(2)));
            mean_tf=squeeze(mean(mean(mean(tf_all_data(freq_idx,time_idx,:,:),1), 2),4));
            maxabs(f_idx)=max([maxabs(f_idx) max(abs(mean_tf(:)))]);
            axes(f_idx,t_idx)=subplot(length(study_info.experimental_conditions),size(time_windows,1),(cond_idx-1)*size(time_windows,1)+t_idx);
            topoplot(mean_tf,channel_location,'plotrad',.6,'numcontour',0,'electrodes','off');
            title(sprintf('%s - %d-%dHz: %d-%dms', study_info.experimental_conditions{cond_idx},...
                foi(1), foi(2), woi(1), woi(2)));
        end
    end
end
for f_idx=1:length(study_info.freq_bands)
    for t_idx=1:size(time_windows,1)
        set(axes(f_idx,t_idx),'clim',[-maxabs(f_idx) maxabs(f_idx)]);
    end        
end
for f_idx=1:length(study_info.freq_bands)  
    figs(f_idx);
    axes(f_idx,size(time_windows,1));
    originalSize = get(gca, 'Position');
    colorbar();
    set(gca, 'Position', originalSize);
end

for f_idx=1:length(study_info.freq_bands)
    saveas(figs(f_idx), fullfile(study_info.output_dir, 'figures', sprintf('Scalp_Topo_%s.png',study_info.freq_bands(f_idx).name))); 
    saveas(figs(f_idx), fullfile(study_info.output_dir, 'figures', sprintf('Scalp_Topo_%s.eps',study_info.freq_bands(f_idx).name)),'epsc');
end
