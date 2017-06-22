function ecog_RenderElectrodes()
% Download pial surface from FreeSurfer and overlay electrodes for
% visualization
%
% 
% DH/BW Vistasoft Team, 2017
%
% Repositories needed
%   vistasoft
%   ecogBasicCode 
%
% TODO:
%    Try to use objRead and objWrite for now.
%    We may end up deleting read_obj() from vistasoft in the end

%%  Open up the object to vistalab
st = scitran('vistalab','verify',true);
chdir(fullfile(ecogRootPath,'local'));
workDir = pwd;

%% Argument checking and toolbox checking


%% Identify

% Get the electrode positions
electrodePositions = st.search('files',...
    'project label','SOC ECoG (Hermes)',...
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

%%

% Read the pial surface
[vertex,face] = read_obj(fNamePial);
% Not working properly.
% We should check
% OBJ = objRead(fNamePial);

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

% Renders the brain
ecog_RenderGifti(g)

% Set a good position for the viewer and the light 
ecog_ViewLight(270,0)

% Load and add electrode positions
ePositions = importdata(fnameElectrodes);
elecMatrix = ePositions.data(:,2:4);
ecog_Label(elecMatrix,10,20)

%% save as a gifti

% gifti_name = [bids_rootpath 'sub-' subj '/anat/sub-' subj '_T1w_pial.L.surf.gii'];
% 
% save(g,gifti_name,'Base64Binary')


%% TODO

% obj to gifti
% gifti to obj
% include color 
 
% make a function for surf2native_coordinates;

