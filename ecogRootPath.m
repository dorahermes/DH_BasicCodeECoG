function rootPath = ecogRootPath()
% Determine path to root of the mrVista directory
%
%        rootPath = ecogRootPath;
%
% This function MUST reside in the directory at the base of the
% ecogBasicCode directory structure 
%
% Copyright Stanford team, mrVista, 2017

rootPath=which('ecogRootPath');

rootPath= fileparts(rootPath);

return
