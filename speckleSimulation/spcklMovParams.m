function [frmMeanI,fluorData,params] = spcklMovParams
% SPCKLMOVPARAMS allows user to specify model and imaging parameters

% Currently you must check different files (labeled with "1") depending on
% the model you are using for the simulation:

% CHECK THESE FILES:    params       main       modeln
% model 1                 1           0           1
% model 2                 1           0           0
% model 3                 1           0           1
% model 4                 1           0           0

% check spcklMovMain if you want to change the beginning state
% distributions!

% FOR ALL MODELS ---------------------------

% VALUES FOR params.nModel
% 1 Stationary network, random poly/depoly
% 2 Converging network, either without depoly or depoly so I is constant
% 3 Left-to-right actin (one color) or actin/adhesion (two colors)
% 4 Antiparallel microtubules in bundles
params.nModel = 4;    % model number

% movie parameters
params.imL          = 256;  % image length
params.imW          = 256;  % image width
params.nFrames      = 15;   % number of frames to produce
params.nSecPerFrame = 2;    % frame rate (seconds)
params.intTime      = 0.3;  % exposure time (seconds)
params.dT           = 0.1;  % time between steps (seconds)

% imaging parameters
params.lambdaEmit = 488;    % emission wavelength (nm)
params.na         = 1.45;   % numerical aperture
params.pixNM      = 67;     % real space pixel size (nm)

% size of box used to bin fluorophores - don't need to change
params.sampleScale=floor(params.pixNM/3);   

