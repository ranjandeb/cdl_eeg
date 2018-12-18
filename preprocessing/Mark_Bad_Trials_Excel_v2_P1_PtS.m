
cd 'E:\PTS_study_VS\Visit1\Scripts\Preprocessing\'

%% Read excel file containing trial numbers to be excluded from analysis because of interference during experiment
xls_file_location = 'E:\PTS_study_VS\Visit1\Scripts\Preprocessing\';
xls_file_name = 'PtS_Bad_Trials.xlsx';
xls_sheet = 1;
xls_rwcl = 'A2:D68';
xls_header = {'ID', 'OG', 'OP','EG'};

%% Clear temporary variables
clearvars data raw stringVectors BadTrialsList;

%% Import the data
[~, ~, raw] = xlsread(xls_file_name, xls_sheet, xls_rwcl);
stringVectors = string(raw(:,[1,2,3,4]));
stringVectors(ismissing(stringVectors)) = '';

 
%% Create table
BadTrialsList = table;

%% Allocate imported array to column variable names
BadTrialsList.ID = stringVectors(:,1);
BadTrialsList.OG = stringVectors(:,2);
BadTrialsList.OP = stringVectors(:,3);
BadTrialsList.EG = stringVectors(:,4);

%% Clear temporary variables
clearvars data raw stringVectors;

%%
% Find the index of the last event
lastevent_idx = length(EEG.event);


for j=1:length(BadTrialsList.ID)
    if strcmp(subject,BadTrialsList.ID{j})
        i=j;
    end
end

if  BadTrialsList.ID(i)== subject  % Check the subject ID from the excle file
    og_bad = BadTrialsList.OG(i); % Get execute bad trial list for the subject
    op_bad = BadTrialsList.OP(i); % Get observe bad trial list for the subject
    eg_bad = BadTrialsList.EG(i); % Get point bad trial list for the subject
else
    error('Subject ID does not match. Make sure ID in excle file and EEGLAB match.');
end

% % The excle file is read as a tabel in matlab. Table is converted into
% % number in two steps
 exe_bad = table2array(eg_bad); % Convert tabel to array 
 exe_bad = str2num(exe_bad); % Convert string to number
 grsp_bad = table2array (og_bad);
 grsp_bad = str2num(grsp_bad);
 point_bad = table2array (op_bad);
 point_bad = str2num(point_bad);
 
 %%
% Mark bad trials for observation condition

for k=1:length(grsp_bad)
    
    for i=1:length(EEG.event)
        if strcmp(EEG.event(i).type, baseline_markers{1}) && (EEG.event(i).TrialNum == grsp_bad(k))
            EEG.event(i).type = [EEG.event(i).type '_ogbad'];
        end
    end
end

for k=1:length(grsp_bad)
    
    for i=1:length(EEG.event)
        if strcmp(EEG.event(i).type, experimental_markers{1}) && (EEG.event(i).TrialNum == grsp_bad(k))
            EEG.event(i).type = [EEG.event(i).type '_ogbad'];
        end
    end
end



%%
% Mark bad trials for point condition

for k=1:length(point_bad)
    
    for i=1:length(EEG.event)
        if strcmp(EEG.event(i).type, baseline_markers{2}) && (EEG.event(i).TrialNum == point_bad(k))
            EEG.event(i).type = [EEG.event(i).type '_ptbad'];
        end
    end
end

for k=1:length(point_bad)
    
    for i=1:length(EEG.event)
        if strcmp(EEG.event(i).type, experimental_markers{2}) && (EEG.event(i).TrialNum == point_bad(k))
            EEG.event(i).type = [EEG.event(i).type '_ptbad'];
        end
    end
end

%%
% Mark bad trials for execution condition

for k=1:length(exe_bad)
    
    for i=1:length(EEG.event)
        if strcmp(EEG.event(i).type, baseline_markers{3}) && (EEG.event(i).TrialNum == exe_bad(k))
            EEG.event(i).type = [EEG.event(i).type '_egbad'];
        end
    end
end

for k=1:length(exe_bad)
    
    for i=1:length(EEG.event)
        if strcmp(EEG.event(i).type, experimental_markers{3}) && (EEG.event(i).TrialNum == exe_bad(k))
            EEG.event(i).type = [EEG.event(i).type '_egbad'];
        end
    end
end


