

% Make the folder that contains all the scripts current directory
% cd 'Z:\Dropboxes\vcsalo\Pointing to Success\Preprocessing\'

%% Initialize all variables that are specific to this site and project

%change locations below depending on the type of TF analysis run
% Data location
data_location = Flex_TFR_Data;
save_data_location = Flex_TFR_Clustered_Data;

% List the group of channels
F3 = {'E19', 'E20', 'E23', 'E24', 'E27', 'E28'}; 
F4 = {'E3', 'E4', 'E117', 'E118', 'E123', 'E124'};

C3 = {'E29', 'E30', 'E35', 'E36', 'E37', 'E41', 'E42'};
C4 = {'E87', 'E93', 'E103', 'E104', 'E105', 'E110', 'E111'};

P3 = {'E47', 'E51', 'E52', 'E53', 'E59', 'E60'};
P4 = {'E85', 'E86', 'E91', 'E92', 'E97', 'E98'};

O1 = {'E66', 'E69', 'E70', 'E71', 'E74'};
O2 = {'E76', 'E82', 'E83', 'E84', 'E89'};

% Find indices of the channels
for i=1:length(F3)
F3_idx (i)= find(strcmp({channel_location.labels}, F3{i}));
F4_idx (i)= find(strcmp({channel_location.labels}, F4{i}));

P3_idx (i)= find(strcmp({channel_location.labels}, P3{i}));
P4_idx (i)= find(strcmp({channel_location.labels}, P4{i}));
end

for i=1:length(C3)
C3_idx (i)= find(strcmp({channel_location.labels}, C3{i}));
C4_idx (i)= find(strcmp({channel_location.labels}, C4{i}));
end

for i=1:length(O1)
O1_idx (i)= find(strcmp({channel_location.labels}, O1{i}));
O2_idx (i)= find(strcmp({channel_location.labels}, O2{i}));
end

