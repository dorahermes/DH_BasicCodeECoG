

bids_rootpath = '/Volumes/DoraBigDrive/data/visual_soc/soc_bids/';
subj = '09';
hemi_sm='r';
hemi_cap='R';

%% load freesurfer Benson Atlas output and save as gifti in original coordinates

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

 

