%% Individualized_Info
function study_info=init_study_info()

study_info=[];
study_info.task='facialexpressions';

%% Specify Paths
% Locate data on hard drive
study_info.data_dir = '/data2/empathy_eeg/bids';
study_info.output_dir = '/data2/empathy_eeg/deriv';

% Initial channel locations (including reference)
study_info.init_channel_locations = '/data2/empathy_eeg/GSN-HydroCel-129.sfp';

%% Subject list
study_info.participant_info=readtable([fullfile(study_info.data_dir, 'participants.tsv')],...
    'FileType','text','Delimiter','\t','TreatAsEmpty',{''});

%% EEG acquisition info
study_info.eeg_info=loadjson(fullfile(study_info.data_dir,...
    sprintf('task-%s_eeg.json', study_info.task)));

%% Sampling rate to resample to
study_info.sample_rate=250;

%% Impedance threshold to mark bad channels
study_info.impedance_threshold=50;

%% Remove data before last boundary event
study_info.remove_before_last_boundary=false;

%% Remove data before last boundary event
study_info.remove_before_last_boundary=false;

%% Cap remove event
study_info.cap_remove_event='net';

%% Initialize all other variables for first preprocessing step
% EGI anti-aliasing time offset (ms) depends on sampling rate and amplifier
study_info.EGI_AATF = 112; 

%% Delete outerlayer of the channels in infants data
study_info.delete_outlyr = 'yes'; % yes||no, requires answer

%% Initialize filters
study_info.highpass = 0.3;
study_info.lowpass  = 40;

%% Initialize variables for preparation of ICA on copied data
% 1 Hz highpass filter
study_info.hp_fl_4ICA = 1; 
% epoch length is 1 second
study_info.event_time_window = 1; 
% 999 is temporary event marker
study_info.event_type = '999'; 
% Delete channel if > XX% are artifacted? yes|no. If you say yes here,
% specify cutoff percent below
study_info.delete_chan='no'; 
% If > 20% epochs are bad in a channel, that channel will be removed.
% Change cutoff percent as required   
study_info.cutoff_pcnt=20;

