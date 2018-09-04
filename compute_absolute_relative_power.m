%% Calculate power

clear
clc
%% Data location and location to save data
data_location = 'D:\BEIP_16yrs_rest\Epoch_Data\';
save_data     = 'D:\BEIP_16yrs_rest\new data july2018\power_data\';

%% Frequency range (Hz) for BEIP baseline
theta = [4 7];
alpha = [8 13];
beta  = [14 25];
gamma  = [26 40];
total = [4 40];

%% Subject list
cd(data_location)
subnum=dir('*.set');
sub_list={subnum.name};
for i =1:length(sub_list)
    sub = sub_list{i};
    subject_list{i}= sub(1:end);
end

%%
event_marker   = {'ONESEC-EYECLSD', 'ONESEC-EYEOPEN'};
condition_name = {'eyes_closed', 'eyes_open'};
mintrl2analyse = 59; % analyse a subject only if it has minimum one senond of data 

for sub=1:length(subject_list)
    
    subject = subject_list{sub};
    subject=subject(1:end-21);
    %% Load data
    EEG=pop_loadset('filename', [subject '_Reref_Epoch_Rest.set'], 'filepath', data_location);
    
    
    %% Get channel location from dataset
    channel_location = EEG.chanlocs;
    
    %% Get parameters of EEG dataset
    data_length = EEG.pnts;
    srate = EEG.srate;
    nyquist = srate/2;
    freqs = linspace(0, nyquist, floor(data_length/2+1));
    
    for cond=1:length(event_marker)
        EEGa = pop_selectevent( EEG, 'type', event_marker{cond},'deleteevents','off','deleteepochs','on','invertepochs','off');
        
        if size(EEGa.data, 3) > 59
            
            % Initialize variables
            abs_theta =[]; abs_alpha1 =[]; abs_alpha2 =[]; abs_beta1 =[]; abs_beta2 =[];
            rel_theta =[]; rel_alpha1 =[]; rel_alpha2 =[]; rel_beta1 =[]; rel_beta2 =[];
            
            %% Loop through all channels
        for elec = 1:EEGa.nbchan
            
            %% Initialize variables
            trial_power=[]; chan_power=[]; frequency =[]; totalPower =[];
            thetaIdx =[]; alphaIdx =[]; betaIdx =[]; gammaIdx =[]; 
            abs_thetaPower =[]; abs_alphaPower =[]; abs_betaPower =[]; abs_gammaPower =[];
            relativeTheta = []; relativeAlpha = []; relativeBeta  =[]; relativeGamma  =[]; 
            
            for trl=1:EEGa.trials
                
                %% Initialize variables
                data=[]; data_hann=[]; data_fft=[]; data_pos_freq=[]; data_amp=[];
                data_norma=[]; data_amp_pos_freq=[]; data_power=[];
                
                %% Compute fourier coefficient
                data=EEGa.data(elec,:,trl); %
                data_hann=data.*hann(data_length)'; % apply hanning taper
                data_fft=fft(data_hann); % % Fourier transform of data
                data_pos_freq=data_fft(1:floor(data_length/2+1)); % get only positive frequencies
                data_amp=abs(data_pos_freq); % get the amplitude of the frequencies
                data_norma=data_amp/data_length; % normalizing amplitude by length of data to have them be in same scale as data
                data_amp_pos_freq= 2*data_norma(2:end-1); % multiply amplitude by 2 because negative frequencies were removed
                data_power=data_amp_pos_freq.^2; % power is amplitude square
                trial_power(:,trl)=data_power; % Hold power in a frequency x trial matrix
            end
            chan_power=mean(trial_power, 2); % mean over trials (2nd dimensuion)
            chan_power=log10(1+chan_power); % take natural log of power for better distribution
            
            %% Find indecies of the frequencies
            frequency=freqs(2:end-1); % Frequency range excluding DC and nyquest
            
            % Find indecies of the frequencies
            thetaIdx = dsearchn(frequency', theta');
            alphaIdx = dsearchn(frequency', alpha');
            betaIdx  = dsearchn(frequency', beta');
            gammaIdx = dsearchn(frequency', gamma');
            totalIdx = dsearchn(frequency', total');
            
            %% Find power for each frequency band of interest
            thetaPower  = chan_power(thetaIdx(1):thetaIdx(2));
            alpha1Power = chan_power(alphaIdx(1):alphaIdx(2));
            betaPower   =  chan_power(betaIdx(1):betaIdx(2));
            gammaPower  =  chan_power(gammaIdx(1):gammaIdx(2));
            
            %% Calculate absolute power
            abs_thetaPower =  mean(chan_power(thetaIdx(1):thetaIdx(2)));
            abs_alphaPower =  mean(chan_power(alphaIdx(1):alphaIdx(2)));
            abs_betaPower  =  mean(chan_power(betaIdx(1):betaIdx(2)));
            abs_gammaPower =  mean(chan_power(gammaIdx(1):gammaIdx(2)));
            
            %% Hold absolute power of each channel in a channel x power matrix
            abs_theta (elec, :)  = abs_thetaPower;
            abs_alpha (elec, :)  = abs_alphaPower;
            abs_beta (elec, :)   = abs_betaPower;
            abs_gamma (elec, :)  = abs_gammaPower;
            
            %% Compute relative power
            totalPower     = sum(chan_power(totalIdx(1):totalIdx(2)));
            %totalPower    = sum(thetaPower)+sum(alphaPower)+sum(betaPower)+sum(gammaPower);
            relativeTheta  = sum(thetaPower)/(totalPower);
            relativeAlpha  = sum(alphaPower)/(totalPower);
            relativeBeta   = sum(betaPower)/(totalPower);
            relativeGamma  = sum(gammaPower)/(totalPower);
            
            %% Hold relative power in a channel x power matrix
            rel_theta (elec, :) = relativeTheta;
            rel_alpha (elec, :) = relativeAlpha;
            rel_beta (elec, :)  = relativeBeta;
            rel_gamma (elec, :) = relativeGamma;
                        
        end
        
        %% Save absolute power for each subject
                
        save_name = [save_data subject,  '_16yr_power_' condition_name{cond}];
        save (save_name, 'frequency', 'channel_location', 'abs_theta', 'abs_alpha', 'abs_beta', ...
              'abs_gamma', 'rel_theta', 'rel_alpha', 'rel_beta', 'rel_gamma');
        
        end
        
    end
end