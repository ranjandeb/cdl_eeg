%% Individualized_Info
% last updated 6/25/2018

%% Specify Paths
% Locate data on hard drive
data_location = 'E:\PTS_study_VS\Visit1\Raw data\';
output_dir = 'E:\PTS_study_VS\Visit1\';
% output_general = 'Output_General\';
% output_specific = 'Output_Specific\All_Movement_Excluded\';
input_dir = 'E:\PTS_study_VS\Visit1\';

% Initialize channel locations
ch129_locations = 'C:\Users\Berger\Documents\eeglab13_4_4b\plugins\mffimport2.1\GSN-HydroCel-129.sfp';
ch104_locations = 'E:\PTS_study_VS\Visit1\Scripts\channel104_location.mat';
load('E:\PTS_study_VS\Visit1\Scripts\channel104_location.mat');

% Event marker location
event_location = 'E:\PTS_study_VS\Visit1\Finalized Markup Files\';

%% Participants
% Video coding files
% Participants_coded ={'PO4104exe'};

% Make a list of all datasets to be included in the analysis
% EEG files

 %% Subject list
%subject_list = {'PO4104exe'}
cd(data_location)
subnum=dir('*.set');
sub_list={subnum.name};
for i =1:length(sub_list)
    sub = sub_list{i};
    subject_list{i}= sub(1:end-4);
end

%subject_list = subject_list(1);
%subject_list = subject_list(1:end);

%Post TF subject lists per condition
% %OG
% subject_list_og = subject_list([1	2	4	6	9	10	11	12	13	14	17 ...
%     21	22	23	24	26	29	30	33	34	35	36	37	38	39	40	41	42 ...
%     43	44	45	46	47	49	50	51	52	53	56	59	63	64	65]);
% % %OP
% subject_list_op = subject_list([1	4	5	6	9	10	11	12	13	14	15 ...
%     17	18	21	22	23	26	27	29	30	33	34	35	37	38	39	40	41 ...
%     42	43	45	46	47	48	49	50	52	53	56	59	61	64	65	66]);
% % %EG
% subject_list_eg = subject_list([1	2	4	5	6	8	9	11	12	13	14 ...
%     15	17	21	23	26	27	29	30	31	33	36	37	38	39	40	41	42 ...
%     43	44	45	47	48	49	50	52	53	58	61	63	64]);

%% Initialize all other variables for first preprocessing step
EGI_AATF = 18; % EGI anti-aliasing time offset depends on sampling rate and amplifire.
TASK_TF = 0; % task related offset
% Check your amplifire version and data sample and adjust the time offset accordingly
sampling_rate = 500; % We use 500Hz sampling rate

%% Delete outerlayer of the channels in infants data
delete_outlyr = 'yes'; % yes||no, requires answer

% Initialize filters
highpass = 0.3;
lowpass  = 50;

%% Initialize variables for preparation of ICA on copied data

hp_fl_4ICA = 1; % 1 Hz highpass filter
event_time_window = 1; % epoch length is 1 second
event_type = '999'; % 999 is temporary event marker
delete_chan='no'; % Delete channel if > XX% are artifacted? yes|no. If you say yes here, specify cutoff percent below
cutoff_pcnt=20; % If > 20% epochs are bad in a channel, that channel will be removed. Change cutoff percent as required   

% File to write number of rejected epochs in copied data
reject_copied_data = 'Num_trials_copied_data.csv';

%% For second preprocessing step
% name of individualized event scripts
Mark_Bad_Trials={'Mark_Bad_Trials_Excel_v2_P1_PtS'};

% types of trials
trial_type = {'baseline','experimental'};
% define baseline trials
baseline_markers = {'OGBL', 'OPBL', 'EGBL'};
% define baseline epoch length
epoch_length_baseline=[0 2];
% define longer baseline epoch to take into account TFR data loss at edges
extended_epoch_length_baseline = [-1 3];

% define experimental trials
experimental_markers = {'OGGC', 'OPPC', 'EGGC'};
% Define epoch length in second (e.g. length is -1.5s to 1.5s)
epoch_length_experimental=[-1.5 .5];
% define longer experimental epoch to take into account TFR data loss at edges
extended_epoch_length_experimental = [-2.5 1.5];

