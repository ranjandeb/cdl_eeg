function plot_time_frequency_significance(study_info)

data_dir=fullfile(study_info.output_dir, 'tf');
output_dir=fullfile(study_info.output_dir, 'figures');
if exist(output_dir,'dir')~=7
    mkdir(output_dir);
end

for clus_idx=1:length(study_info.clusters)
    
    baseline_max_abs=-Inf;
    comparison_max_abs=-Inf;
    for cond = 1:length(study_info.experimental_conditions)
        fname=fullfile(data_dir, sprintf('time_freqs_significance_%s_%s_%s.mat', study_info.baseline_normalize, study_info.experimental_conditions{cond}, study_info.clusters(clus_idx).name));
        load(fname);
        baseline_max_abs=max([baseline_max_abs max(abs(tf_signif(:)))]);
        for cond2 = cond+1:length(study_info.experimental_conditions)
            fname=fullfile(data_dir, sprintf('time_freqs_significance_%s_%s-%s_%s.mat', study_info.baseline_normalize, study_info.experimental_conditions{cond}, study_info.experimental_conditions{cond2}, study_info.clusters(clus_idx).name));
            load(fname);
            comparison_max_abs=max([comparison_max_abs max(abs(tf_signif(:)))]);
        end
    end
    baseline_clim=[-baseline_max_abs baseline_max_abs];
    comparison_clim=[-comparison_max_abs comparison_max_abs];

    n_conditions=length(study_info.experimental_conditions);
    
    fig=figure();
    for cond = 1:n_conditions
        subplot(n_conditions,1,cond);
        fname=fullfile(data_dir, sprintf('time_freqs_significance_%s_%s_%s.mat', study_info.baseline_normalize, study_info.experimental_conditions{cond}, study_info.clusters(clus_idx).name));
        load(fname);
        
        % tftopo(tf_signif, times, freqs, 'mode', 'ave', 'limits',[time2plot freq2plot lim]);
        contourf(time, frequency, tf_signif, 20,'linecolor','none');
        set(gca, 'ylim', study_info.freq2plot, 'xlim', study_info.time2plot, 'clim', baseline_clim);
        set(gca,'FontName','Arial', 'FontSize', 12);
        title(sprintf('%s: %s', study_info.clusters(clus_idx).name, study_info.experimental_conditions{cond}), 'FontName','Arial', 'FontSize', 14, 'FontWeight', 'normal');
        ylabel ('Frequency (Hz)')
    end
    xlabel('Time (ms)')
    cbar('vert',0, baseline_clim, 3);
    
    saveas(fig, fullfile(output_dir, sprintf('TF_signifMask_%s.png', study_info.clusters(clus_idx).name)), 'png')
    saveas(fig, fullfile(output_dir, sprintf('TF_signifMask_%s.eps', study_info.clusters(clus_idx).name)), 'epsc')
    
    fig=figure();
    for cond1=1:n_conditions
        for cond2=cond1+1:n_conditions
            subplot(n_conditions,n_conditions,(cond1-1)*n_conditions+cond2);
            fname=fullfile(data_dir, sprintf('time_freqs_significance_%s_%s-%s_%s.mat', study_info.baseline_normalize, study_info.experimental_conditions{cond1}, study_info.experimental_conditions{cond2}, study_info.clusters(clus_idx).name));
            load(fname);
            % tftopo(tf_signif, times, freqs, 'mode', 'ave', 'limits',[time2plot freq2plot lim]);
            contourf(time, frequency, tf_signif, 20,'linecolor','none');
            set(gca, 'ylim', study_info.freq2plot, 'xlim', study_info.time2plot, 'clim', comparison_clim);
            set(gca,'FontName','Arial', 'FontSize', 12);
            title(sprintf('%s: %s-%s', study_info.clusters(clus_idx).name, study_info.experimental_conditions{cond1}, study_info.experimental_conditions{cond2}), 'FontName','Arial', 'FontSize', 14, 'FontWeight', 'normal');
        end
    end
    ylabel ('Frequency (Hz)')
    xlabel('Time (ms)')
    cbar('vert',0, comparison_clim, 3);
    
    saveas(fig, fullfile(output_dir, sprintf('TF_signifMask_btw_conditions_%s.png', study_info.clusters(clus_idx).name)), 'png')
    saveas(fig, fullfile(output_dir, sprintf('TF_signifMask_btw_conditions_%s.eps', study_info.clusters(clus_idx).name)), 'epsc')
            
end


