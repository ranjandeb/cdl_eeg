

% % Specify the location of data
Data_Location = Flex_TFR_Clustered_Data;

% % Make location of data current directory
cd(Data_Location)

%% Initialize all variables
% Condition name
Condition_Name = condition_label;

% Number of channels
channels = {'F3','F4','C3','C4', 'P3', 'P4', 'O1', 'O2'};


% Frequency window
freq_windows = mu_freq_windows;

% Initialize time and frequency index
Time_Idx  = zeros(size(time_windows));
Freqs_Idx = zeros(size (freq_windows));

%% Load all data in a matrix condition x channel x freq x time x subjects
for cond=1:length(Condition_Name)
for chan=1:length(channels)
    data_condition = Condition_Name{cond};
    data_channel   = channels{chan};
    
    data_file = [data_condition, '_tf_', data_channel, '.mat'];
    load(data_file);
    
    % initialize matrices on 1st subject
    if cond==1 && chan==1
        tf_all = zeros([ length(Condition_Name) length(channels) size(tf_data) ]); % list more variables here as applicable...
    end
    tf_all(cond,chan,:,:,:) = tf_data;
end
end

%% Find indecies of the time and frequency
for i=1:size(time_windows,1)
    for j=1:2
        [~,Time_Idx(i,j)] = min(abs(time-time_windows(i,j)));
    end
end

for i=1:size(freq_windows,1)
    for j=1:2
        [~,Freqs_Idx(i,j)] = min(abs(frequency-freq_windows(i,j)));
    end
end

%% Write data
% cd(TFR_Data)
% sub=dir('*TimeFreqs.mat');
sub_list=subject_list;
cd(Export_data)

% pointer to text file
fid1=fopen(textfile,'w');

for subno=0:size(tf_all, 5)
    % Write out column variable name or subject number.
    if subno==0
        fprintf(fid1,'subnum\t');
    else
        sub_num=regexp(sub_list{subno},'\d*','Match');
        sub_num=cell2mat(sub_num);
        sub_num=str2num(sub_num);
        fprintf(fid1,'%g\t',sub_num);
    end
    for con=1:length(Condition_Name)
    for chan=1:length(channels)
        for ti=1:size(time_windows,1)
            for fi=1:size(freq_windows,1)
                if subno==0
                    fprintf(fid1,[ channels{chan} '_' Condition_Name{con} '_t' num2str(time_windows(ti,1)) num2str(time_windows(ti,2)) '_f' num2str(freq_windows(fi,1)) num2str(freq_windows(fi,2)) '\t']);
                else
                    fprintf(fid1,'%g\t', (mean(mean(tf_all(con, chan, Freqs_Idx(fi,1):Freqs_Idx(fi,2),Time_Idx(ti,1):Time_Idx(ti,2),subno),3),4)));
                end
            end
        end
    end
    end
    fprintf(fid1,'\n');
end
