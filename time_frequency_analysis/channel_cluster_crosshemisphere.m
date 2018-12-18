

% Make the folder that contains all the scripts current directory
% cd 'Z:\Dropboxes\vcsalo\Pointing to Success\Preprocessing\'

%% Initialize all variables that are specific to this site and project
        
% Data location
data_location = TFR_Data;
save_data_location = TFR_Clustered_Data;

% List the group of channels
F = {'E19', 'E20', 'E23', 'E24', 'E27', 'E28', 'E3', 'E4', 'E117', 'E118', 'E123', 'E124', 'E11', 'E12', 'E6', 'E5'};

C = {'E29', 'E30', 'E35', 'E36', 'E37', 'E41', 'E42', 'E87', 'E93', 'E103', 'E104', 'E105', 'E110', 'E111', 'E7', 'E31', 'E106', 'E80', 'E55', 'E13', 'E112'};

P = {'E47', 'E51', 'E52', 'E53', 'E59', 'E60', 'E85', 'E86', 'E91', 'E92', 'E97', 'E98', 'E54', 'E79', 'E61', 'E67', 'E62', 'E72', 'E78', 'E77'};

O = {'E66', 'E69', 'E70', 'E71', 'E74', 'E76', 'E82', 'E83', 'E84', 'E89', 'E75'};

% Find indices of the channels
for i=1:length(F)
F_idx (i)= find(strcmp({channel_location.labels}, F{i}));
end

for i=1:length(P)
P_idx (i)= find(strcmp({channel_location.labels}, P{i}));
end

for i=1:length(C)
C_idx (i)= find(strcmp({channel_location.labels}, C{i}));
end

for i=1:length(O)
O_idx (i)= find(strcmp({channel_location.labels}, O{i}));
end

