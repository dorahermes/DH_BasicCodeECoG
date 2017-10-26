
% script to call EEGlab spectopo to plot powerspectrum of all channels
% dh 2009, Utrecht University, The Netherlands

% always select all channels, otherwise numbers will not be correct
% data: data should be channels X time
srate=1525.88; % sampling rate
figure;
spectopo(data,length(data(1,:)), srate);


