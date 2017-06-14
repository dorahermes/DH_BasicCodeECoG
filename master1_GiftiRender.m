

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

ecog_renderGifti(g)

% add electrode positions
label_add(elecmatrix,10,20)

% change viewing angle
ecog_ViewLight(270,0)

