function val = ecog_RenderElectrodes(varargin)
% Overlay electrodes on a brain mesh from FreeSurfer
% 
% Syntax
%   ecog_RenderElectrodes(...)
%
% Description
%
% Inputs (required)
%  None
%
% Inputs (optional)
%   subjectCode
%
% Return
%   
%
% Repositories needed
%   vistasoft
%   ecogBasicCode 
%
% Examples in code
%
% DH/BW Vistasoft Team, 2017
%
% See also scitran.runFunction, 

% st = scitran('vistalab');
% Upload this file
%{
 thisFile = which('ecog_RenderElectrodes.m');
 project = 'SOC ECoG (Hermes)';
 [s,id] = st.exist('project',project);
 st.upload(thisFile,'project',id);
%}

% Example 1 - 
%{
 % Run the local version
 clear params
 params.subjectCode = 'sub-19';
 ecog_RenderElectrodes(params);
%}
% Example 2 -
%{
 % Flywheel downloads and runs local_ecog_RenderElectrodes
 clear params
 params.subjectCode = 'sub-19';
 [s,id] = st.exist('project','SOC ECoG (Hermes)');
 mFile = 'ecog_RenderElectrodes.m';
 if s, st.runFunction(mFile,'container type','project','container ID',id); end
%}

%% 
p = inputParser;

p.addParameter('subjectCode','sub-19',@ischar);

p.parse(varargin{:});

subjectCode = p.Results.subjectCode;

val = [];  % Placeholder.  Not used.

%%  Open up the object to vistalab

st = scitran('vistalab');

project = 'SOC ECoG (Hermes)';

% Check that the required toolboxes are on the path
[~,valid] = st.getToolbox('SOC-ECoG-toolboxes.json',...
    'project name',project,...
    'validate',true);

if ~valid
    error('Please install the SOC-ECoG-toolboxes.json toolboxes on your path'); 
    % We could do this
    %     st.toolbox('SOC-ECoG-toolboxes.json',...
    %     'project',project,...
    %     'install',true);
end

%%
chdir(fullfile(ecogRootPath,'local'));
workDir = pwd;

%% Identify
filename = sprintf('%s_loc.tsv',subjectCode);

% Get the electrode positions
electrodePositions = st.search('file',...
    'project label exact',project,...
    'subject code',subjectCode,...
    'file name',filename);
fnameElectrodes = fullfile(workDir,filename);
st.downloadFile(electrodePositions{1},'destination',fnameElectrodes);

% Get the pial surface from the anatomical
lhPial = st.search('file',...
    'project label exact',project,...
    'subject code',subjectCode,...
    'file name','rt_sub000_lh.pial.obj');
fNamePial = fullfile(workDir,'lhPial.obj');
st.downloadFile(lhPial{1},'destination',fNamePial);

% Get information relating the T1 and FreeSurfer coordinates
orig = st.search('file',...
    'project label exact',project,...
    'subject code',subjectCode,...
    'acquisition label exact','anat',...
    'file name','orig.mgz');
fNameOrig = fullfile(workDir,'orig.mgz');
st.downloadFile(orig{1},'destination',fNameOrig);

% Figure out the transformation matrix from freesurfer to the T1 data
% frame.
origData = MRIread(fNameOrig);
Torig    = origData.tkrvox2ras;
Norig    = origData.vox2ras;
freeSurfer2T1 = Norig/Torig;  % Norig * inv(Torig);s

%%  Build the brain surface

% Read the pial surface
[vertex,face] = read_obj(fNamePial);
% We should check this OBJ reader - OBJ = objRead(fNamePial);

% convert vertices to original space
g.vertices = vertex';
g.faces = face';
g.mat = eye(4,4);
g = gifti(g);

% Convert the vertices into the T1 coordinate frame
vert_mat = double(([g.vertices ones(size(g.vertices,1),1)])');
vert_mat = freeSurfer2T1*vert_mat;
vert_mat(4,:) = [];
vert_mat = vert_mat';
g.vertices = vert_mat; 
clear vert_mat

%% Renders the brain and electrode

stNewGraphWin;

ecog_RenderGifti(g)

% Set a good position for the viewer and the light 
ecog_ViewLight(270,0)

% Load and add electrode positions
ePositions = importdata(fnameElectrodes);
elecMatrix = ePositions.data(:,2:4);
ecog_Label(elecMatrix,10,20)

%%

