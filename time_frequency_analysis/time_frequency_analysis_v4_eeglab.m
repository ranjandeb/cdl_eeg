%%
% Perform time frequency calculation
Directories_Variable_Info_v6();
cd 'E:\PTS_study_VS\Visit2\'

% open EEGLab
eeglab;

% Check if variable Exclusion_Info exists already. If yes, load it. if
% exist([output_dir 'Exclusion_Info.mat']) == 2
%     load([output_dir 'Exclusion_Info'],'Exclusion_Info');
% end


for s=1:length(subject_list)
    
    subject = subject_list{s};
    
    EEG_base = []; % Initialize variable for Condition 1
    EEG_exp = []; % Initialize variable for Condition 2
    EEG_base1 = [];
    EEG_base2 = [];
    EEG_base3 = [];
    EEG_exp1 = [];
    EEG_exp2 = [];
    EEG_exp3 = [];
    
    
    %% Load pre-processed dataset
    
    % load baseline data
    EEG=pop_loadset('filename',[subject '_Epoched_Matched_CSD_' trial_type{1} '.set'],'filepath', CSD_Data);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    EEG_base = EEG;
    EEG = [];
    
    % load experimental data
    EEG=pop_loadset('filename',[subject '_Epoched_Matched_CSD_' trial_type{2} '.set'], 'filepath', CSD_Data);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    EEG_exp = EEG;
    
    channel_location = EEG.chanlocs; % Channel location is required for topograpic plot
    
    %% calculate trial numbers
    for i=1:length(all_match_base_markers)
        trls_left(s,i) = sum(strcmp(all_match_base_markers{i},{EEG_base.event.type}));
    end
    
