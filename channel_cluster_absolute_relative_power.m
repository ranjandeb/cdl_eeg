%% Make cluster of channels
clear;
clc;

%%
data_location = 'D:\BEIP_16yrs_rest\new data july2018\power_data\';
save_data = 'D:\BEIP_16yrs_rest\new data july2018\channel_cluster_new\';

%% Load channel location
load('D:\BEIP_16yrs_rest\Scripts\Preprocessing\channel64_location.mat')

%% Condition name
condition_name = {'eyes_closed', 'eyes_open'};
power = {'abs', 'rel'};
freqs = {'theta', 'alpha1', 'alpha2', 'beta1', 'beta2'};

%% List the group of channels
F3= {'E9', 'E11', 'E12', 'E13', 'E14'};
F4= {'E2', 'E3', 'E57', 'E59', 'E60'};
C3= {'E16', 'E20', 'E21', 'E22'};
C4= {'E41', 'E49', 'E50', 'E51'};
P3= {'E26', 'E27', 'E28', 'E31'};
P4= {'E40', 'E42', 'E45', 'E46'};
O1= {'E35'};
O2= {'E39'};

%% Find indices of the channels
for i=1:length(F3)
    F3_idx (i)= find(strcmp({channel64_location.labels}, F3{i}));
    F4_idx (i)= find(strcmp({channel64_location.labels}, F4{i}));
end

for i=1:length(C3)
    C3_idx (i)= find(strcmp({channel64_location.labels}, C3{i}));
    C4_idx (i)= find(strcmp({channel64_location.labels}, C4{i}));
    
    P3_idx (i)= find(strcmp({channel64_location.labels}, P3{i}));
    P4_idx (i)= find(strcmp({channel64_location.labels}, P4{i}));
end

O1_idx = find(strcmp({channel64_location.labels}, O1));
O2_idx = find(strcmp({channel64_location.labels}, O2));

    %% Subject list
    subject_list =[];
    subnum=dir([data_location, '*' condition_name{1} '*']);
    sub_list={subnum.name};
    for i =1:length(sub_list)
        sub = sub_list{i};
        subject_list{i}= sub(1:end-27);
    end
    subject_list=sort(str2num(char(subject_list)));
    
    %% loop through all subjects and conditions

for cond = 1:length(condition_name)

    
    %% load data
    for sub = 1:length(subject_list)
        data_file = [data_location, num2str(subject_list(sub)), '_16yr_power_', condition_name{cond}, '.mat'];
        load(data_file);
        
        data = [abs_theta, abs_alpha1, abs_alpha2, abs_beta1, abs_beta2, rel_theta, rel_alpha1, rel_alpha2, rel_beta1, rel_beta2];
        
        %% load all subject data in a matrix
        if sub == 1
            power_all = zeros([ size(data) length(subject_list)  ]);
        end
        
        power_all(:,:,sub) = data;
    end
    
    %% make cluster
    F3_power = []; F4_power = []; C3_power =[]; C4_power =[];
    P3_power = []; P4_power = []; O1_power =[]; O2_power =[];
    
    for i=1:length(F3)
        F3_power   (i,:,:)   =   power_all(F3_idx(i),:,:);
        F4_power   (i,:,:)   =   power_all(F4_idx(i),:,:);
    end
    
    for i=1:length(C3)
        C3_power   (i,:,:)   =   power_all(C3_idx(i),:,:);
        C4_power   (i,:,:)   =   power_all(C4_idx(i),:,:);
        P3_power   (i,:,:)   =   power_all(P3_idx(i),:,:);
        P4_power   (i,:,:)   =   power_all(P4_idx(i),:,:);
    end
    
    O1_power   (i,:,:)   =   power_all(O1_idx,:,:);
    O2_power   (i,:,:)   =   power_all(O2_idx,:,:);
    
    %% save data
    
    chan_power = [];
    chan_power = squeeze(mean(F3_power, 1));
    save_name = [save_data condition_name{cond}, '_F3_power'];
    save (save_name, 'chan_power', 'frequency');
    
    chan_power = [];
    chan_power = squeeze(mean(F4_power, 1));
    save_name = [save_data condition_name{cond}, '_F4_power'];
    save (save_name, 'chan_power', 'frequency');
    
    chan_power = [];
    chan_power = squeeze(mean(C3_power, 1));
    save_name = [save_data condition_name{cond}, '_C3_power'];
    save (save_name, 'chan_power', 'frequency');
    
    chan_power = [];
    chan_power = squeeze(mean(C4_power, 1));
    save_name = [save_data condition_name{cond}, '_C4_power'];
    save (save_name, 'chan_power', 'frequency');
    
    chan_power = [];
    chan_power = squeeze(mean(P3_power, 1));
    save_name = [save_data condition_name{cond}, '_P3_power'];
    save (save_name, 'chan_power', 'frequency');
    
    chan_power = [];
    chan_power = squeeze(mean(P4_power, 1));
    save_name = [save_data condition_name{cond}, '_P4_power'];
    save (save_name, 'chan_power', 'frequency');
    
    chan_power = [];
    chan_power = squeeze(mean(O1_power, 1));
    save_name = [save_data condition_name{cond}, '_O1_power'];
    save (save_name, 'chan_power', 'frequency');
    
    chan_power = [];
    chan_power = squeeze(mean(O2_power, 1));
    save_name = [save_data condition_name{cond}, '_O2_power'];
    save (save_name, 'chan_power', 'frequency');
end