%% If you have more or less than 2 conditions, add/remove lines 58-67 
% Load all data for condition 1 in a matrix freq x time x channel x subjects
for sub = 1:length(subject_list)
    subject  = subject_list{sub};
    load([data_location '\' subject, '_tf_data_' int2str(1)])
    
    % initialize matrices on 1st subject
    if sub == 1
        tf_all_obg = zeros([size(tf_data_1) length(subject_list)]);
    end
    tf_all_obg(:,:,:,sub) = tf_data_1;
end

% Load all data for condition 2 in a matrix freq x time x channel x subjects
for sub = 1:length(subject_list)
    subject  = subject_list{sub};
    load([data_location '\'  subject, '_tf_data_' int2str(2)])
    
    % initialize matrices on 1st subject
    if sub == 1
        tf_all_obp = zeros([size(tf_data_2) length(subject_list)]);
    end
    tf_all_obp(:,:,:,sub) = tf_data_2;
end

% % Load all data for condition 1 in a matrix freq x time x channel x subjects
% for sub = 1:length(subject_list)
%     subject  = subject_list{sub};
%     load([data_location '\' subject, '_tf_data_' int2str(3)])
%     
%     % initialize matrices on 1st subject
%     if sub == 1
%         tf_all_exe = zeros([size(tf_data_3) length(subject_list)]);
%     end
%     tf_all_exe(:,:,:,sub) = tf_data_3;
% end

%% If you have more or less than 2 conditions, add/remove lines 96-164 
%% Observe Grasp condition

% Make cluster
for i=1:length(F)
obsgrsp_tf_F   (:,:,i,:)   =   tf_all_obg(:,:,F_idx(i),:); 
end

for i=length(P)
obsgrsp_tf_P   (:,:,i,:)   =   tf_all_obg(:,:,P_idx(i),:);  
end

for i=1:length(C)
obsgrsp_tf_C   (:,:,i,:)   =   tf_all_obg(:,:,C_idx(i),:); 
end

for i=1:length(O)
obsgrsp_tf_O   (:,:,i,:)   =   tf_all_obg(:,:,O_idx(i),:); 
end

% Save data
% cd(save_data_location)

tf_data = [];
mean_tf_data = [];
tf_data = squeeze(mean(obsgrsp_tf_F, 3));
mean_tf_data = squeeze(mean(mean(obsgrsp_tf_F, 3), 4));
save ([save_data_location 'obsgrsp_tf_F'], 'tf_data', 'mean_tf_data', 'times', 'freqs');

tf_data = [];
mean_tf_data = [];
tf_data = squeeze(mean(obsgrsp_tf_C, 3));
mean_tf_data = squeeze(mean(mean(obsgrsp_tf_C, 3), 4));
save ([save_data_location 'obsgrsp_tf_C'], 'tf_data', 'mean_tf_data', 'times', 'freqs');

tf_data = [];
mean_tf_data = [];
tf_data = squeeze(mean(obsgrsp_tf_P, 3));
mean_tf_data = squeeze(mean(mean(obsgrsp_tf_P, 3), 4));
save ([save_data_location 'obsgrsp_tf_P'], 'tf_data', 'mean_tf_data', 'times', 'freqs');

tf_data = [];
mean_tf_data = [];
tf_data = squeeze(mean(obsgrsp_tf_O, 3));
mean_tf_data = squeeze(mean(mean(obsgrsp_tf_O, 3), 4));
save ([save_data_location 'obsgrsp_tf_O'], 'tf_data', 'mean_tf_data', 'times', 'freqs');


%% Observe Point Condition
% Make cluster
for i=1:length(F)
obspnt_tf_F   (:,:,i,:)   =   tf_all_obp(:,:,F_idx(i),:); 
end

for i=1:length(P)
obspnt_tf_P   (:,:,i,:)   =   tf_all_obp(:,:,P_idx(i),:); 
end

for i=1:length(C)
obspnt_tf_C   (:,:,i,:)   =   tf_all_obp(:,:,C_idx(i),:); 
end

for i=1:length(O)
obspnt_tf_O   (:,:,i,:)   =   tf_all_obp(:,:,O_idx(i),:); 
end

% Save data
% cd(save_data_location)

tf_data = [];
mean_tf_data = [];
tf_data = squeeze(mean(obspnt_tf_F, 3));
mean_tf_data = squeeze(mean(mean(obspnt_tf_F, 3), 4));
save ([save_data_location 'obspnt_tf_F'], 'tf_data', 'mean_tf_data', 'times', 'freqs');

tf_data = [];
mean_tf_data = [];
tf_data = squeeze(mean(obspnt_tf_C, 3));
mean_tf_data = squeeze(mean(mean(obspnt_tf_C, 3), 4));
save ([save_data_location 'obspnt_tf_C'], 'tf_data', 'mean_tf_data', 'times', 'freqs');

tf_data = [];
mean_tf_data = [];
tf_data = squeeze(mean(obspnt_tf_P, 3));
mean_tf_data = squeeze(mean(mean(obspnt_tf_P, 3), 4));
save ([save_data_location 'obspnt_tf_P'], 'tf_data', 'mean_tf_data', 'times', 'freqs');

tf_data = [];
mean_tf_data = [];
tf_data = squeeze(mean(obspnt_tf_O, 3));
mean_tf_data = squeeze(mean(mean(obspnt_tf_O, 3), 4));
save ([save_data_location 'obspnt_tf_O'], 'tf_data', 'mean_tf_data', 'times', 'freqs');

%% Execute Grasp condition

% % Make cluster
% for i=1:length(F)
% exegrsp_tf_F   (:,:,i,:)   =   tf_all_exe(:,:,F_idx(i),:); 
% end
% 
% for i=1:length(P)
% exegrsp_tf_P   (:,:,i,:)   =   tf_all_exe(:,:,P_idx(i),:); 
% end
% 
% for i=1:length(C)
% exegrsp_tf_C   (:,:,i,:)   =   tf_all_exe(:,:,C_idx(i),:); 
% end
% 
% for i=1:length(O)
% exegrsp_tf_O   (:,:,i,:)   =   tf_all_exe(:,:,O_idx(i),:); 
% end

% Save data
% cd(save_data_location)

% tf_data = [];
% mean_tf_data = [];
% tf_data = squeeze(mean(exegrsp_tf_F, 3));
% mean_tf_data = squeeze(mean(mean(exegrsp_tf_F, 3), 4));
% save ([save_data_location 'exegrsp_tf_F'], 'tf_data', 'mean_tf_data', 'times', 'freqs');
% 
% tf_data = [];
% mean_tf_data = [];
% tf_data = squeeze(mean(exegrsp_tf_C, 3));
% mean_tf_data = squeeze(mean(mean(exegrsp_tf_C, 3), 4));
% save ([save_data_location 'exegrsp_tf_C'], 'tf_data', 'mean_tf_data', 'times', 'freqs');
% 
% tf_data = [];
% mean_tf_data = [];
% tf_data = squeeze(mean(exegrsp_tf_P, 3));
% mean_tf_data = squeeze(mean(mean(exegrsp_tf_P, 3), 4));
% save ([save_data_location 'exegrsp_tf_P'], 'tf_data', 'mean_tf_data', 'times', 'freqs');
% 
% tf_data = [];
% mean_tf_data = [];
% tf_data = squeeze(mean(exegrsp_tf_O, 3));
% mean_tf_data = squeeze(mean(mean(exegrsp_tf_O, 3), 4));
% save ([save_data_location 'exegrsp_tf_O'], 'tf_data', 'mean_tf_data', 'times', 'freqs');

