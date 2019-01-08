

bids_rootpath = '/Volumes/DoraBigDrive/data/visual_soc/soc_bids/';
subj = '19';
hemi_sm='l';
hemi_cap='L';

%%
% Convert a Freesurfer Pial Rendering to a gifti file
% Coordinates are converted to original MRI coordinatated

% GIFTI file
% if still a freesurfer surf file this can be converted to gifti with:
mris_convert lh.pial lh.pial.gii
gifti(lh.pial.gii)

% the following conversion to original space always has to happen!
% get tranformation matrix from freesurfer surfaces to original T1 space:

mri_orig = ([bids_rootpath 'sub-' subj '/derivatives/RetinotopyTemplates/rt_sub-' subj '/mri/orig.mgz']);
orig = MRIread(mri_orig);
Torig = orig.tkrvox2ras;
Norig = orig.vox2ras;
freeSurfer2T1 = Norig*inv(Torig);

% convert vertices to original space
vert_mat = double(([g.vertices ones(size(g.vertices,1),1)])');
vert_mat = freeSurfer2T1*vert_mat;
vert_mat(4,:) = [];
vert_mat = vert_mat';
g.vertices = vert_mat; clear vert_mat

%% save as a gifti
gifti_name = [bids_rootpath 'sub-' subj '/anat/sub-' subj '_T1w_pial.' hemi_cap '.surf.gii'];

save(g,gifti_name,'Base64Binary')

 
%% Load the gifti and render with Destrieux labels:
%%

clear all 
close all 

bids_rootpath = '/Volumes/DoraBigDrive/data/visual_soc/soc_bids/';
subj = '19';
hemi_sm='l';
hemi_cap='L';

% load electrode positions
loc_info = importdata([bids_rootpath '/sub-' subj '/ses-01/ieeg/sub-' subj '_loc.tsv']);
elecmatrix = loc_info.data(:,2:4);

% load gifti surface (generated from lh.pial)
g = gifti([bids_rootpath 'sub-' subj '/ses-01/anat/sub-' subj '_T1w_pial.' hemi_cap '.surf.gii']);

%% get the Destrieux labels:

fname_destrieux = [bids_rootpath 'sub-' subj '/ses-01/derivatives/RetinotopyTemplates/rt_sub000/label/' hemi_sm 'h.aparc.a2009s.annot'];
[averts,albl,actbl]=read_annotation(fname_destrieux); % [vertices, label, colortable]
%%%% can plot now, but colortable is a hassle...


%% try ielvis?
addpath(genpath('/Users/dora/Documents/git/iELVis'))

cfg=[];
cfg.view='l';
cfg.overlayParcellation='D';
cfg.title='PT001: Destrieux Atlas'; 
cfgOut=plotPialSurf('PT001',cfg);

% this goes wrong, because searing for PT001 in a freesurfer dir... can
% plot if I change these...
       
        