rootpath = '/Volumes/DoraBigDrive/data/NYU/';
sub_label = 'nyu645';
ses_label = 'ieeg';
acq_label = 'sourcedata';
sourcedataName = 'NY645_Winawer_3x_1minute.edf';

dataName = fullfile(rootpath,['sub-' sub_label],['ses-' ses_label],acq_label,sourcedataName);

%% Import ECoG data

cfg            = [];
cfg.dataset    = dataName;
cfg.continuous = 'yes';
cfg.channel    = 'all';
data           = ft_preprocessing(cfg);

%% Look at powerpectrum of channels to see which ones look bad

% This is one way to calculate the power spectrum and make a plot, the nice
% thing is that when you click on the lines it returns the channel numbers
figure;
spectopo(data.trial{1}(1:100,:),size(data.trial{1},2),data.fsample);

% This is another way to look at the power spectum and make a plot. This
% returns the frequency (f) and power (pxx) and you can check for outliers.
[pxx,f] = pwelch(data.trial{1}(1:100,:)',data.fsample,0,data.fsample,data.fsample);
figure,plot(f,log10(pxx))

% Now, I think these are bad channels, but this is quite subjective.
bad_channels = find(log10(pxx(f==60,:))>3);