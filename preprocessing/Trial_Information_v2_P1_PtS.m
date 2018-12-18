% Check if variable Exclusion_Info exists already. If yes, load it.
if exist([output_dir 'Exclusion_Info.mat']) == 2
    load([output_dir 'Exclusion_Info'],'Exclusion_Info');
end

all_subjects = fields(Exclusion_Info);

for s=1:length(fields(Exclusion_Info))
    subject = all_subjects{s};
    AllRemaining_trials(s,1) = str2num(all_subjects{s}(end-1:end));
%     AllRemaining_trials(s,2) = Exclusion_Info.(subject).BeforeExl_BASE;
%     AllRemaining_trials(s,3) = Exclusion_Info.(subject).BeforeExl_EXP;
%     AllRemaining_trials(s,4) = Exclusion_Info.(subject).AFTERExl_BASE;
%     AllRemaining_trials(s,5) = Exclusion_Info.(subject).AFTERExl_EXP;
    
    if isfield(Exclusion_Info.(subject),'baseline')==1
        AllRemaining_trials(s,6) = Exclusion_Info.(subject).baseline.Total_Trials;
    else
        AllRemaining_trials(s,6) = NaN;
    end
    
    
    if isfield(Exclusion_Info.(subject),'experimental')==1
        AllRemaining_trials(s,9) = Exclusion_Info.(subject).experimental.Trials_After_Rej;
        AllRemaining_trials(s,7) = Exclusion_Info.(subject).experimental.Total_Trials;
        AllRemaining_trials(s,8) = Exclusion_Info.(subject).baseline.Trials_After_Rej;
    else
        AllRemaining_trials(s,9) = NaN;
        AllRemaining_trials(s,7) = NaN;
        AllRemaining_trials(s,8) = NaN;
    end
    
    if isfield(Exclusion_Info.(subject),'RemainingTrials')==1
        AllRemaining_trials(s,10) = Exclusion_Info.(subject).RemainingTrials;
    else
        AllRemaining_trials(s,10) = NaN;
    end
end

AllRemaining_trials_header = {'PartNR', 'Before_Base', 'Before_Exp', ...
    'AfterVideoExcl_Base', 'AfterVideoExcl_Exp', ...
    'Trials_Base', 'Trials_Exp' ...
    'AfterAutomaticRej_Base', 'AfterAutomaticRej_Exp' ...
    'RemainingTrials'};
%% adjust this to your own video markers

% for s=1:length(fields(Exclusion_Info))
%     subject = all_subjects{s};
%     AllVideorejections(s,1) = str2num(all_subjects{s}(end-1:end));
%     reject_reasons = length(Exclusion_Info.(subject).videobased_exclusion_overview(1,:));
%     AllVideorejections(s,2:1+reject_reasons) =Exclusion_Info.(subject).videobased_exclusion_overview(1,:);
%     AllVideorejections(s,2+reject_reasons:1+reject_reasons+reject_reasons) =Exclusion_Info.(subject).videobased_exclusion_overview(2,:);
%     
% end
% AllVideorejections_header = {'PartNR',...
%     'NOTL_Base', 'ICRY_Base','IPAR_Base','IACT_Base','IMOV_Base',...
%     'NOTL_Exp', 'ICRY_Exp','IPAR_Exp','IACT_Exp','IMOV_Exp'};