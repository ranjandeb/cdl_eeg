
%data_location = TFR_Clustered_Data;
%save_data_location = Stats_data;
data_location = ('E:\PTS_study_VS\Visit2\Time_Frequency_Data\ControlGroup\Clustered\');
save_data_location = ('E:\PTS_study_VS\Visit2\Time_Frequency_Data\ControlGroup\Stats_test\');

% Condition name
Condition_Name = condition_label;

% Channel list
Channels = {'F3', 'F4', 'C3', 'C4', 'P3', 'P4', 'O1', 'O2'};

%for condi=1:length(Condition_Name)
for condi=Condition_Name{2}
    
    for chan=1:length(Channels)

        %data_file = [data_location Condition_Name{condi} , '_tf_', Channels{chan}, '.mat'];
        data_file = [data_location 'obspnt', '_tf_', Channels{chan}, '.mat'];
        load(data_file)
    
        % Change zeros(size(tf_data)if you want to test against another
        % condition
        tf_data_pvals = std_stat({ tf_data zeros(size(tf_data)) }', 'method', 'permutation', 'naccu', 1000, 'condstats', 'on', 'correctm', 'fdr');
        tf_signif = mean(tf_data,3);
        tf_signif(tf_data_pvals{1} > 0.05) = 0;

   
        %save_data = [Condition_Name{condi}, '_tf_signif_', Channels{chan}, '.mat'];
        save_data = ['obspnt', '_tf_signif_', Channels{chan}, '.mat'];
        save ([save_data_location save_data], 'tf_signif', 'times', 'freqs');
        
        
    end
end