% % define interference markers
% interference_markers = {'CACT', 'CCRY','CMOV','CPAR','CEAT'};
% % interference_markers = {'NOTL', 'ICRY','IPAR','IACT','GMOV'};
% % interference_markers = {'NOTL', 'ICRY','IPAR','IACT','FMOV'};
% % interference_markers = {'NOTL', 'ICRY','IPAR','IACT'};


%% Artifact rejection
% Step 1 eyelblink: detect and reject based on front six frontal channels
% ('E1', 'E8', 'E14', 'E21', 'E25', 'E32') for voltage only. no interp
interp_chan = 'yes';
volthrs_low = -250;
volthrs_up  = 250;

% If more than 10% of channels in a epoch were interpolated in a epoch, reject that epoch
percent_chan = 10;

% File to write number of epochs before and after artifact rejection
numtrl_bfafartrej = 'Num_Trials_BefAft_ArtRej.csv';

%% Rereference to average of all channels
reref = [];

%% For third processing step

% Match baseline with experimental marker
baseline_exp_markers = {{'OGBL','OGGC'}, {'OPBL','OPPC'}, {'EGBL','EGGC'}};
base_exp_match_marker = {{'OGBL_MTH','OGGC_MTH'}, {'OPBL_MTH','OPPC_MTH'}, {'EGBL_MTH','EGGC_MTH'}};

all_match_exp_markers = {'OGGC_MTH','OPPC_MTH','EGGC_MTH'};
all_match_base_markers = {'OGBL_MTH','OPBL_MTH','EGBL_MTH'};

%% for CSD transform
%% Paths to CSD toolbox and EEGLab
addpath(genpath('C:\Users\Berger\Documents\eeglab13_4_4b')); % Point to your version of EEGLab
addpath(genpath(('C:\Users\Berger\Documents\CSDtoolbox')));   % Point to place where you put CSDToolbox

current_montage_path = 'GSN-HydroCel-104.csd';

%% for Time-Frequency Analysis

substract_baseline = [-1000 0];

% if you want a different range here make sure to checke the Time Frequency
% script --> adjust wavelet cycle
freqOI = [3 30];

conditions =    {'OGGC','OPPC','EGGC'};
baselines =     {'OGBL','OPBL','EGBL'};
condition_label = {'obsgrsp','obspnt','exegrsp'};

%% for FLEXIBLE Time-Frequency Analysis

% min_trials=3;
% substract_baseline = [-1000 0];
% % if you want a different range here make sure to checke the Time Frequency
% % script --> adjust wavelet cycle
% freqOI = [3 30];
% num_frex = 100;
% conditions =    {'OGGC','OPPC','EGGC'};
% baselines =     {'OGBL','OPBL','EGBL'};
% % conditions =    {'OPPC'};
% % baselines =     {'OPBL'};
% condition_label = {'obsgrsp','obspnt','exegrsp'};
% % condition_label = {'obspnt'};
% baseline_type = {'within_condition', 'single_trial', 'across_condition'};
% baseline_normalize = baseline_type{2};

%% for Topoplot
% Time bins
% if you have more than 20 time windows adjust in the script
% subplot(4,5,ti)
time_windows = [ -1500 -1000; -1000 -500; -500 0; 0 500];
%time_windows = [-1500 -1300; -1300 -1100; -1100 -900; -900 -700; -700 -500; -500 -300; -300 -100; -100 100; 100 300; 300 500];
% frequency ranges
mu_freq_windows = [ 6 9 ];
beta_freq_windows = [10 17];
theta_freq_windows = [3 5];
% standardize axis
clim       = [ -1.5  1.5 ];

%% for TFR plot
lim_obg=[-1.5 1.5];
lim_obp=[-1.5 1.5];
lim_exe=[-1.5 1.5];
freq2plot=[3 20];
time2plot=[-1500 500];

%% for Writing data in text file

% Text file name
%textfile='PtSdataVisit1_1500.500_OG.txt';
% textfile='PtSdataVisit1_1500.500_OP.txt';
textfile='PtSdataVisit1_1500.500_EG.txt';

%%
eeglab;