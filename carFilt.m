%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% $Id: carFilt.m 2007-111-26 12:31:37EST fialkoff $ 
%% 
%% File: carFilt.m 
%% 
%% Author: Joshua Fialkoff <fialkj@rpi.edu>, Gerwin Schalk <schalk@wadsworth.org>
%%
%% Description: This function performs CAR filtering on the specified
%% signal.
%%
%% (C) 2000-2008, BCI2000 Project
%% http:%%www.bci2000.org 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dora 19/02/2008 
% edit 1 line 33:40
% add possibility to exclude channels

% Dora 19/02/2008 
% edit 2 start - end exclude channels
% add possibility to exclude channels

% Dora 19/02/2008 
% edit 2 line 28
% change num_chans for the included channels

function [signalOut,spatfiltmatrix] = carFilt(signal, chans2incl)

num_chans = length(chans2incl);%was size(signal,2)

% spatfiltmatrix=[];
% create a CAR spatial filter
spatfiltmatrix=-1/num_chans*ones(size(signal,2)); % ischanged
for i=1:length(signal(1,:))
    spatfiltmatrix(i, i)=1-1/num_chans;% was num_chans-1;
end

% start exclude channels
% signalOut1=double(signal)*spatfiltmatrix;
for i=1:length(signal(1,:))
    if ismember(i,chans2incl)==0
        spatfiltmatrix(i,:)=0;
        spatfiltmatrix(:,i)=0;
        spatfiltmatrix(i,i)=1;
    end
end
% end exclude channels

signalOut=signal*spatfiltmatrix;

% clear spatfiltmatrix;