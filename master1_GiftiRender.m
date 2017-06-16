
clear all
close all
bids_rootpath = '/Volumes/DoraBigDrive/data/visual_soc/soc_bids/';
subj = '19';

%%
%% load electrode positions
loc_info = importdata([bids_rootpath '/sub-' subj '/ieeg/sub-' subj '_loc.tsv']);
elecmatrix = loc_info.data(:,2:4);


%% load gifti
g = gifti([bids_rootpath 'sub-' subj '/anat/sub-' subj '_T1w_pial.L.surf.gii']);

%% render gifti
figure

ecog_RenderGifti(g)

% change viewing angle
ecog_ViewLight(270,0)

% add electrode positions
label_add(elecmatrix,10,20)

%%
%%
%% load surface with labels
clear all 
close all 

bids_rootpath = '/Volumes/DoraBigDrive/data/visual_soc/soc_bids/';
subj = '19';

% load electrode positions
loc_info = importdata([bids_rootpath '/sub-' subj '/ieeg/sub-' subj '_loc.tsv']);
elecmatrix = loc_info.data(:,2:4);

% load gifti surface (generated from lh.pial)
g = gifti([bids_rootpath 'sub-' subj '/anat/sub-' subj '_T1w_pial.L.surf.gii']);
%%
% load surface labels
surface_labels_name = [bids_rootpath 'sub-' subj '/derivatives/RetinotopyTemplates/rt_sub000/surf/lh.wang2015_atlas.mgz'];
surface_labels = MRIread(surface_labels_name);
vert_label = surface_labels.vol(:);

cmap = 'lines';
Wang_ROI_Names = {...
    'V1v' 'V1d' 'V2v' 'V2d' 'V3v' 'V3d' 'hV4' 'VO1' 'VO2' 'PHC1' 'PHC2' ...
    'TO2' 'TO1' 'LO2' 'LO1' 'V3B' 'V3A' 'IPS0' 'IPS1' 'IPS2' 'IPS3' 'IPS4' ...
    'IPS5' 'SPL1' 'FEF'};
ecog_RenderGiftiLabels(g,vert_label,cmap,Wang_ROI_Names)

