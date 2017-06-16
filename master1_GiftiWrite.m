

bids_rootpath = '/Volumes/DoraBigDrive/data/visual_soc/soc_bids/';
subj = '19';

%% load freesurfer Benson Atlas output and save as gifti in original coordinates

[vertex,face] = read_obj([bids_rootpath '/sub-' subj '/derivatives/RetinotopyTemplates/lh.pial.obj']);
% if still a freesurfer surf file this can be converted to gifti with:
%   mri_convert lh.pial lh.pial.gii
% the following conversion to original space always has to happen!

g.vertices = vertex';
g.faces = face';
g.mat = eye(4,4);
g = gifti(g);

% get tranformation matrix from freesurfer surfaces to original T1 space:
mri_orig = [bids_rootpath '/sub-' subj '/derivatives/RetinotopyTemplates/T1.nii.gz'];
[status,Torig]  = system(['/Applications/freesurfer/bin/mri_info --vox2ras-tkr ' mri_orig]);
Torig = str2num(Torig);
[status,Norig]  = system(['/Applications/freesurfer/bin/mri_info --vox2ras ' mri_orig]);
Norig = str2num(Norig);
freeSurfer2T1 = Norig*inv(Torig);

% convert vertices to original space
vert_mat = double(([g.vertices ones(size(g.vertices,1),1)])');
vert_mat = freeSurfer2T1*vert_mat;
vert_mat(4,:) = [];
vert_mat = vert_mat';
g.vertices = vert_mat; clear vert_mat

%% save as a gifti
gifti_name = [bids_rootpath 'sub-' subj '/anat/sub-' subj '_T1w_pial.L.surf.gii'];

save(g,gifti_name,'Base64Binary')


