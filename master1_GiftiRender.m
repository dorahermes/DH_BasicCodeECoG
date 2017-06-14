

bids_rootpath = '/Volumes/DoraBigDrive/data/visual_soc/soc_bids/';
subj = '19';

%%
%% load electrode positions
loc_info = importdata([bids_rootpath '/sub-' subj '/ieeg/sub-' subj '_loc.tsv']);
elecmatrix = loc_info.data(:,2:4);


%% load gifti
g = gifti([bids_rootpath 'sub-' subj '/anat/sub-' subj '_T1w_pial.L.surf.gii']);


%% render obj
figure
c = zeros(size(g.vertices,1),3)+.5;
tH = trimesh(g.faces, g.vertices(:,1), g.vertices(:,2), g.vertices(:,3), c); axis equal; hold on
set(tH, 'LineStyle', 'none', 'FaceColor', 'interp', 'FaceVertexCData',c)
% colormap(cmap); set(gca, 'CLim', [0 255]);

% light('Position',100*[0 -1 1],'Style','local')
l1 = light;
l2 = light;
l3 = light;
lighting gouraud
material([.3 .8 .1 10 1]);
axis off
set(gcf,'Renderer', 'zbuffer')
view(270, 0);

set(l1,'Position',[-1 0 1])
set(l2,'Position',[-1 0 -1])
set(l3,'Position',[1 0 1])

label_add(elecmatrix,10,20)