%% If you have more or less than 2 conditions, add/remove lines 58-67 
% Load all data for condition 1 in a matrix freq x time x channel x subjects
% for sub = 1:length(subject_list)
%     subject  = subject_list{sub};
%     load([data_location '\' subject, '_timefreqs_' conditions{1}])
%     
%     % initialize matrices on 1st subject
%     if sub == 1
%         tf_all_obg = zeros([size(timefreqs_data) length(subject_list)]);
%     end
%     tf_all_obg(:,:,:,sub) = timefreqs_data;
%     clear timefreqs_data
% end

% Load all data for condition 2 in a matrix freq x time x channel x subjects
% for sub = 1:length(subject_list)
%     subject  = subject_list{sub};
%     load([data_location '\'  subject, '_timefreqs_' conditions{2}])
%     
%     % initialize matrices on 1st subject
%     if sub == 1
%         tf_all_obp = zeros([size(timefreqs_data) length(subject_list)]);
%     end
%     tf_all_obp(:,:,:,sub) = timefreqs_data;
%      clear timefreqs_data
% end

%Load all data for condition 3 in a matrix freq x time x channel x subjects
for sub = 1:length(subject_list)
    subject  = subject_list{sub};
    load([data_location '\' subject, '_timefreqs_' conditions{3}])
    
    % initialize matrices on 1st subject
    if sub == 1
        tf_all_exe = zeros([size(timefreqs_data) length(subject_list)]);
    end
    tf_all_exe(:,:,:,sub) = timefreqs_data;
     clear timefreqs_data
end

%% If you have more or less than 2 conditions, add/remove lines 96-164 
%% Observe Grasp condition

% Make cluster
% for i=1:length(F3)
% obsgrsp_tf_F3   (:,:,i,:)   =   tf_all_obg(:,:,F3_idx(i),:); 
% obsgrsp_tf_F4   (:,:,i,:)   =   tf_all_obg(:,:,F4_idx(i),:);
%     
% obsgrsp_tf_P3   (:,:,i,:)   =   tf_all_obg(:,:,P3_idx(i),:); 
% obsgrsp_tf_P4   (:,:,i,:)   =   tf_all_obg(:,:,P4_idx(i),:); 
% end
% 
% for i=1:length(C3)
% obsgrsp_tf_C3   (:,:,i,:)   =   tf_all_obg(:,:,C3_idx(i),:); 
% obsgrsp_C4   (:,:,i,:)   =   tf_all_obg(:,:,C4_idx(i),:);
% end
% 
% for i=1:length(O1)
% obsgrsp_tf_O1   (:,:,i,:)   =   tf_all_obg(:,:,O1_idx(i),:); 
% obsgrsp_tf_O2   (:,:,i,:)   =   tf_all_obg(:,:,O2_idx(i),:);
% end
% 
% Save data
% cd(save_data_location)
% 
% tf_data = [];
% mean_tf_data = [];
% tf_data = squeeze(mean(obsgrsp_tf_F3, 3));
% mean_tf_data = squeeze(mean(mean(obsgrsp_tf_F3, 3), 4));
% save ([save_data_location 'obsgrsp_tf_F3'], 'tf_data', 'mean_tf_data', 'time', 'frequency');
% 
% tf_data = [];
% mean_tf_data = [];
% tf_data = squeeze(mean(obsgrsp_tf_F4, 3));
% mean_tf_data = squeeze(mean(mean(obsgrsp_tf_F4, 3), 4));
% save ([save_data_location 'obsgrsp_tf_F4'], 'tf_data', 'mean_tf_data', 'time', 'frequency');
% 
% tf_data = [];
% mean_tf_data = [];
% tf_data = squeeze(mean(obsgrsp_tf_C3, 3));
% mean_tf_data = squeeze(mean(mean(obsgrsp_tf_C3, 3), 4));
% save ([save_data_location 'obsgrsp_tf_C3'], 'tf_data', 'mean_tf_data', 'time', 'frequency');
% 
% tf_data = [];
% mean_tf_data = [];
% tf_data = squeeze(mean(obsgrsp_C4, 3));
% mean_tf_data = squeeze(mean(mean(obsgrsp_C4, 3), 4));
% save ([save_data_location 'obsgrsp_tf_C4'], 'tf_data', 'mean_tf_data', 'time', 'frequency');
% 
% tf_data = [];
% mean_tf_data = [];
% tf_data = squeeze(mean(obsgrsp_tf_P3, 3));
% mean_tf_data = squeeze(mean(mean(obsgrsp_tf_P3, 3), 4));
% save ([save_data_location 'obsgrsp_tf_P3'], 'tf_data', 'mean_tf_data', 'time', 'frequency');
% 
% tf_data = [];
% mean_tf_data = [];
% tf_data = squeeze(mean(obsgrsp_tf_P4, 3));
% mean_tf_data = squeeze(mean(mean(obsgrsp_tf_P4, 3), 4));
% save ([save_data_location 'obsgrsp_tf_P4'], 'tf_data', 'mean_tf_data', 'time', 'frequency');
% 
% tf_data = [];
% mean_tf_data = [];
% tf_data = squeeze(mean(obsgrsp_tf_O1, 3));
% mean_tf_data = squeeze(mean(mean(obsgrsp_tf_O1, 3), 4));
% save ([save_data_location 'obsgrsp_tf_O1'], 'tf_data', 'mean_tf_data', 'time', 'frequency');
% 
% tf_data = [];
% mean_tf_data = [];
% tf_data = squeeze(mean(obsgrsp_tf_O2, 3));
% mean_tf_data = squeeze(mean(mean(obsgrsp_tf_O2, 3), 4));
% save ([save_data_location 'obsgrsp_tf_O2'], 'tf_data', 'mean_tf_data', 'time', 'frequency');


%% Observe Point Condition
% Make cluster
% for i=1:length(F3)
% obspnt_tf_F3   (:,:,i,:)   =   tf_all_obp(:,:,F3_idx(i),:); 
% obspnt_tf_F4   (:,:,i,:)   =   tf_all_obp(:,:,F4_idx(i),:);
%     
% obspnt_tf_P3   (:,:,i,:)   =   tf_all_obp(:,:,P3_idx(i),:); 
% obspnt_tf_P4   (:,:,i,:)   =   tf_all_obp(:,:,P4_idx(i),:); 
% end
% 
% for i=1:length(C3)
% obspnt_tf_C3   (:,:,i,:)   =   tf_all_obp(:,:,C3_idx(i),:); 
% obspnt_tf_C4   (:,:,i,:)   =   tf_all_obp(:,:,C4_idx(i),:);
% end
% 
% for i=1:length(O1)
% obspnt_tf_O1   (:,:,i,:)   =   tf_all_obp(:,:,O1_idx(i),:); 
% obspnt_tf_O2   (:,:,i,:)   =   tf_all_obp(:,:,O2_idx(i),:);
% end
% 
% % Save data
% % cd(save_data_location)
% 
% tf_data = [];
% mean_tf_data = [];
% tf_data = squeeze(mean(obspnt_tf_F3, 3));
% mean_tf_data = squeeze(mean(mean(obspnt_tf_F3, 3), 4));
% save ([save_data_location 'obspnt_tf_F3'], 'tf_data', 'mean_tf_data', 'time', 'frequency');
% 
% tf_data = [];
% mean_tf_data = [];
% tf_data = squeeze(mean(obspnt_tf_F4, 3));
% mean_tf_data = squeeze(mean(mean(obspnt_tf_F4, 3), 4));
% save ([save_data_location 'obspnt_tf_F4'], 'tf_data', 'mean_tf_data', 'time', 'frequency');
% 
% tf_data = [];
% mean_tf_data = [];
% tf_data = squeeze(mean(obspnt_tf_C3, 3));
% mean_tf_data = squeeze(mean(mean(obspnt_tf_C3, 3), 4));
% save ([save_data_location 'obspnt_tf_C3'], 'tf_data', 'mean_tf_data', 'time', 'frequency');
% 
% tf_data = [];
% mean_tf_data = [];
% tf_data = squeeze(mean(obspnt_tf_C4, 3));
% mean_tf_data = squeeze(mean(mean(obspnt_tf_C4, 3), 4));
% save ([save_data_location 'obspnt_tf_C4'], 'tf_data', 'mean_tf_data', 'time', 'frequency');
% 
% tf_data = [];
% mean_tf_data = [];
% tf_data = squeeze(mean(obspnt_tf_P3, 3));
% mean_tf_data = squeeze(mean(mean(obspnt_tf_P3, 3), 4));
% save ([save_data_location 'obspnt_tf_P3'], 'tf_data', 'mean_tf_data', 'time', 'frequency');
% 
% tf_data = [];
% mean_tf_data = [];
% tf_data = squeeze(mean(obspnt_tf_P4, 3));
% mean_tf_data = squeeze(mean(mean(obspnt_tf_P4, 3), 4));
% save ([save_data_location 'obspnt_tf_P4'], 'tf_data', 'mean_tf_data', 'time', 'frequency');
% 
% tf_data = [];
% mean_tf_data = [];
% tf_data = squeeze(mean(obspnt_tf_O1, 3));
% mean_tf_data = squeeze(mean(mean(obspnt_tf_O1, 3), 4));
% save ([save_data_location 'obspnt_tf_O1'], 'tf_data', 'mean_tf_data', 'time', 'frequency');
% 
% tf_data = [];
% mean_tf_data = [];
% tf_data = squeeze(mean(obspnt_tf_O2, 3));
% mean_tf_data = squeeze(mean(mean(obspnt_tf_O2, 3), 4));
% save ([save_data_location 'obspnt_tf_O2'], 'tf_data', 'mean_tf_data', 'time', 'frequency');

%% Execute Grasp condition

% Make cluster
for i=1:length(F3)
exegrsp_tf_F3   (:,:,i,:)   =   tf_all_exe(:,:,F3_idx(i),:); 
exegrsp_tf_F4   (:,:,i,:)   =   tf_all_exe(:,:,F4_idx(i),:);
    
exegrsp_tf_P3   (:,:,i,:)   =   tf_all_exe(:,:,P3_idx(i),:); 
exegrsp_tf_P4   (:,:,i,:)   =   tf_all_exe(:,:,P4_idx(i),:); 
end

for i=1:length(C3)
exegrsp_tf_C3   (:,:,i,:)   =   tf_all_exe(:,:,C3_idx(i),:); 
exegrsp_tf_C4   (:,:,i,:)   =   tf_all_exe(:,:,C4_idx(i),:);
end

for i=1:length(O1)
exegrsp_tf_O1   (:,:,i,:)   =   tf_all_exe(:,:,O1_idx(i),:); 
exegrsp_tf_O2   (:,:,i,:)   =   tf_all_exe(:,:,O2_idx(i),:);
end

% Save data
cd(save_data_location)

tf_data = [];
mean_tf_data = [];
tf_data = squeeze(mean(exegrsp_tf_F3, 3));
mean_tf_data = squeeze(mean(mean(exegrsp_tf_F3, 3), 4));
save ([save_data_location 'exegrsp_tf_F3'], 'tf_data', 'mean_tf_data', 'time', 'frequency');

tf_data = [];
mean_tf_data = [];
tf_data = squeeze(mean(exegrsp_tf_F4, 3));
mean_tf_data = squeeze(mean(mean(exegrsp_tf_F4, 3), 4));
save ([save_data_location 'exegrsp_tf_F4'], 'tf_data', 'mean_tf_data', 'time', 'frequency');

tf_data = [];
mean_tf_data = [];
tf_data = squeeze(mean(exegrsp_tf_C3, 3));
mean_tf_data = squeeze(mean(mean(exegrsp_tf_C3, 3), 4));
save ([save_data_location 'exegrsp_tf_C3'], 'tf_data', 'mean_tf_data', 'time', 'frequency');

tf_data = [];
mean_tf_data = [];
tf_data = squeeze(mean(exegrsp_tf_C4, 3));
mean_tf_data = squeeze(mean(mean(exegrsp_tf_C4, 3), 4));
save ([save_data_location 'exegrsp_tf_C4'], 'tf_data', 'mean_tf_data', 'time', 'frequency');

tf_data = [];
mean_tf_data = [];
tf_data = squeeze(mean(exegrsp_tf_P3, 3));
mean_tf_data = squeeze(mean(mean(exegrsp_tf_P3, 3), 4));
save ([save_data_location 'exegrsp_tf_P3'], 'tf_data', 'mean_tf_data', 'time', 'frequency');

tf_data = [];
mean_tf_data = [];
tf_data = squeeze(mean(exegrsp_tf_P4, 3));
mean_tf_data = squeeze(mean(mean(exegrsp_tf_P4, 3), 4));
save ([save_data_location 'exegrsp_tf_P4'], 'tf_data', 'mean_tf_data', 'time', 'frequency');

tf_data = [];
mean_tf_data = [];
tf_data = squeeze(mean(exegrsp_tf_O1, 3));
mean_tf_data = squeeze(mean(mean(exegrsp_tf_O1, 3), 4));
save ([save_data_location 'exegrsp_tf_O1'], 'tf_data', 'mean_tf_data', 'time', 'frequency');

tf_data = [];
mean_tf_data = [];
tf_data = squeeze(mean(exegrsp_tf_O2, 3));
mean_tf_data = squeeze(mean(mean(exegrsp_tf_O2, 3), 4));
save ([save_data_location 'exegrsp_tf_O2'], 'tf_data', 'mean_tf_data', 'time', 'frequency');

