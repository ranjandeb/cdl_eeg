function compute_timefreqs_significance_btw_conditions(study_info)

out_dir=fullfile(study_info.output_dir, 'tf');
    
for cond1 = 1:length(study_info.experimental_conditions)
    for cond2 = cond1+1:length(study_info.experimental_conditions)
        for clus_idx=1:length(study_info.clusters)
    
            fname=fullfile(out_dir, sprintf('time_freqs_%s_%s_%s.mat', study_info.baseline_normalize, study_info.experimental_conditions{cond1}, study_info.clusters(clus_idx).name));
            load(fname)
            cond1_data=timefreqs_data;
            
            fname=fullfile(out_dir, sprintf('time_freqs_%s_%s_%s.mat', study_info.baseline_normalize, study_info.experimental_conditions{cond2}, study_info.clusters(clus_idx).name));
            load(fname)
            cond2_data=timefreqs_data;
                        
            tf_pvals = std_stat({ cond1_data cond2_data }', 'paired', {'on'}, 'method', 'permutation', 'condstats', 'on', 'mcorrect', 'fdr');
            tf_signif = mean(cond1_data,3)-mean(cond2_data,3);
            tf_signif(tf_pvals{1} > 0.05) = 0;
    
            %% save data
            out_fname=fullfile(out_dir, sprintf('time_freqs_significance_%s_%s-%s_%s.mat', study_info.baseline_normalize, study_info.experimental_conditions{cond1}, study_info.experimental_conditions{cond2}, study_info.clusters(clus_idx).name));
            save (out_fname, 'tf_signif', 'tf_pvals', 'time', 'frequency');
        end
    end
        
end

