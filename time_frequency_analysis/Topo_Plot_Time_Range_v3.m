%%
% Perform time frequency calculation
% Directories_Variable_Info_v3();

% open EEGLab
%eeglab;

%change locations below depending on the type of TF analysis run
% Data location
data_location = TFR_Data;

%% if more or less than two conditions add/remove (lines 10-20)

%Load all observegrasp condition data in a matrix freq x time x channel x subjects
% for sub = 1:length(subject_list_og)
%     subject  = subject_list_og{sub};
%     load([data_location '\' subject, '_tf_data_1'])
%     
%     % initialize matrices on 1st subject
%     if sub == 1
%         tf_all_obg = zeros([size(tf_data_1) length(subject_list_og)]);
%     end
%     tf_all_obg(:,:,:,sub) = tf_data_1;
%     clear timefreqs_data
% end

% Load all observe point cpmplete condition data in a matrix freq x time x channel x subjects
for sub = 1:length(subject_list)
    subject  = subject_list{sub};
    load([data_location '\' subject, '_tf_data_2'])
    
    % initialize matrices on 1st subject
    if sub == 1
        tf_all_obp = zeros([size(tf_data_2) length(subject_list)]);
    end
    tf_all_obp(:,:,:,sub) = tf_data_2;
    clear timefreqs_data
end

% Load all execute grasp condition data in a matrix freq x time x channel x subjects
% for sub = 1:length(subject_list_eg)
%     subject  = subject_list_eg{sub};
%     load([data_location subject, '_tf_data_3'])
%     
%     % initialize matrices on 1st subject
%     if sub == 1
%         tf_all_exe = zeros([size(tf_data_3) length(subject_list_eg)]);
%     end
%     tf_all_exe(:,:,:,sub) = tf_data_3;
%     clear timefreqs_data
% end
%%

% find indices corresponding to time and frequency windows
Time_Idx  = zeros(size(time_windows)); % initialize time indices
Mu_Freqs_Idx = zeros(size (mu_freq_windows)); % initialize frequency indices
Beta_Freqs_Idx = zeros(size (beta_freq_windows));
Theta_Freqs_Idx = zeros(size (theta_freq_windows));

% Find time indices
for i=1:size(time_windows,1)
    for j=1:2
        [~,Time_Idx(i,j)] = min(abs(times-time_windows(i,j)));
    end
end

% Fine frequency indices
for i=1:size(mu_freq_windows,1)
    for j=1:2
        [~,Mu_Freqs_Idx(i,j)] = min(abs(freqs-mu_freq_windows(i,j)));
    end
end

% Fine frequency indices
for i=1:size(beta_freq_windows,1)
    for j=1:2
        [~,Beta_Freqs_Idx(i,j)] = min(abs(freqs-beta_freq_windows(i,j)));
    end
end

% Fine frequency indices
for i=1:size(theta_freq_windows,1)
    for j=1:2
        [~,Theta_Freqs_Idx(i,j)] = min(abs(freqs-theta_freq_windows(i,j)));
    end
end

%% Alpha
% Plot execution and observe grasp complete conditions
figure
set(gcf,'name','Topographical maps at time-frequency range')


for ti =1:size(time_windows,1)
    for fi=1:size(mu_freq_windows,1)
%% if more or less than two conditions add/remove (lines 91-95)

%         subplot(3,4,ti)
%         % make topomap
%         topoplot(squeeze(mean(mean(mean(tf_all_obg(Mu_Freqs_Idx(fi,1):Mu_Freqs_Idx(fi,2),Time_Idx(ti,1):Time_Idx(ti,2),:,:),1), 2),4)),channel_location,'plotrad',.55,'maplimits',clim,'electrodes','off','numcontour',0);
%         title([ '(' num2str(time_windows(ti,1)) ' ' num2str(time_windows(ti,2)) 'ms; ' num2str(mu_freq_windows(1)) '-' num2str(mu_freq_windows(2)) 'Hz)' ]);
%         set(gca, 'FontName','Times New Roman', 'FontSize', 12, 'FontWeight', 'normal')
        
        subplot(1,4,ti)
        % make topomap
        topoplot(squeeze(mean(mean(mean(tf_all_obp(Mu_Freqs_Idx(fi,1):Mu_Freqs_Idx(fi,2),Time_Idx(ti,1):Time_Idx(ti,2),:,:),1), 2),4)),channel_location,'plotrad',.55,'maplimits',clim,'electrodes','off','numcontour',0);
        title([ '(' num2str(time_windows(ti,1)) ' ' num2str(time_windows(ti,2)) 'ms; ' num2str(mu_freq_windows(1)) '-' num2str(mu_freq_windows(2)) 'Hz)' ]);
        set(gca, 'FontName','Times New Roman', 'FontSize', 12, 'FontWeight', 'normal')
        
%         subplot(3,4,ti+8)
%         % make topomap
%         topoplot(squeeze(mean(mean(mean(tf_all_exe(Mu_Freqs_Idx(fi,1):Mu_Freqs_Idx(fi,2),Time_Idx(ti,1):Time_Idx(ti,2),:,:),1), 2),4)),channel_location,'plotrad',.55,'maplimits',clim,'electrodes','off','numcontour',0);
%         title([ '(' num2str(time_windows(ti,1)) ' ' num2str(time_windows(ti,2)) 'ms; ' num2str(mu_freq_windows(1)) '-' num2str(mu_freq_windows(2)) 'Hz)' ]);
%         set(gca, 'FontName','Times New Roman', 'FontSize', 12, 'FontWeight', 'normal')
        
    end
end

% hold on
cbar('vert',0, clim, 3);
% set(gca, 'FontName','Times New Roman', 'FontSize', 12, 'FontWeight', 'normal')

% %% Beta
% 
% 
% % Plot execution and observe grasp complete conditions
% figure(2)
% set(gcf,'name','Topographical maps at time-frequency range')
% 
% 
% for ti =1:size(time_windows,1)
%     for fi=1:size(beta_freq_windows,1)
% %% if more or less than two conditions add/remove (lines 127-131)
%         subplot(4,5,ti)
%         % make topomap
%         topoplot(squeeze(mean(mean(mean(tf_all_obg(Beta_Freqs_Idx(fi,1):Beta_Freqs_Idx(fi,2),Time_Idx(ti,1):Time_Idx(ti,2),:,:),1), 2),4)),channel_location,'plotrad',.55,'maplimits',clim,'electrodes','off','numcontour',0);
%         title([ '(' num2str(time_windows(ti,1)) ' ' num2str(time_windows(ti,2)) 'ms; ' num2str(beta_freq_windows(1)) '-' num2str(beta_freq_windows(2)) 'Hz)' ]);
%         set(gca, 'FontName','Times New Roman', 'FontSize', 12, 'FontWeight', 'normal')
%         
%         subplot(4,5,ti+10)
%         % make topomap
%         topoplot(squeeze(mean(mean(mean(tf_all_obp(Beta_Freqs_Idx(fi,1):Beta_Freqs_Idx(fi,2),Time_Idx(ti,1):Time_Idx(ti,2),:,:),1), 2),4)),channel_location,'plotrad',.55,'maplimits',clim,'electrodes','off','numcontour',0);
%         title([ '(' num2str(time_windows(ti,1)) ' ' num2str(time_windows(ti,2)) 'ms; ' num2str(beta_freq_windows(1)) '-' num2str(beta_freq_windows(2)) 'Hz)' ]);
%         set(gca, 'FontName','Times New Roman', 'FontSize', 12, 'FontWeight', 'normal')
%         
%         subplot(4,5,ti)
%         % make topomap
%         topoplot(squeeze(mean(mean(mean(tf_all_exe(Beta_Freqs_Idx(fi,1):Beta_Freqs_Idx(fi,2),Time_Idx(ti,1):Time_Idx(ti,2),:,:),1), 2),4)),channel_location,'plotrad',.55,'maplimits',clim,'electrodes','off','numcontour',0);
%         title([ '(' num2str(time_windows(ti,1)) ' ' num2str(time_windows(ti,2)) 'ms; ' num2str(beta_freq_windows(1)) '-' num2str(beta_freq_windows(2)) 'Hz)' ]);
%         set(gca, 'FontName','Times New Roman', 'FontSize', 12, 'FontWeight', 'normal')
%         
%     end
% end
% 
% %% Theta
% % Plot execution and observe grasp complete conditions
% figure(3)
% set(gcf,'name','Topographical maps at time-frequency range')
% 
% 
% for ti =1:size(time_windows,1)
%     for fi=1:size(theta_freq_windows,1)
% %% if more or less than two conditions add/remove (lines 157-161)
%         subplot(4,5,ti)
%         % make topomap
%         topoplot(squeeze(mean(mean(mean(tf_all_obg(Theta_Freqs_Idx(fi,1):Theta_Freqs_Idx(fi,2),Time_Idx(ti,1):Time_Idx(ti,2),:,:),1), 2),4)),channel_location,'plotrad',.55,'maplimits',clim,'electrodes','off','numcontour',0);
%         title([ '(' num2str(time_windows(ti,1)) ' ' num2str(time_windows(ti,2)) 'ms; ' num2str(theta_freq_windows(1)) '-' num2str(theta_freq_windows(2)) 'Hz)' ]);
%         set(gca, 'FontName','Times New Roman', 'FontSize', 12, 'FontWeight', 'normal')
%         
%         subplot(4,5,ti+10)
%         % make topomap
%         topoplot(squeeze(mean(mean(mean(tf_all_obp(Theta_Freqs_Idx(fi,1):Theta_Freqs_Idx(fi,2),Time_Idx(ti,1):Time_Idx(ti,2),:,:),1), 2),4)),channel_location,'plotrad',.55,'maplimits',clim,'electrodes','off','numcontour',0);
%         title([ '(' num2str(time_windows(ti,1)) ' ' num2str(time_windows(ti,2)) 'ms; ' num2str(theta_freq_windows(1)) '-' num2str(theta_freq_windows(2)) 'Hz)' ]);
%         set(gca, 'FontName','Times New Roman', 'FontSize', 12, 'FontWeight', 'normal')
%         
%         subplot(4,5,ti+10)
%         % make topomap
%         topoplot(squeeze(mean(mean(mean(tf_all_exe(Theta_Freqs_Idx(fi,1):Theta_Freqs_Idx(fi,2),Time_Idx(ti,1):Time_Idx(ti,2),:,:),1), 2),4)),channel_location,'plotrad',.55,'maplimits',clim,'electrodes','off','numcontour',0);
%         title([ '(' num2str(time_windows(ti,1)) ' ' num2str(time_windows(ti,2)) 'ms; ' num2str(theta_freq_windows(1)) '-' num2str(theta_freq_windows(2)) 'Hz)' ]);
%         set(gca, 'FontName','Times New Roman', 'FontSize', 12, 'FontWeight', 'normal')
%         
%     end
% end
