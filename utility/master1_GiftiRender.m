
%%
%% Render without labels
%%

clear all
close all
bids_rootpath = '/Volumes/DoraBigDrive/data/visual_soc/soc_bids/';
subj = '19';

% load electrode positions
loc_info = importdata([bids_rootpath '/sub-' subj '/ieeg/sub-' subj '_loc.tsv']);
elecmatrix = loc_info.data(:,2:4);

% load gifti
g = gifti([bids_rootpath 'sub-' subj '/anat/sub-' subj '_T1w_pial.L.surf.gii']);

%% render gifti
figure

ecog_RenderGifti(g)

% change viewing angle
ecog_ViewLight(270,0)

% add electrode positions
label_add(elecmatrix,10,20)

%%
%% render gifti with Wang/Kastner labels
%%

clear all 
close all 

bids_rootpath = '/Volumes/DoraBigDrive/data/visual_soc/soc_bids/';
subj = '19';

% load electrode positions
loc_info = importdata([bids_rootpath '/sub-' subj '/ieeg/sub-' subj '_loc.tsv']);
elecmatrix = loc_info.data(:,2:4);

% load gifti surface (generated from lh.pial)
g = gifti([bids_rootpath 'sub-' subj '/anat/sub-' subj '_T1w_pial.L.surf.gii']);

%% load surface labels
% the nice thing about the gifti surface generated from the lh.pial.surf is
% that the map labels from the Atlas already correspond to all vertices

surface_labels_name = [bids_rootpath 'sub-' subj '/derivatives/RetinotopyTemplates/rt_sub000/surf/lh.wang2015_atlas.mgz'];
surface_labels = MRIread(surface_labels_name);
vert_label = surface_labels.vol(:);

% cmap = 'lines';
cmap = lines(max(vert_label));
Wang_ROI_Names = {...
    'V1v' 'V1d' 'V2v' 'V2d' 'V3v' 'V3d' 'hV4' 'VO1' 'VO2' 'PHC1' 'PHC2' ...
    'TO2' 'TO1' 'LO2' 'LO1' 'V3B' 'V3A' 'IPS0' 'IPS1' 'IPS2' 'IPS3' 'IPS4' ...
    'IPS5' 'SPL1' 'FEF'};

fid = figure;

ecog_RenderGiftiLabels(g,vert_label,cmap,Wang_ROI_Names)
el_add(elecmatrix,'k',30)
el_add(elecmatrix,[.9 .9 .9],20)

ecog_ViewLight(-89,-10)

set(gcf,'PaperPositionMode','auto')
print('-dpng','-r300',['./local/sub-' subj '_render_v-89-10'])



%% write a video
% 
% videoname = [bids_rootpath 'sub-' subj '/KastnerLabels_Render_V01'];
% 
% vidObj = VideoWriter(videoname,'MPEG-4'); %
% 
% open(vidObj); 
% 
% views_play = [-89:1:90; -10*ones(1,180)]';
% 
% for k = 1:size(views_play,1)
%     if mod(k,10)==0;
%         disp(['frame ' int2str(k)])
%     end
% 
%     ecog_ViewLight(views_play(k,1),views_play(k,2))
% 
%     % Write each frame to the file.
%     for m=1:3 % write X frames
%         writeVideo(vidObj,getframe(fid));
%     end
%     
% end
% 
% close(vidObj);


%%
%% render gifti with Benson labels
%%

clear all 

bids_rootpath = '/Volumes/DoraBigDrive/data/visual_soc/soc_bids/';
subj = '19';

% load electrode positions
loc_info = importdata([bids_rootpath '/sub-' subj '/ieeg/sub-' subj '_loc.tsv']);
elecmatrix = loc_info.data(:,2:4);

% load gifti surface (generated from lh.pial)
g = gifti([bids_rootpath 'sub-' subj '/anat/sub-' subj '_T1w_pial.L.surf.gii']);

%% load surface labels
% the nice thing about the gifti surface generated from the lh.pial.surf is
% that the map labels from the Atlas already correspond to all vertices

% surface_labels_name = [bids_rootpath 'sub-' subj '/derivatives/RetinotopyTemplates/rt_sub000/surf/lh.template_areas.mgz'];
% surface_labels_name = [bids_rootpath 'sub-' subj '/derivatives/RetinotopyTemplates/rt_sub000/surf/lh.template_angle.mgz'];
surface_labels_name = [bids_rootpath 'sub-' subj '/derivatives/RetinotopyTemplates/rt_sub000/surf/lh.template_eccen.mgz'];

surface_labels = MRIread(surface_labels_name);
vert_label = surface_labels.vol(:);

% cmap = 'lines';
% cmap = lines(max(vert_label));% area
% cmap = jet(ceil(max(vert_label)));% angle
cmap = [jet(15); repmat([0.6 0 0],ceil(max(vert_label))-15,1)];% eccentricity
Benson_ROI_Names = {'V1' 'V2' 'V3'};

fid = figure;

% ecog_RenderGiftiLabels(g,vert_label,cmap,Benson_ROI_Names)
ecog_RenderGiftiLabels(g,vert_label,cmap,[1:size(cmap,1)])
el_add(elecmatrix,'k',30)
el_add(elecmatrix,[.9 .9 .9],20)
