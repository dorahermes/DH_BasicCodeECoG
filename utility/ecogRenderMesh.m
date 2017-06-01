function g = ecogRenderMesh(varargin)
% Read a freesurfer pial obj file and render it as a gifti
%
%
% ecogRenderMesh;

%%
p = inputParser;
p.addParameter('filename','lh.pial.obj',@ischar);
p.addParameter('session','sub-19',@ischar);

p.parse(varargin{:});

filename = p.Results.filename;
session  = p.Results.session;
project  = 'SOC ECoG (Hermes)';

%% Get the obj file from Flywheel
st = scitran('action', 'create', 'instance', 'scitran');

file = st.search('files in analysis',...
    'project label',project,...
    'session label',session,...
    'filename',filename,...
    'summary',true);

objFile = fullfile(ecogRootPath,'local',filename);
st.get(file{1},'destination',objFile);

%% Read the obj file
%
% Note:  Could use this gifti library if we like
% https://www.artefact.tk/software/matlab/gifti/

% Read obj file and visualize it in Matlab with trimesh.
[g.vertices,g.faces] = read_obj(objFile);
g.vertices = single(g.vertices');
g.faces = int32(g.faces');
g.mat = eye(4,4);

%% Render
c = zeros(size(g.vertices,1),3)+.5;
tH = trimesh(g.faces, g.vertices(:,1), g.vertices(:,2), g.vertices(:,3), c); 

axis equal; hold on
set(tH, 'LineStyle', 'none', 'FaceColor', 'interp', 'FaceVertexCData',c)
l = light; lighting gouraud
material([.3 .8 .1 10 1]);
axis off; view(270, 0);
set(gcf,'Renderer', 'zbuffer')
set(l,'Position',[-1 0 1]) 

end

