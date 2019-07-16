function plot_time_frequency(study_info)

data_dir=fullfile(study_info.output_dir, 'tf');
output_dir=fullfile(study_info.output_dir, 'figures');
if exist(output_dir,'dir')~=7
    mkdir(output_dir);
end

max_abs=-Inf;

for clus_idx=1:length(study_info.clusters)
    for cond = 1:length(study_info.experimental_conditions)
        fname = fullfile(data_dir, sprintf('time_freqs_%s_%s_%s.mat', study_info.baseline_normalize, study_info.experimental_conditions{cond}, study_info.clusters(clus_idx).name));
        load(fname);
        mean_tf=mean(timefreqs_data,3);
        max_abs=max([max_abs max(abs(mean_tf(:)))]);
    end
    
end
clim=[-max_abs max_abs];

for clus_idx=1:length(study_info.clusters)
    
    n_conditions=length(study_info.experimental_conditions);
    
    fig=figure();
    for cond = 1:n_conditions
        subplot(n_conditions,1,cond);
        fname = fullfile(data_dir, sprintf('time_freqs_%s_%s_%s.mat', study_info.baseline_normalize, study_info.experimental_conditions{cond}, study_info.clusters(clus_idx).name));
        load(fname);
        
        % tftopo(tf_signif, times, freqs, 'mode', 'ave', 'limits',[time2plot freq2plot lim]);
        contourf(time, frequency, mean(timefreqs_data,3), 20,'linecolor','none');
        set(gca, 'ylim', study_info.freq2plot, 'xlim', study_info.time2plot, 'clim', clim);
        set(gca,'FontName','Arial', 'FontSize', 12);
        title(sprintf('%s: %s', study_info.clusters(clus_idx).name, study_info.experimental_conditions{cond}), 'FontName','Arial', 'FontSize', 14, 'FontWeight', 'normal');
        ylabel ('Frequency (Hz)')
    end
    xlabel('Time (ms)')
    cbar('vert',0, clim, 3);
    
    saveas(fig, fullfile(output_dir, sprintf('TF_%s.png', study_info.clusters(clus_idx).name)), 'png')
    saveas(fig, fullfile(output_dir, sprintf('TF_%s.eps', study_info.clusters(clus_idx).name)), 'epsc')
end


