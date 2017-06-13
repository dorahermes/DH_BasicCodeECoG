function [signal] = ecog_CarRegress(signal, chans2incl)
% common average referencing flunction with regressing out the mean, rather
% than subtracting out the mean
%
% dh - Oct 2010
% signal = electrodes X samples

if size(signal,2) < size(signal,1) % signal samples X electrodes
    disp('transpose signal to be electrodes X samples')
    return
end

ca_signal=mean(signal(chans2incl,:),1);

% regress off the mean signal
for k=1:size(signal,1) % elecs
    disp(['elec ' int2str(k)])
    if ismember(k,chans2incl)
        [B,BINT,R] = regress(signal(k,:)',ca_signal');
        signal(k,:)=R';
    end
end

