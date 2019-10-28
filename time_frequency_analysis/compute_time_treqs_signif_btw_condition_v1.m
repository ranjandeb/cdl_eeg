
data_location = Flex_TFR_Clustered_Data;
save_data_location = Stats_flex_data;


% Channel list
Channels = {'F3', 'F4', 'C3', 'C4', 'P3', 'P4', 'O1', 'O2'};


    
for chan=1:length(Channels)
    
    %% load 1st condition
    tf_data = [];
    data_file = [data_location condition_label{1} , '_tf_', Channels{chan}, '.mat'];
    load(data_file)
    cond1_data = tf_data;
      
    %% load 2nd condition
    tf_data = [];
    data_file = [data_location condition_label{2} , '_tf_', Channels{chan}, '.mat'];
    load(data_file)
    cond2_data = tf_data;
    
    %% Change zeros(size(tf_data)if you want to test against another
    % condition
    tf_data_pvals = std_stat({ cond1_data cond2_data }', 'method', 'permutation', 'condstats', 'on', 'mcorrect', 'fdr');
    tf_signif = mean(cond1_data,3);
    tf_signif(tf_data_pvals{1} > 0.05) = 0;
    
    %% save data
    save_data = ['compare_cond1&2_tf_signif_', Channels{chan}, '.mat'];
    save ([save_data_location save_data], 'tf_signif', 'time', 'frequency');
        
end

