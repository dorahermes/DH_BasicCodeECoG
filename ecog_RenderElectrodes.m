function val = ecog_RenderElectrodes(varargin)
% Overlay electrodes on a brain mesh from FreeSurfer
% 
% Repositories needed
%   vistasoft
%   ecogBasicCode 
%
% DH/BW Vistasoft Team, 2017

%%
val = [];

%%  Open up the object to vistalab
st = scitran('vistalab','verify',true);
chdir(fullfile(ecogRootPath,'local'));
workDir = pwd;

%% Argument checking and toolbox checking

project = 'SOC ECoG (Hermes)';
st.toolbox('project',project,'file','toolboxes.json');

%% Identify

% Get the electrode positions
electrodePositions = st.search('files',...
    'project label',project,...
    'session label','sub-19',...
    'file name','sub-19_loc.tsv');
fnameElectrodes = fullfile(workDir,'sub-19_loc.tsv');
st.get(electrodePositions{1},'destination',fnameElectrodes);

% Get the pial surface from the anatomical
lhPial = st.search('files in analysis',...
    'project label','SOC ECoG (Hermes)',...
    'session label','sub-19',...
    'file name','rt_sub000_lh.pial.obj');
fNamePial = fullfile(workDir,'lhPial.obj');
st.get(lhPial{1},'destination',fNamePial);

% Get information relating the T1 and FreeSurfer coordinates
orig = st.search('files',...
    'project label','SOC ECoG (Hermes)',...
    'session label','sub-19',...
    'acquisition label','anat',...
    'file name','orig.mgz');
fNameOrig = fullfile(workDir,'orig.mgz');
st.get(orig{1},'destination',fNameOrig);

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

ecog_RenderGifti(g)

% Set a good position for the viewer and the light 
ecog_ViewLight(270,0)

% Load and add electrode positions
ePositions = importdata(fnameElectrodes);
elecMatrix = ePositions.data(:,2:4);
ecog_Label(elecMatrix,10,20)

%%

