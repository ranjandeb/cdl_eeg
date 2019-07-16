function compute_timefreqs_significance(study_info)

out_dir=fullfile(study_info.output_dir, 'tf');

for cond = 1:length(study_info.experimental_conditions)
    
    for clus_idx=1:length(study_info.clusters)

        fname=fullfile(out_dir, sprintf('time_freqs_%s_%s_%s.mat', study_info.baseline_normalize, study_info.experimental_conditions{cond}, study_info.clusters(clus_idx).name));
        load(fname)
    
        % Change zeros(size(tf_data)if you want to test against another
        % condition
        tf_pvals = std_stat({ timefreqs_data zeros(size(timefreqs_data)) }', 'paired', {'on'}, 'method', 'permutation', 'naccu', 1000, 'condstats', 'on', 'correctm', 'fdr');
        tf_signif = mean(timefreqs_data,3);
        tf_signif(tf_pvals{1} > 0.05) = 0;

   
        out_fname=fullfile(out_dir, sprintf('time_freqs_significance_%s_%s_%s.mat', study_info.baseline_normalize, study_info.experimental_conditions{cond}, study_info.clusters(clus_idx).name));
        save(out_fname, 'tf_signif', 'tf_pvals', 'time', 'frequency');        
    end
end
