function time_frequency_all(study_info)

time_frequency_analysis(study_info);

time_frequency_cluster_analysis(study_info);

compute_timefreqs_significance(study_info);

compute_timefreqs_significance_btw_conditions(study_info);

compute_absolute_relative_power(study_info);

compute_cluster_absolute_relative_power(study_info);

export_erd_data(study_info, study_info.erdplot_woi);

plot_scalp_topo_time_range(study_info, study_info.topoplot_woi);

plot_time_frequency(study_info);

plot_time_frequency_significance(study_info);

plot_scalp_array_time_frequency(study_info);

plot_erds(study_info, study_info.erdplot_woi);