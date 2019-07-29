function plot_scalp_array_time_frequency(study_info)

plot_time_lims=study_info.epoch_length_experimental.*1000;

% Initialize excluded and included subjects
excluded={};
included=study_info.participant_info.participant_id;

% Apply exclusion criteria
for i=1:length(study_info.tf_exclude_subjects)
    eval(sprintf('[excluded, included]=%s(study_info, excluded, included);', study_info.tf_exclude_subjects{i}));
end

cond_mean_ersps={};
for cond_idx=1:length(study_info.experimental_conditions)
    cond_ersps=[];
    %% Loop through all subjects
    for s=1:size(study_info.participant_info,1)
    
        % Get subject ID from study info
        subject=study_info.participant_info.participant_id{s};
    
        % If subject not excluded
        if find(strcmp(included, subject))
            % Where to put processed (derived) data
            subject_output_data_dir=fullfile(study_info.output_dir, subject, 'eeg');
            tf_output_dir=fullfile(subject_output_data_dir, 'tf');


            fname = fullfile(tf_output_dir, sprintf('%s_timefreqs_%s_%s.mat', subject, study_info.baseline_normalize, study_info.experimental_conditions{cond_idx}));
            if exist(fname,'file')==2
                load(fname);
                time_idx=intersect(find(time>=plot_time_lims(1)),find(time<=plot_time_lims(2)));
                chan_ersp=timefreqs_data(:,time_idx,:);
                cond_ersps(end+1,:,:,:)=chan_ersp;
            end
        end
    end
    cond_mean_ersps{cond_idx}=permute(cond_ersps,[2 3 4 1]);
end
        
DEFAULT_PLOT_WIDTH    = 0.95;     % 0.75, width and height of plot array on figure
DEFAULT_PLOT_HEIGHT   = 0.88;    % 0.88
DEFAULT_AXWIDTH  = 0.04; %
DEFAULT_AXHEIGHT = 0.05; %

fname=fullfile(study_info.output_dir,...
    study_info.participant_info.participant_id{1}, 'eeg',...
    'final_channel_locations.mat');
load(fname);
nonemptychans = cellfun('isempty', { channel_location.theta });
nonemptychans = find(~nonemptychans);
[tmp channames Th Rd] = readlocs(channel_location(nonemptychans));
channames = strvcat({ channel_location.labels });
Th = pi/180*Th;                 % convert degrees to radians
Rd = Rd;

[yvalstmp,xvalstmp] = pol2cart(Th,Rd); % translate from polar to cart. coordinates
xvals(nonemptychans) = xvalstmp;
yvals(nonemptychans) = yvalstmp;

totalchans = length(channel_location);
emptychans = setdiff_bc(1:totalchans, nonemptychans);
totalchans = floor(sqrt(totalchans))+1;
for index = 1:length(emptychans)
    xvals(emptychans(index)) = 0.7+0.2*floor((index-1)/totalchans);
    yvals(emptychans(index)) = -0.4+mod(index-1,totalchans)/totalchans;
end;

xvals = (xvals-mean([max(xvals) min(xvals)]))/(max(xvals)-min(xvals)); % recenter

cond_mean_ersp={};%zeros(length(STUDY.condition), length(channels), length(erspfreqs), length(ersptimes));
chan_mean_ersp={};
for cond_idx=1:length(study_info.experimental_conditions)
    cond_ersp=cond_mean_ersps{cond_idx};
    for c=1:length(channel_location)
        ch_mean=squeeze(mean(cond_ersp(:,:,c,:),4));
        cond_mean_ersp{cond_idx,c}=ch_mean;   
        chan_mean_ersp{cond_idx,c}=squeeze(cond_ersp(:,:,c,:));   
    end
end
chan_p_vals={};
for c=1:length(channel_location)
    [pcond, pgroup, pinter, statscond, statsgroup, statsinter] = std_stat(chan_mean_ersp(:,c), 'paired', {'on'}, 'condstats', 'on', 'correctm', 'fdr');
    chan_p_vals{c}=pcond{1};
end

%clim=[-max(abs(cond_mean_ersp(:))) max(abs(cond_mean_ersp(:)))];
%clim=[min(cond_mean_ersp(:)) max(cond_mean_ersp(:))];

for cond_idx=1:length(study_info.experimental_conditions)
    figure();
    gcapos = get(gca,'Position'); axis off;
    PLOT_WIDTH    = gcapos(3)*DEFAULT_PLOT_WIDTH; % width and height of gca plot array on gca
    PLOT_HEIGHT   = gcapos(4)*DEFAULT_PLOT_HEIGHT;
    axheight = DEFAULT_AXHEIGHT*(gcapos(4)*1.25);
    axwidth =  DEFAULT_AXWIDTH*(gcapos(3)*1.3);
    
    cond_xvals = gcapos(1)+gcapos(3)/2+PLOT_WIDTH*xvals;   % controls width of plot
    cond_yvals = gcapos(2)+gcapos(4)/2+PLOT_HEIGHT*yvals;  % controls height of plot

    Axes = [];
    for c=1:length(channel_location), %%%%%%%% for each data channel %%%%%%%%%%%%%%%%%%%%%%%%%%

        xcenter = cond_xvals(c); if isnan(xcenter), xcenter = 0.5; end; 
        ycenter = cond_yvals(c); if isnan(ycenter), ycenter = 0.5; end;
        ax=axes('Units','Normal','Position', ...
            [xcenter-axwidth/2 ycenter-axheight/2 axwidth axheight]);
        axis('off');
        chan_ersp=cond_mean_ersp{cond_idx,c};
        imagesc(time(time_idx)./1000.0,frequency,chan_ersp);
        set(ax,'ydir','normal');
        hold on;
        plot([0 0], [frequency(1) frequency(end)], 'k--');
        ylabel(channames(c,:));
        Axes = [Axes ax];        
    end
end

figure();
gcapos = get(gca,'Position'); axis off;
PLOT_WIDTH    = gcapos(3)*DEFAULT_PLOT_WIDTH; % width and height of gca plot array on gca
PLOT_HEIGHT   = gcapos(4)*DEFAULT_PLOT_HEIGHT;
axheight = DEFAULT_AXHEIGHT*(gcapos(4)*1.25);
axwidth =  DEFAULT_AXWIDTH*(gcapos(3)*1.3);

cond_xvals = gcapos(1)+gcapos(3)/2+PLOT_WIDTH*xvals;   % controls width of plot
cond_yvals = gcapos(2)+gcapos(4)/2+PLOT_HEIGHT*yvals;  % controls height of plot

Axes = [];
for c=1:length(channel_location), %%%%%%%% for each data channel %%%%%%%%%%%%%%%%%%%%%%%%%%

    xcenter = cond_xvals(c); if isnan(xcenter), xcenter = 0.5; end; 
    ycenter = cond_yvals(c); if isnan(ycenter), ycenter = 0.5; end;
    ax=axes('Units','Normal','Position', ...
        [xcenter-axwidth/2 ycenter-axheight/2 axwidth axheight]);
    axis('off');
    p_vals=chan_p_vals{c};
    colormap(flipud(colormap('hot')));
    imagesc(time(time_idx)./1000.0,frequency,p_vals,[0 0.05]);
    set(gca,'ydir','normal');
    hold on;
    plot([0 0], [frequency(1) frequency(end)], 'w--');
    ylabel(channames(c,:));
    Axes = [Axes ax];        
end