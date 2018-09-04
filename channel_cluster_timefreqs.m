%% Perform time frequency calculation
clear
clc;

%% Locations
data_location      = TFR_Data;
save_data_location = TFR_Clustered_Data;

%% Load channel location
load('E:\PTS_study_VS\Visit1\Scripts\channel104_location.mat')

%% Condition name
condition_name = {'1' '2' '3'};

%% List the group of channels
F3 = {'E19', 'E20', 'E23', 'E24', 'E27', 'E28'}; 
F4 = {'E3', 'E4', 'E117', 'E118', 'E123', 'E124'};

C3 = {'E29', 'E30', 'E35', 'E36', 'E37', 'E41', 'E42'};
C4 = {'E87', 'E93', 'E103', 'E104', 'E105', 'E110', 'E111'};

P3 = {'E47', 'E51', 'E52', 'E53', 'E59', 'E60'};
P4 = {'E85', 'E86', 'E91', 'E92', 'E97', 'E98'};

O1 = {'E66', 'E69', 'E70', 'E71', 'E74'};
O2 = {'E76', 'E82', 'E83', 'E84', 'E89'};

%% Find indices of the channels
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

for cond = 1:length(condition_name)
    %% Subject list
    subnum=dir([data_location '*' 'tf_data_' condition_name{cond} '*']);
    sub_list={subnum.name};
    for i =1:length(sub_list)
        sub = sub_list{i};
        subject_list{i}= sub(1:4);
    end
    
    %% Load all data in a matrix freq x time x channel x subjects
    tf_all = [];
    for sub = 1:length(subject_list)
        subject  = subject_list{sub};
        load([data_location '\' subject, '_tf_data_' int2str(1)])
        
        % initialize matrices on 1st subject
        if sub == 1
            tf_all = zeros([ size(tf_data) length(subject_list) ]);
        end
        tf_all(:,:,:,sub) = tf_data;
    end
        
    %% Make cluster
    % F3 & F4
    tf_F3 = []; tf_F4 = [];
    for i=1:length(F3)
        tf_F3   (:,:,i,:)   =   tf_all(:,:,F3_idx(i),:);
        tf_F4   (:,:,i,:)   =   tf_all(:,:,F4_idx(i),:);
    end
    
    chan_tf_power = [];
    chan_tf_power = squeeze(mean(tf_F3, 3));
    save_name = [save_data_location condition_name{cond}, '_tf_power_F3'];
    save (save_name, 'chan_tf_power', 'time', 'frequency');
    
    chan_tf_power = [];
    chan_tf_power = squeeze(mean(tf_F4, 3));
    save_name = [save_data_location condition_name{cond}, '_tf_power_F4'];
    save (save_name, 'chan_tf_power', 'time', 'frequency');
    
    %% C3, C4
    tf_C3 = []; tf_C4 = [];
    for i=1:length(C3)
        tf_C3   (:,:,i,:)   =   tf_all(:,:,C3_idx(i),:);
        tf_C4   (:,:,i,:)   =   tf_all(:,:,C4_idx(i),:);
    end
    
    chan_tf_power = [];
    chan_tf_power = squeeze(mean(tf_C3, 3));
    save_name = [save_data_location condition_name{cond}, '_tf_power_C3'];
    save (save_name, 'chan_tf_power', 'time', 'frequency');
    
    chan_tf_power = [];
    chan_tf_power = squeeze(mean(tf_C4, 3));
    save_name = [save_data_location condition_name{cond}, '_tf_power_C4'];
    save (save_name, 'chan_tf_power', 'time', 'frequency');
    
%% P3 & P4
    tf_P3 = []; tf_P4 = [];
    for i=1:length(P3)     
        tf_P3   (:,:,i,:)   =   tf_all(:,:,P3_idx(i),:);
        tf_P4   (:,:,i,:)   =   tf_all(:,:,P4_idx(i),:);
    end    
    chan_tf_power = [];
    chan_tf_power = squeeze(mean(tf_P3, 3));
    save_name = [save_data_location condition_name{cond}, '_tf_power_P3'];
    save (save_name, 'chan_tf_power', 'time', 'frequency');
    
    chan_tf_power = [];
    chan_tf_power = squeeze(mean(tf_P4, 3));
    save_name = [save_data_location condition_name{cond}, '_tf_power_P4'];
    save (save_name, 'chan_tf_power', 'time', 'frequency');
    
    %% O1 & O2
    tf_O1 = []; tf_O2 =[];
    tf_O1   (:,:,:)   =   tf_all(:,:,O1_idx,:);
    tf_O2   (:,:,:)   =   tf_all(:,:,O2_idx,:);
    
    chan_tf_power = [];
    chan_tf_power = squeeze(mean(tf_O1, 3));
    save_name = [save_data_location condition_name{cond}, '_tf_power_O1'];
    save (save_name, 'chan_tf_power', 'time', 'frequency');
    
    chan_tf_power = [];
    chan_tf_power = squeeze(mean(tf_O2, 3));
    save_name = [save_data_location condition_name{cond}, '_tf_power_O2'];
    save (save_name, 'chan_tf_power', 'time', 'frequency');
    
end