%        Exclusion_Info.(subject).RemainingTrials_perCond = trls_left(s);
%        Exclusion_Info.(subject).RemainingTrials_perCondheader =
%        condition_label;
    
    %% if more or less than 2 conditions adjust
    %EEG_base[COND_number] = pop_selectevent( EEG_base, 'type',
    %baselines{[COND_number]},'deleteevents','off','deleteepochs','on','invertepochs','off');
    
    %% analyse condition 1
 
    if length(find(strcmp({EEG_base.event.type}, all_match_base_markers{1})))> 2 && length(find(strcmp({EEG_exp.event.type}, all_match_exp_markers{1}))) > 2
        
        EEG_base1 = pop_selectevent( EEG_base, 'type', all_match_base_markers{1},'deleteevents','off','deleteepochs','on','invertepochs','off');
        EEG_exp1 = pop_selectevent( EEG_exp, 'type', all_match_exp_markers{1},'deleteevents','off','deleteepochs','on','invertepochs','off');
        
        for elec = 1:EEG_base.nbchan
            
            % Calculate baseline power
            
            % window size calculated based on following formula:
            % [(1000/lowest freq)*number of wavelet cycles]
            
            %% if more or less than two conditions add/remove (lines 62-74)
            
            [ersp, itc, powbase] = newtimef(EEG_base1.data(elec,:,:), EEG_base1.pnts, [EEG_base1.xmin EEG_base1.xmax]*1000, ...
                EEG_base1.srate,[3 0.5], 'baseline',substract_baseline, 'freqs', freqOI, 'nfreqs', 150,...
                'plotersp','off', 'plotitc', 'off', 'plotphase', 'off', 'padratio', 8);
            
            tf_base_1 = [];
            tf_base_1=powbase;
            
            [ersp, itc, powbase, times, freqs] = newtimef(EEG_exp1.data(elec,:,:), EEG_exp1.pnts, [EEG_exp1.xmin EEG_exp1.xmax]*1000,...
                EEG_exp1.srate,[3 0.5], 'powbase', tf_base_1, 'freqs', freqOI,'nfreqs', 150,...
                'plotersp','off', 'plotitc', 'off', 'plotphase', 'off', 'padratio', 8);
            
            tf_data_1(:,:,elec)=ersp;
            
        end
        
        save_data1=[subject, '_tf_data_1'];
        save ([TFR_Data save_data1], 'tf_data_1', 'times', 'freqs', 'channel_location', '-v7.3');
    end
    
    %% analyse condition 2
    
    if length(find(strcmp({EEG_base.event.type}, all_match_base_markers{2})))> 2 && length(find(strcmp({EEG_exp.event.type}, all_match_exp_markers{2}))) > 2
        
        EEG_base2 = pop_selectevent( EEG_base, 'type', all_match_base_markers{2},'deleteevents','off','deleteepochs','on','invertepochs','off');
        EEG_exp2 = pop_selectevent( EEG_exp, 'type', all_match_exp_markers{2},'deleteevents','off','deleteepochs','on','invertepochs','off');
        
        for elec = 1:EEG_base.nbchan
            
            [ersp, itc, powbase] = newtimef(EEG_base2.data(elec,:,:), EEG_base2.pnts, [EEG_base2.xmin EEG_base2.xmax]*1000, ...
                EEG_base2.srate,[3 0.5], 'baseline',substract_baseline, 'freqs', freqOI, 'nfreqs', 150,...
                'plotersp','off', 'plotitc', 'off', 'plotphase', 'off', 'padratio', 8);
            
            tf_base_2 = [];
            tf_base_2=powbase;
            
            [ersp, itc, powbase, times, freqs] = newtimef(EEG_exp2.data(elec,:,:), EEG_exp2.pnts, [EEG_exp2.xmin EEG_exp2.xmax]*1000,...
                EEG_exp2.srate,[3 0.5], 'powbase', tf_base_2, 'freqs', freqOI,'nfreqs', 150,...
                'plotersp','off', 'plotitc', 'off', 'plotphase', 'off', 'padratio', 8);
            
            tf_data_2(:,:,elec)=ersp;
        end
        
        save_data2=[subject, '_tf_data_2'];
        save ([TFR_Data save_data2], 'tf_data_2', 'times', 'freqs', 'channel_location','-v7.3');
    end
    
    %% analyse condition 3
    
    if length(find(strcmp({EEG_base.event.type}, all_match_base_markers{3})))> 2 && length(find(strcmp({EEG_exp.event.type}, all_match_exp_markers{3}))) > 2
        
        EEG_base3 = pop_selectevent( EEG_base, 'type', all_match_base_markers{3},'deleteevents','off','deleteepochs','on','invertepochs','off');
        EEG_exp3 = pop_selectevent( EEG_exp, 'type', all_match_exp_markers{3},'deleteevents','off','deleteepochs','on','invertepochs','off');
              
        for elec = 1:EEG_base.nbchan
            
            [ersp, itc, powbase] = newtimef(EEG_base3.data(elec,:,:), EEG_base3.pnts, [EEG_base3.xmin EEG_base3.xmax]*1000, ...
                EEG_base3.srate,[3 0.5], 'baseline',substract_baseline, 'freqs', freqOI, 'nfreqs', 150,...
                'plotersp','off', 'plotitc', 'off', 'plotphase', 'off', 'padratio', 8);
            
            tf_base_3 = [];
            tf_base_3=powbase;
            
            [ersp, itc, powbase, times, freqs] = newtimef(EEG_exp3.data(elec,:,:), EEG_exp3.pnts, [EEG_exp3.xmin EEG_exp3.xmax]*1000,...
                EEG_exp3.srate,[3 0.5], 'powbase', tf_base_3, 'freqs', freqOI,'nfreqs', 150,...
                'plotersp','off', 'plotitc', 'off', 'plotphase', 'off', 'padratio', 8);
            
            tf_data_3(:,:,elec)=ersp;
        end
        
        %% save data
        
        save_data3=[subject, '_tf_data_3'];
        save ([TFR_Data save_data3], 'tf_data_3', 'times', 'freqs', 'channel_location','-v7.3');
    
    
    end
    
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
%     save([output_dir 'Exclusion_Info'],'Exclusion_Info');
end
