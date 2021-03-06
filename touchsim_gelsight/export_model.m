% export_model.m

% publish HMTL documentation
publish_docs

% determine current model version
[~,rev] = system('hg id');
fid = fopen( 'version.txt','wt');
fprintf(fid,[rev '\n']);
fclose(fid);

% generate distOnhand_boundt.mat if it doesn't exist
if ~exist('base/internal/distOnHand_boundt.mat','file')
    cd('base/internal')
    distOnHand_generateboundarytable()
    cd('../..')
end

% list of files to include
files = {...
    ... % root
    'setup_path.m',...
    'version.txt',...
    ... % base/GUI
    'base/GUI/hand.mat',...
    ...'base/GUI/hand.tiff',...
    'base/GUI/hand_gui.m',...
    ... % base/internal
    'base/internal/affcol.m',...
    'base/internal/apply_ramp.m',...
    'base/internal/apply_sine_ramp.m',...
    'base/internal/distOnHand_boundt.mat',...
    'base/internal/distOnHand_generateboundarytable.m',...
    'base/internal/distOnHand.m',...
    'base/internal/hand2pixel.m',...
    'base/internal/IF_ihbasis.m',...
    'base/internal/IF_neuron.m',...
    'base/internal/IF_parameters.m',...
    'base/internal/locate.m',...
    'base/internal/pixel2hand.m',...
    'base/internal/plot_hand.m',...
    'base/internal/plot_spikes.m',...
    'base/internal/print2array.m',...
    'base/internal/rectify.m',...
    'base/internal/sample_random_shape.m',...
    ... % base/model
    'base/model/Afferent.m',...
    'base/model/AfferentPopulation.m',...
    'base/model/affpop_grid.m',...
    'base/model/affpop_hand.m',...
    'base/model/affpop_linear.m',...
    'base/model/affpop_single_models.m',...
    'base/model/Response.m',...
    'base/model/ResponseCollection.m',...
    'base/model/shape_bar.m',...
    'base/model/shape_circle.m',...
    'base/model/shape_letter.m',...
    'base/model/shape_square_grating.m',...
    'base/model/Stimulus.m',...
    'base/model/stim_grasp.m',...
    'base/model/stim_indent_shape.m',...
    'base/model/stim_ramp.m',...
    'base/model/stim_sine.m',...
    ... % base/skinmech
    'base/skinmech/CircIndent2LoadProfile.m',...
    'base/skinmech/CircLoadDynWave.m',...
    'base/skinmech/CircLoadVertStress.m',...
    ... % docs
    'docs/info.xml',...
    'docs/examples.m'
    };

mlist=dir('docs/html/');
for i=1:length(mlist)
    files{length(files)+1} = ['docs/html/' mlist(i).name];
end

% zip everything up
timestr=datestr(now,'yyyy_mm_dd');
zip(['TouchSim_' timestr '.zip'],files)
