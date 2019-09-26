function plot_erds(study_info, time_windows)

all_conds_clusters_bands_pow=[];

out_dir=fullfile(study_info.output_dir, 'tf');
for cond_idx=1:length(study_info.experimental_conditions)
    for clus_idx=1:length(study_info.clusters)
        cluster_tf_name = fullfile(out_dir, sprintf('time_freqs_%s_%s_%s.mat',...
                    study_info.baseline_normalize,...
                    study_info.experimental_conditions{cond_idx},...
                    study_info.clusters(clus_idx).name));
        load(cluster_tf_name);
        for f_idx=1:length(study_info.freq_bands)
            foi=study_info.freq_bands(f_idx).foi;
            freq_idx=intersect(find(frequency>=foi(1)),find(frequency<=foi(2)));
            for t_idx=1:size(time_windows,1)
                woi=time_windows(t_idx,:);
                time_idx=intersect(find(time>=woi(1)), find(time<=woi(2)));
                clus_pow=squeeze(mean(mean(timefreqs_data(freq_idx,time_idx,:),2),1));                
                all_conds_clusters_bands_pow(t_idx,f_idx,cond_idx,clus_idx,:)=clus_pow;
            end
        end
        
    end
end

for f_idx=1:length(study_info.freq_bands)
    freq_band=study_info.freq_bands(f_idx).name;
    for t_idx=1:size(time_windows,1)
        woi=time_windows(t_idx,:);
        foi_woi_pow=squeeze(all_conds_clusters_bands_pow(t_idx,f_idx,:,:,:));
        fig=figure();
        mean_pow=squeeze(mean(foi_woi_pow,3));
        stderr_pow=squeeze(std(foi_woi_pow,[],3))./sqrt(size(foi_woi_pow,3));
        barwitherr(stderr_pow', mean_pow');
        set(gca,'xticklabel',flip({study_info.clusters.name}));
        xlabel('\Delta Power (dB)');
        title(sprintf('%s - %d-%dms', study_info.freq_bands(f_idx).name, woi(1), woi(2)));
        legend(study_info.experimental_conditions);                                
        
        saveas(fig, fullfile(study_info.output_dir, 'figures', sprintf('ERD_%s_%d-%dms.png',freq_band,woi(1),woi(2)))); 
        saveas(fig, fullfile(study_info.output_dir, 'figures', sprintf('ERD_%s_%d-%dms.eps',freq_band,woi(1),woi(2))),'epsc');
    end
end
