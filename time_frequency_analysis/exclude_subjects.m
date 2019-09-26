function [excluded, included]=exclude_subjects(study_info, excluded,...
    included)

min_trials_per_condition=10;

preprocessing_info=readtable(fullfile(study_info.output_dir,...
    'preprocessing_info.csv'));

subj_cond_per_trial=[];
for cond_idx=1:length(study_info.experimental_conditions)
    for s_idx=1:length(included)
        abs_s_idx=find(strcmp(preprocessing_info.Subject,included{s_idx}));
        subj_cond_per_trial(s_idx,cond_idx)=preprocessing_info.(sprintf('%sConditionNumTrials',study_info.experimental_conditions{cond_idx}))(abs_s_idx);
    end
end
subjs_to_exclude=included(find(min(subj_cond_per_trial,[],2)<min_trials_per_condition));


included=setdiff(included, subjs_to_exclude);
excluded=union(excluded, subjs_to_exclude);
