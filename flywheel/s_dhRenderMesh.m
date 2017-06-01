%% s_dhRenderGifti
%
%  1.  Find an analysis file, say, '*lh.pial.obj'
%  2.  Download it
%  3.  Run a script on it (master_render_gifti_01)
%  4.  Add the maps
%  5.  Put the result back on the Flywheel
%

%% Open up
st = scitran('action', 'create', 'instance', 'scitran');

%% Check that the toolboxes are in place
project = 'SOC ECoG (Hermes)';
st.toolbox('project',project,'file','toolboxes.json');

%% Find the analysis
clear params
params.filename = 'sub-19';
st.runFunction('ecogRenderMesh.m','project',project,'params',params);

%%