switch params.nModel
    case 1 % Stationary network, random poly/depoly
        % for this model we have poly/depoly according to the rates set in
        % spcklMovModel1.m. the state of each fluorophore is set in
        % spcklMovMain.m, with half beginning in the unbound state.
        % unbound monomers do not contribute to signal, so the total
        % fluorophores generating signal in this case will be on average
        % half the labeled fraction. the number will go up or down till
        % steady state is reached based on the kinetics.
        
        % be aware that the border used to make the images might not be big
        % enough if the diffusion constant is high.  check the images to
        % see if there is substantial variation at the borders after
        % running it.  you can adjust the borders in spcklMovCalcBorder.m.
        % also be aware that all particles are undergoing same diffusion
        % regardless of whether they are bound or unbound.
        
        params.areaDens = 278;               % actin filaments density (microns/microns^2) - calc to be 278 by Abraham et al 1999
        params.percentLabeledActin = 0.01;   % actually, the fraction of labeled subunits (multiply by 100 to get percent)
        params.D = 10^-17;                % diffusion constant D (cm^2/s), 0 if no diffusion. (D=10^-9 is approx. free protein diffusion in a membrane)

    case 2 % Converging network, either without depoly or depoly so I is constant
        % for this model there is no polymerization and no diffusion
        % (though this could be added in the future). if params.depoly is
        % set to 1, depolymerization occurs at a rate proportional to how
        % far each fluorophore is from the sink (located at params.poleYX),
        % this makes the image intensity uniform everywhere despite massive
        % depoly at the sink.  because there is no poly, we start with all
        % the fluorophores labeled (state = 1), set in spcklMovMain.m.
        % this allows you to have a lower labeled fraction, which is
        % important for memory limitations, since the borders have to be
        % bigger to accomodate inward flow over the image edge.
        
        params.areaDens = 278;               % actin filaments density (microns/microns^2) - calc to be 278 by Abraham et al 1999
        params.percentLabeledActin = 0.001;   % actually, the fraction of labeled subunits (multiply by 100 to get percent)
        params.umPerMinFlowSpeed = 10;      % velocity in microns/min
        
        % [y0 x0] coordinates of the pole (sink) in pixels
        params.poleYX=[]; % use [] to center pole in the image

        % if depoly=1, depoly occurs so that avg intensity stays constant as
        % convergence occurs. if depoly=0, no depoly occurs and the image gets
        % brighter near the pole.
        params.depoly=1;

        % here we calculate flow rate in pixels per frame
        params.pixPerFrame=(1000/60)*params.umPerMinFlowSpeed*(params.nSecPerFrame/params.pixNM);

    case 3 % actin (one color) or actin/adhesion (two colors) flow, one direction
        % ACTIN OR ADHESION CHANNEL
        % to make a one-color movie of just actin, make params.protein=1
        % and change params below. this is essentially the same as running
        % model 1, except here we have actin flow instead of stationary
        % flow and the states are noted by 0 and 2 instead of 0 and 1.
        
        % to make a two-color movie of actin and adhesions, run first with
        % params.protein=1 (actin) and then run again with params.protein=2
        % (adhesion). we essentially treat the adhesion proteins as if they 
        % were actin, but now there are more dynamic states.  actin
        % monomers can only exist in two states (0 or 2), while adhesion
        % proteins can exist in four (0, 1, 2, or 3):
        % 0: unbound
        % 1: bound to substrate (stationary)
        % 2: bound to actin (moving with actin flow speed)
        % 3: bound to both actin and substrate
        
        params.protein = 1; % 1 for actin, 2 for adhesion

        % INITIAL STATE DISTRIBUTIONS
        % if modeling actin (params.protein=1), we assume half the
        % fluorophores are bound and half are unbound.  you can change
        % this in spcklMovMain.m if desired.
        
        % if modeling adhesion (params.protein=2), you can choose your
        % initial distribution of states
        % 1: all unbound
        % 2: all bound to substrate
        % 3: all bound to actin
        % 4: all bound to both substrate and actin
        % 5: random even distribution of monomers in the four states
        % 6: don't allow binding to both substrate and actin simultaneously
        % (no state 3), states distributed equally between 0, 1, and 2
        if params.protein==2
            params.stateDist = 6;
        end
        
        % be aware that the border used to make the images might not be big
        % enough if the diffusion constant is high.  check the images to
        % see if there is substantial variation at the borders after
        % running it.  you can adjust the borders in spcklMovCalcBorder.m.
        % also be aware that all particles are undergoing same diffusion
        % regardless of whether they are bound or unbound.
        
        params.areaDens = 278;               % actin filaments density (microns/microns^2) - calc to be 278 by Abraham et al 1999
        params.percentLabeledActin = 0.01;   % actually, the fraction of labeled subunits (multiply by 100 to get percent)
        params.D = 0; %10^-17;                % diffusion constant D (cm^2/s), 0 if no diffusion. (D=10^-9 is approx. free protein diffusion in a membrane)
        params.umPerMinFlowSpeed = 3.2;      % velocity in microns/min
        params.theta = 180;                   % angle in degrees for flow direction (0 is left-to-right, 45 is top-left to bottom-right, etc.)
        
        % here we calculate flow rate in pixels per frame
        params.pixPerFrame=(1000/60)*params.umPerMinFlowSpeed*(params.nSecPerFrame/params.pixNM);
        
    case 4 % Antiparallel microtubules in bundles

        % mean and sigma for 2 populations of MTs, one fast and one slow
        % (microns/min)
        params.fastFlowMean = 4.8;
        params.fastFlowSigma = 0.3;
        params.slowSpeedMean = 2.3;
        params.slowSpeedSigma = 0.6;

        % labeled fraction of subunits in individual MTs
        params.fractionTuLabeled = 0.0004;
        % labeled fraction of subunits in bundle MTs
        params.effectiveLabeling = 5*params.fractionTuLabeled;
        % fraction from single MT population that move according to fast
        % distribution
        params.fractionFastSingleMTs = 0.50;

        % repeating geometry of parallel units of bundle-space-singleMT-space
        params.nPerBundle=5;    % num MTs in bundle
        params.nSpacers1=1;     % num MT-sized empty spaces between bundle and single MTs
        params.nSingles=1;      % num of single MTs (each has different speed)
        params.nSpacers2=2;     % num MT-sized empty spaces between single MTs and next bundle
       
    otherwise
        error('params.nModel value is incorrect');
end

% run the main function which sets up the directories and makes the movies
[frmMeanI,fluorData,params]=spcklMovMain(params);
