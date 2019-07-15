      
        
% Data location
data_location = Flex_TFR_Clustered_Data;
save_data_location = Flex_TFR_Clustered_Data;

%data_location = ('E:\PTS_study_VS\Visit1\6.11.18 tf data 1000_1000segment\Time_Frequency_Data\Clustered\');
%save_data_location = ('E:\PTS_study_VS\Visit1\6.11.18 tf data 1000_1000segment\Time_Frequency_Data\Clustered\');

% Condition name
Condition_Name = condition_label;

% Channel list
Channels = {'F3', 'F4', 'C3', 'C4', 'P3', 'P4', 'O1', 'O2'};

% Plot execute and observe grasp condition
figure; clf

for chan=1:length(Channels)
            
        % If you have more or less than 2 conditions, add/remove lines
        % 20-28
        data_file = [data_location Condition_Name{1} , '_tf_', Channels{chan}, '.mat'];
        load(data_file)
        
        subplot(6,4,chan)
        %tftopo(mean_tf_data, time, frequency, 'mode', 'ave', 'limits',[-1000 1000 5 15 nan nan]);
        contourf(time, frequency, mean_tf_data, 20,'linecolor','none');
        set(gca, 'ylim', freq2plot, 'xlim', time2plot, 'clim', lim_obg);
        set(gca,'FontName','Times New Roman', 'FontSize', 14);
        title([Condition_Name{1}, '-',Channels{chan}], 'Interpreter', 'none', 'FontName','Times New Roman', 'FontSize', 14, 'FontWeight', 'normal');
        
        data_file = [data_location Condition_Name{2} , '_tf_', Channels{chan}, '.mat'];
        load(data_file)
  
         subplot(6,4,chan+8)
        %tftopo(mean_tf_data, time, frequency, 'mode', 'ave', 'limits',[-1000 1000 5 15 nan nan]);
        contourf(time, frequency, mean_tf_data, 20,'linecolor','none');
        set(gca, 'ylim', freq2plot, 'xlim', time2plot, 'clim', lim_obp);
        set(gca,'FontName','Times New Roman', 'FontSize', 14);
         title([ Condition_Name{2}, '-',Channels{chan}], 'Interpreter', 'none', 'FontName','Times New Roman', 'FontSize', 14, 'FontWeight', 'normal');
         
         data_file = [data_location Condition_Name{3} , '_tf_', Channels{chan}, '.mat'];
        load(data_file)
        
        subplot(6,4,chan+16)
        %tftopo(mean_tf_data, time, frequency, 'mode', 'ave', 'limits',[-1000 1000 5 15 nan nan]);
        contourf(time, frequency, mean_tf_data, 20,'linecolor','none');
        set(gca, 'ylim', freq2plot, 'xlim', time2plot, 'clim', lim_exe);
        set(gca,'FontName','Times New Roman', 'FontSize', 14);
        title([Condition_Name{3}, '-',Channels{chan}], 'FontName','Times New Roman', 'FontSize', 14, 'FontWeight', 'normal');

                
        if chan == 1 || chan == 5 
            ylabel ('Frequency (Hz)') 
        end
        
        if  chan+8 == 9 || chan+8 == 13
            ylabel ('Frequency (Hz)')
        end
        
        if  chan+16 == 17 || chan+16 == 21
            ylabel ('Frequency (Hz)')
        end
        
        if chan+16 == 21 || chan+16 == 22
            xlabel('Time (ms)')
        
        elseif chan+16 == 23 || chan+16 == 24
            xlabel('Time (ms)')
        end
        
      
end
colormap('jet(100)');
% To create a colorbar
%cbar('vert',0, lim, 3);
%set(gca,'FontName','Times New Roman', 'FontSize', 14);
