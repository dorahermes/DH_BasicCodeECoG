
addpath(genpath('/Users/dorahermes-miller/Documents/github/client'))
addpath(genpath('/Users/dorahermes-miller/Documents/github/ecogBasicCode'))

st = scitran('vistalab');
% paste https://flywheel.scitran.stanford.edu
% paste the key from the flywheel website (under name/APIkey and then only
% the numbers after flywheel.scitran.edu:)

st.runFunction('ecog_RenderElectrodes.m','project','SOC ECoG (Hermes)',...
    'destination','~/Documents/github/ecogBasicCode/local/');

params.views = [-89:1:90; -10*ones(1,180)]';
st.runFunction('ecog_RenderElectrodesMovie.m','project','SOC ECoG (Hermes)',...
    'destination','~/Documents/github/ecogBasicCode/local/',...
    'params',params);