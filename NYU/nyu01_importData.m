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
good_channels = setdiff(1:size(data.trial{1},1),bad_channels);
good_channels(good_channels>100)=[];

%% So let's visualize the timeseries of some channels
figure
subplot(2,1,1),hold on
plot(data.time{1},data.trial{1}(bad_channels(1),:),'r')
title('first bad channel')
subplot(2,1,2),hold on
plot(data.time{1},data.trial{1}(good_channels(1),:),'k')
title('first bad channel')

% check the powerplot of all the good channels, no leftover outliers?
figure,plot(f,log10(pxx(:,good_channels)))

% check the timeseries of all the good channels, no noisy moments?
figure,plot(data.time{1},data.trial{1}(good_channels,:))

%%  Now we know the bad channels, and we can do a common average reference.
% note that some reviewers may want to see another referencing method, and
% any large signal in 50% of the channels is introduced in all channels...

signal = data.trial{1};
[signal] = ecog_CarRegress(signal, good_channels);

%% look at the effect of CAR
figure
subplot(1,2,1),hold on
channel_plot = good_channels(1);
plot(data.time{1},data.trial{1}(channel_plot,:),'k')
plot(data.time{1},signal(channel_plot,:),'g')
legend({'before CAR','after CAR'})

subplot(1,2,2),hold on
[pxx2,f] = pwelch(signal',data.fsample,0,data.fsample,data.fsample);
plot(f,log10(pxx(:,channel_plot)),'k')
plot(f,log10(pxx2(:,channel_plot)),'g')

%% Now you have preprocessed data, save it somewhere and analyse.

%% You may want to do a notch filter (optional).

% Filter
hband_sig=zeros(size(signal));
for el=1:size(signal,1)
    disp(['filter el ' int2str(el) ' of ' int2str(size(signal,1))])
    hband=[60 70];
    hband_sig1=butterpass_eeglabdata(signal(el,:)',hband,data.fsample);   
    hband_sig1=log10(abs(hilbert(hband_sig1)).^2)-mean(log10(abs(hilbert(hband_sig1)).^2));
    hband=[70 80];
    hband_sig2=butterpass_eeglabdata(signal(el,:)',hband,data.fsample);   
    hband_sig2=log10(abs(hilbert(hband_sig2)).^2)-mean(log10(abs(hilbert(hband_sig2)).^2));
    hband=[80 90];
    hband_sig3=butterpass_eeglabdata(signal(el,:)',hband,data.fsample);   
    hband_sig3=log10(abs(hilbert(hband_sig3)).^2)-mean(log10(abs(hilbert(hband_sig3)).^2));
    hband=[110 120];
    hband_sig4=butterpass_eeglabdata(signal(el,:)',hband,data.fsample);   
    hband_sig4=log10(abs(hilbert(hband_sig4)).^2)-mean(log10(abs(hilbert(hband_sig4)).^2));

    hband_sig(el,:)=mean([hband_sig1 hband_sig2 hband_sig3 hband_sig4],2);

    clear hband_sig1 hband_sig2 hband_sig3 hband_sig4
end
    
% You can also notch filter at 100 and then take hband = 60:120
%%

figure,hold on
el = 45;
plot(data.time{1},smooth(hband_sig(el,:),64));
% load onsets
plot(onsets.soc,0,'r.')

% and plot event onsets on top

