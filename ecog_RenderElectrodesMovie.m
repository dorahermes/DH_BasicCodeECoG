function val = ecog_RenderElectrodesMovie(varargin)
% Overlay electrodes on a brain mesh from FreeSurfer
% and make a movie
%
% val = ecog_RenderElectrodesMovie(views,varargin)
%
% inputs: views: viewing angles to loop through
%   
%
% Example
%   views = [-89:1:90; -10*ones(1,180)]';
%   params.views = views;
%   ecog_RenderElectrodesMovie(params);
%
% Repositories needed
%   vistasoft
%   ecogBasicCode
%   scitran
%
% DH/BW Vistasoft Team, 2017
%%

p = inputParser;
p.addParameter('views',[],@(x)(size(x,2) == 2));
p.addParameter('subjectCode','sub-19',@ischar);

p.parse(varargin{:});

subjectCode = p.Results.subjectCode;
views = p.Results.views;
if isempty(views), error('No views defined.'); end

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
filename = sprintf('%s_loc.tsv',subjectCode);
electrodePositions = st.search('files',...
    'project label',project,...
    'subject code',subjectCode,...
    'file name',filename);
fnameElectrodes = fullfile(workDir,filename);
st.get(electrodePositions{1},'destination',fnameElectrodes);

% Get the pial surface from the anatomical
lhPial = st.search('files in analysis',...
    'project label','SOC ECoG (Hermes)',...
    'subject code',subjectCode,...
    'file name','rt_sub000_lh.pial.obj');
fNamePial = fullfile(workDir,'lhPial.obj');
st.get(lhPial{1},'destination',fNamePial);

% Get information relating the T1 and FreeSurfer coordinates
orig = st.search('files',...
    'project label','SOC ECoG (Hermes)',...
    'subject code',subjectCode,...
    'acquisition label','anat',...
    'file name','orig.mgz');
fNameOrig = fullfile(workDir,'orig.mgz');
st.get(orig{1},'destination',fNameOrig);

% Get Wang and Kastner color labels for the mesh
labels = st.search('files',...
    'project label','SOC ECoG (Hermes)',...
    'subject code',subjectCode,...
    'acquisition label','anat',...
    'file name','lh.wang2015_atlas.mgz');
fNameLabel = fullfile(workDir,'lh.wang2015_atlas.mgz');
st.get(labels{1},'destination',fNameLabel);

% Figure out the transformation matrix from freesurfer to the T1 data
% frame.
origData = MRIread(fNameOrig);
Torig    = origData.tkrvox2ras;
Norig    = origData.vox2ras;
freeSurfer2T1 = Norig/Torig;  % = Norig * inv(Torig);

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

%% Renders the brain with colors and electrodes 

% Import electrode positions
ePositions = importdata(fnameElectrodes);
elecMatrix = ePositions.data(:,2:4);

% Read surface labels
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

videoname = fullfile(workDir,'wang2015_atlas_electrodes_movie'); 

vidObj = VideoWriter(videoname,'MPEG-4'); %

open(vidObj); 

views_play = views;

for k = 1:size(views_play,1)
    if mod(k,10)==0;
        disp(['frame ' int2str(k)])
    end

    ecog_ViewLight(views_play(k,1),views_play(k,2))

    % Write each frame to the file.
    for m=1:3 % write X frames: decides speed
        writeVideo(vidObj,getframe(fid));
    end
    
end

close(vidObj);

%%

