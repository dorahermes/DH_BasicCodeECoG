
% write gifti from freesurfer:
%   mris_convert lh.pial lh.pial.gii

% load gifti file:
g           = gifti('/Volumes/DoraBigDrive/data/ctmr_utrecht/FreeSurfer/coevorden/surf/lh.pial.gii');
% original fMRI:
mri_orig    = '../FreeSurfer/coevorden/mri/orig.mgz';
% get electrodes
load('./coevorden_electrodes_surface_loc_all1_FreeSurfer.mat')
% % get cortex - to check
% load('./coevorden_L_cortex.mat')


%% convert to orig space - to match electrode coordinates

% VERTICES
vert_mat = double(([g.vertices ones(size(g.vertices,1),1)])');
[status,Torig]  = system(['/Applications/freesurfer/bin/mri_info --vox2ras-tkr ' mri_orig]);
Torig = str2num(Torig);
[status,Norig]  = system(['/Applications/freesurfer/bin/mri_info --vox2ras ' mri_orig]);
Norig = str2num(Norig);
gifti_cortex.vert = Norig*inv(Torig)*vert_mat;
gifti_cortex.vert(4,:) = [];
gifti_cortex.vert = gifti_cortex.vert';

% TRIANGLES
gifti_cortex.tri = double(g.faces);


%% PLOT using ctmr_gauss_plot

ctmr_gauss_plot(gifti_cortex,[0 0 0],0)
label_add(elecmatrix)


%%
%% plot gifti using Matlab trimesh

g = gifti('./sub-19/anat/sub-19_T1w_pial.L.surf.gii')
c = zeros(size(g.vertices,1),3)+.5;
tH = trimesh(g.faces, g.vertices(:,1), g.vertices(:,2), g.vertices(:,3), c); axis equal; hold on
set(tH, 'LineStyle', 'none', 'FaceColor', 'interp', 'FaceVertexCData',c)
% colormap(cmap); set(gca, 'CLim', [0 255]);

% light('Position',100*[0 -1 1],'Style','local')
l = light;
lighting gouraud
material([.3 .8 .1 10 1]);
axis off
set(gcf,'Renderer', 'zbuffer')
view(270, 0);
set(l,'Position',[-1 0 1]) 

%%
%% PLOT using Matlab (blue...)
%%


g_orig = g;
g_orig.faces = gifti_cortex.tri;
g_orig.vertices = gifti_cortex.vert;
figure,plot(g_orig)