function export_erd_data(study_info, time_windows)

out_dir=fullfile(study_info.output_dir, 'tf');

all_conds_clusters_bands_pow=[];
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

% Long format
out_fname='erd_data-long.csv';
fid=fopen(fullfile(out_dir, out_fname),'w');
fprintf(fid,'Subject,Cluster,FreqBand,WOI,Condition,ERD\n');
for s_idx=1:length(included)
    subj_id=included{s_idx};
    for clus_idx=1:length(study_info.clusters)
        cluster_name=study_info.clusters(clus_idx).name;
        for f_idx=1:length(study_info.freq_bands)
            band_name=study_info.freq_bands(f_idx).name;
            for t_idx=1:size(time_windows,1)
                woi=time_windows(t_idx,:);
                for cond_idx=1:length(study_info.experimental_conditions)
                    cond_name=study_info.experimental_conditions{cond_idx};
                    fprintf(fid,sprintf('%s,%s,%s,%d-%dms,%s,%.3f\n', subj_id,...
                        cluster_name, band_name, woi(1), woi(2), cond_name,...
                        squeeze(all_conds_clusters_bands_pow(t_idx,f_idx,cond_idx,clus_idx,s_idx))));
                end
            end
        end
    end
end
fclose(fid);

% Wide format
out_fname='erd_data-wide.csv';
fid=fopen(fullfile(out_dir, out_fname),'w');
fprintf(fid,'Subject');
for clus_idx=1:length(study_info.clusters)
    cluster_name=study_info.clusters(clus_idx).name;
    for f_idx=1:length(study_info.freq_bands)
        band_name=study_info.freq_bands(f_idx).name;
        for t_idx=1:size(time_windows,1)
            woi=time_windows(t_idx,:);
            for cond_idx=1:length(study_info.experimental_conditions)
                cond_name=study_info.experimental_conditions{cond_idx};
                fprintf(fid,sprintf(',%s_%s_%d-%dms_%s',cluster_name, band_name, woi(1), woi(2), cond_name));
            end
        end
    end
end
fprintf(fid,'\n');
for s_idx=1:length(included)
    subj_id=included{s_idx};
    fprintf(fid,subj_id);
    for clus_idx=1:length(study_info.clusters)
        for f_idx=1:length(study_info.freq_bands)
            for t_idx=1:size(time_windows,1)
                for cond_idx=1:length(study_info.experimental_conditions)
                    fprintf(fid,sprintf(',%.3f',...
                        squeeze(all_conds_clusters_bands_pow(t_idx,f_idx,cond_idx,clus_idx,s_idx))));
                end
            end
        end
    end
    fprintf(fid,'\n');
end
fclose(fid);