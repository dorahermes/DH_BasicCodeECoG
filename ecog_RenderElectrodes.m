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

%% Argument checking and toolbox checking

project = 'SOC ECoG (Hermes)';
st.toolbox('project',project,'file','toolboxes.json');

%%
chdir(fullfile(ecogRootPath,'local'));
workDir = pwd;

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

% Get Wang and Kastner color labels for the mesh
labels = st.search('files',...
    'project label','SOC ECoG (Hermes)',...
    'session label','sub-19',...
    'acquisition label','anat',...
    'file name','lh.wang2015_atlas.mgz');
fNameLabel = fullfile(workDir,'lh.wang2015_atlas.mgz');
st.get(labels{1},'destination',fNameLabel);

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

%% Renders the brain and electrodes
figure
ecog_RenderGifti(g)

% Set a good position for the viewer and the light 
ecog_ViewLight(270,0)

% Load and add electrode positions
ePositions = importdata(fnameElectrodes);
elecMatrix = ePositions.data(:,2:4);
ecog_Label(elecMatrix,10,20)

%% Renders the brain with colors and electrodes 

surface_labels = MRIread(fNameLabel);
vert_label = surface_labels.vol(:);

cmap = 'lines';
% cmap = lines(max(vert_label));
Wang_ROI_Names = {...
    'V1v' 'V1d' 'V2v' 'V2d' 'V3v' 'V3d' 'hV4' 'VO1' 'VO2' 'PHC1' 'PHC2' ...
    'TO2' 'TO1' 'LO2' 'LO1' 'V3B' 'V3A' 'IPS0' 'IPS1' 'IPS2' 'IPS3' 'IPS4' ...
    'IPS5' 'SPL1' 'FEF'};

fid = figure;

ecog_RenderGiftiLabels(g,vert_label,cmap,Wang_ROI_Names)
el_add(elecMatrix,'k',30)
el_add(elecMatrix,[.9 .9 .9],20)


%%