%% For second preprocessing step
% name of individualized event scripts for marking bad trials (based on
% video interference coding, for example)
% must have parameters: study_info, s (subject index in list of subjects),
% EEG (subject's eeg data), and preprocessing_info. Must return EEG and
% preprocessing_info
study_info.mark_bad_trials={'mark_bad_trials'};

% baseline type (epoch_matched or within_epoch). If 'epoched_matched',
% matching_markers will be called to match baseline to experimental
% epochs. If 'within_epoch' the baseline time window within experimental
% epochs will be used as the baseline
study_info.baseline_type='within_epoch';

% types of trials (baseline or experimental)
study_info.trial_type = {'experimental'};

% define baseline trials (only used if study_info.baseline_type is 
% 'epoched_matched')
% list of baseline condition names
study_info.baseline_conditions={};
% for each baseline condition, the event type to center epochs around (can
% be the same for each condition)
study_info.baseline_event_types = {};
% for each baseline condition, the event field to check the value of to
% determine the condition
study_info.baseline_event_fields = {};
% for each baseline condition, the value of the event field
study_info.baseline_event_field_values = {};
% define baseline epoch length
study_info.epoch_length_baseline=[];
% define longer baseline epoch to take into account TFR data loss at edges
study_info.extended_epoch_length_baseline = [];

% define experimental trials
% list of experimental condition names
study_info.experimental_conditions={'angry','happy','neutral'};
% for each experimental condition, the event type to center epochs around
% (can be the same for each condition)
study_info.experimental_event_types = {'Stm+','Stm+','Stm+'};
% for each experimental condition, the event field to check the value of to
% determine the condition (can be the same for each condition)
study_info.experimental_event_condition_fields = {'Emotion','Emotion','Emotion'};
% for each experimental condition, the value of the event field
study_info.experimental_event_condition_field_values = {'a', 'h', 'n'};
% Define epoch length in seconds (e.g. length is -0.8s to 2.5s)
study_info.epoch_length_experimental=[-0.8 2.5];
% define longer experimental epoch to take into account TFR data loss at
% edges
study_info.extended_epoch_length_experimental = [-1.8 3.5];

% % define interference markers
study_info.interference_markers = {'NOAT', 'MVMT'};


%% Artifact rejection
% Step 1 eyelblink: detect and reject based on front six frontal channels
% ('E1', 'E8', 'E14', 'E21', 'E25', 'E32') for voltage only. no interp
study_info.interp_chan = 'yes';
study_info.volthrs_low = -250;
study_info.volthrs_up  = 250;

% If more than 10% of channels in a epoch were interpolated in a epoch,
% reject that epoch
study_info.percent_chan = 10;

% Whether or not to use automatic ICA rejection
study_info.automatic_ica_rej=true;

%% Rereference to average of all channels
study_info.reref = [];

%% For third processing step

% Match baseline with experimental marker
%study_info.baseline_exp_markers = {{'OGBL','OGGC'}, {'OPBL','OPPC'}, {'EGBL','EGGC'}};
study_info.baseline_exp_markers = {};
%study_info.base_exp_match_marker = {{'OGBL_MTH','OGGC_MTH'}, {'OPBL_MTH','OPPC_MTH'}, {'EGBL_MTH','EGGC_MTH'}};
study_info.base_exp_match_marker = {};

%study_info.all_match_exp_markers = {'OGGC_MTH','OPPC_MTH','EGGC_MTH'};
study_info.all_match_exp_markers = {};
%study_info.all_match_base_markers = {'OGBL_MTH','OPBL_MTH','EGBL_MTH'};
study_info.all_match_base_markers = {};

%% for CSD transform
%% Paths to CSD toolbox and EEGLab
addpath(genpath('/home/jbonaiuto/Apps/CSDtoolbox'));   % Point to place where you put CSDToolbox

study_info.current_montage_path = '/data2/empathy_eeg/GSN-HydroCel-104.csd';

%% for Time-Frequency Analysis
study_info.baseline_woi = [-0.8 0];

% if you want a different range here make sure to checke the Time Frequency
% script --> adjust wavelet cycle
study_info.FOI = [3 30];
study_info.num_frex = 100;

% Frequency space (linear or log)
study_info.freq_space='linear';

% name of individualized event scripts for excluding subjects
% must have parameters: study_info, excluded (cell array of excluded 
% subject IDs), included (cell array of included subject IDs). Must return
% excluded and included
study_info.tf_exclude_subjects={'exclude_subjects'};

% Can be 'within_condition', 'single_trial', or 'across_condition'
study_info.baseline_normalize = 'within_condition';

% List of electrode clusters - cluster name and list of channel names
study_info.clusters=[];
study_info.clusters(1).name='C3';
study_info.clusters(1).channels={'E29', 'E30', 'E35', 'E36', 'E37', 'E41', 'E42'};
study_info.clusters(2).name='C4';
study_info.clusters(2).channels={'E87', 'E93', 'E103', 'E104', 'E105', 'E110', 'E111'};
study_info.clusters(1).name='C3';
study_info.clusters(1).channels={'E29', 'E30', 'E35', 'E36', 'E37', 'E41', 'E42', 'E87', 'E93', 'E103', 'E104', 'E105', 'E110', 'E111'};
study_info.clusters(3).name='F3';
study_info.clusters(3).channels={'E19', 'E20', 'E23', 'E24', 'E27', 'E28'};
study_info.clusters(4).name='F4';
study_info.clusters(4).channels={'E3', 'E4', 'E117', 'E118', 'E123', 'E124'};
study_info.clusters(3).name='F';
study_info.clusters(3).channels={'E19', 'E20', 'E23', 'E24', 'E27', 'E28', 'E3', 'E4', 'E117', 'E118', 'E123', 'E124'};
study_info.clusters(5).name='P3';
study_info.clusters(5).channels={'E47', 'E51', 'E52', 'E53', 'E59', 'E60'};
study_info.clusters(6).name='P4';
study_info.clusters(6).channels={'E85', 'E86', 'E91', 'E92', 'E97', 'E98'};
study_info.clusters(5).name='P';
study_info.clusters(5).channels={'E47', 'E51', 'E52', 'E53', 'E59', 'E60', 'E85', 'E86', 'E91', 'E92', 'E97', 'E98'};
study_info.clusters(7).name='O1';
study_info.clusters(7).channels={'E66', 'E69', 'E70', 'E71', 'E74'};
study_info.clusters(8).name='O2';
study_info.clusters(8).channels={'E76', 'E82', 'E83', 'E84', 'E89'};
study_info.clusters(7).name='O';
study_info.clusters(7).channels={'E66', 'E69', 'E70', 'E71', 'E74', 'E76', 'E82', 'E83', 'E84', 'E89'};
    
% Name and frequency ranges of frequency bands to analyze
study_info.freq_bands=[];
study_info.freq_bands(1).name='mu';
study_info.freq_bands(1).foi=[6 9];
study_info.freq_bands(2).name='beta';
study_info.freq_bands(2).foi=[10 17];
study_info.freq_bands(2).name='theta';
study_info.freq_bands(2).foi=[3 5];

%% for Topoplot
% Time bins
% if you have more than 20 time windows adjust in the script
% subplot(4,5,ti)
time_windows = [ -1500 -1000; -1000 -500; -500 0; 0 500];
% standardize axis
clim       = [ -1.5  1.5 ];

%% for TFR plot
% plot frequency limits
study_info.freq2plot=[3 20];
study_info.time2plot=[-800 1000];

%% for Writing data in text file

% Text file name
textfile='PtSdataVisit1_1500.500_EG.txt';

%%
eeglab;