
output_fig = Figures;
data_location = Stats_data;
%data_location = ('E:\PTS_study_VS\Visit1\6.11.18 tf data 1000_1000segment\Time_Frequency_Data\StatsTest\');
data_location = ('E:\PTS_study_VS\Visit2\Time_Frequency_Data\ControlGroup\Stats_test\');

cd(data_location)

% Condition name
Condition_Name = condition_label;

% Channel list
Channels = {'F3', 'F4', 'C3', 'C4', 'P3', 'P4', 'O1', 'O2'};
% Channels = {'F3', 'F4', 'C3', 'C4'};

% Plot execute grasp condition
figure; clf

for chan=1:length(Channels)
    
    % Condition 1
    % If you have more or less than 2 conditions, add/remove lines 21-29
%     data_file = [Condition_Name{1}, '_tf_signif_', Channels{chan}, '.mat'];
%     load([data_location data_file])
%     
%     subplot(6,4,chan)
%     % tftopo(tf_signif, times, freqs, 'mode', 'ave', 'limits',[time2plot freq2plot lim]);
%     contourf(times, freqs, tf_signif, 20,'linecolor','none');
%     set(gca, 'ylim', freq2plot, 'xlim', time2plot, 'clim', lim_obg);
%     set(gca,'FontName','Times New Roman', 'FontSize', 12);
%     title([Condition_Name{1}, '-',Channels{chan}], 'FontName','Times New Roman', 'FontSize', 14, 'FontWeight', 'normal');
   
    %Condition 2
    data_file = [Condition_Name{2}, '_tf_signif_', Channels{chan}, '.mat'];
    load([data_location data_file])
    
    subplot(3,4,chan)
    % tftopo(tf_signif, times, freqs, 'mode', 'ave', 'limits',[time2plot freq2plot lim]);
    contourf(times, freqs, tf_signif, 20,'linecolor','none');
    set(gca, 'ylim', freq2plot, 'xlim', time2plot, 'clim', lim_obp);
    set(gca,'FontName','Times New Roman', 'FontSize', 12);
    title([Condition_Name{2}, '-',Channels{chan}], 'FontName','Times New Roman', 'FontSize', 14, 'FontWeight', 'normal');
    
    %Condition 3
%     data_file = [Condition_Name{3}, '_tf_signif_', Channels{chan}, '.mat'];
%     load([data_location data_file])
%     
%     subplot(6,4,chan+16)
%     % tftopo(tf_signif, times, freqs, 'mode', 'ave', 'limits',[time2plot freq2plot lim]);
%     contourf(times, freqs, tf_signif, 20,'linecolor','none');
%     set(gca, 'ylim', freq2plot, 'xlim', time2plot, 'clim', lim_obp);
%     set(gca,'FontName','Times New Roman', 'FontSize', 12);
%     title([Condition_Name{3}, '-',Channels{chan}], 'FontName','Times New Roman', 'FontSize', 14, 'FontWeight', 'normal');
%     
    if chan == 1 || chan == 5
        ylabel ('Frequency (Hz)')
    end
    
%     if  chan+8 == 9 || chan+8 == 13
%         ylabel ('Frequency (Hz)')
%     end
%     
%     if  chan+16 == 17 || chan+16 == 21
%         ylabel ('Frequency (Hz)')
%     end
%     
%     if chan+16 == 21 || chan+16 == 22
%         xlabel('Time (ms)')
%         
%     elseif chan+16 == 23 || chan+16 == 24
%         xlabel('Time (ms)')
%     end
end

colormap('jet(100)');
% cbar('vert',0, clim, 3);
% set(gca,'FontName','Times New Roman', 'FontSize', 12);

% saveas(gcf, [Figures 'TFR_signifMask'], 'png')
% saveas(gcf, [Figures 'TFR_signifMask'], 'fig')



