function MD = bfImport(dataPath,varargin)
% BFIMPORT imports movie files into MovieData objects using Bioformats
%
% MD = bfimport(dataPath)
% MD = bfimport(dataPath, false)
% MD = bfimport(dataPath, 'outputDirectory', outputDir)
%
% Load proprietary files using the Bioformats library. Read the metadata
% that is associated with the movie and the channels and set them into the
% created movie objects.
%
% Input:
%
%   dataPath - A string containing the full path to the movie file.
%
%   importMetadata - A flag specifying whether the movie metadata read by
%   Bio-Formats should be copied into the MovieData. Default: true.
%
%   Optional Parameters :
%       ('FieldName' -> possible values)
%
%       outputDirectory - A string giving the directory where to save the
%       created MovieData as well as the analysis output. In the case of
%       multi-series images, this string gives the basename of the output
%       folder and will be exanded as basename_sxxx for each movie
%
% Output:
%
%   MD - A single MovieData object or an array of MovieData objects
%   depending on the number of series in the original images.

% Sebastien Besson, Dec 2011 (last modifier Apr 2015)

% Input check
ip=inputParser;
ip.addRequired('dataPath',@ischar);
ip.addOptional('importMetadata',true,@islogical);
ip.addParamValue('outputDirectory',[],@ischar);
ip.addParamValue('askUser', false, @isscalar);
ip.parse(dataPath,varargin{:});

% Retrieve the absolute path of the image file
[status, f] = fileattrib(dataPath);
assert(status, '%s is not a valid path', dataPath);
assert(~f.directory, '%s is a directory', dataPath);
dataPath = f.Name;

try
    % autoload java path and configure log4j
    bfInitLogging();
    % Retrieve movie reader and metadata
    r = loci.formats.Memoizer(bfGetReader(),0);
    r.setId(dataPath);
    r.setSeries(0);
catch bfException
    ME = MException('lccb:import:error','Import error');
    ME = ME.addCause(bfException);
    throw(ME);
end

% Read number of series and initialize movies
nSeries = r.getSeriesCount();
MD(1, nSeries) = MovieData();

% Set output directory (based on image extraction flag)
[mainPath, movieName, movieExt] = fileparts(dataPath);
token = regexp([movieName,movieExt], '^(.+)\.ome\.tiff{0,1}$', 'tokens');
if ~isempty(token), movieName = token{1}{1}; end

if ~isempty(ip.Results.outputDirectory)
    mainOutputDir = ip.Results.outputDirectory;
else
    mainOutputDir = fullfile(mainPath, movieName);
end

% Create movie channels
nChan = r.getSizeC();
movieChannels(nSeries, nChan) = Channel();

for i = 1 : nSeries
    fprintf(1,'Creating movie %g/%g\n',i,nSeries);
    iSeries = i-1;
    
    % Read movie metadata using Bio-Formats
    if ip.Results.importMetadata
        movieArgs = getMovieMetadata(r, iSeries);
    else
        movieArgs = {};
    end
    
    % Read number of channels, frames and stacks
    nChan =  r.getMetadataStore().getPixelsSizeC(iSeries).getValue;
    
    % Generate movie filename out of the input name
    if nSeries>1
        sString = num2str(i, ['_s%0' num2str(floor(log10(nSeries))+1) '.f']);
        outputDir = [mainOutputDir sString];
        movieFileName = [movieName sString '.mat'];
    else
        outputDir = mainOutputDir;
        movieFileName = [movieName '.mat'];
    end
    
    % Create output directory
    if ~isdir(outputDir), mkdir(outputDir); end
    
    for iChan = 1:nChan
        
        if ip.Results.importMetadata
            channelArgs = getChannelMetadata(r, iSeries, iChan-1);
        else
            channelArgs = {};
        end
        
        % Create new channel
        movieChannels(i, iChan) = Channel(dataPath, channelArgs{:});
    end
    
    % Create movie object
    MD(i) = MovieData(movieChannels(i, :), outputDir, movieArgs{:});
    MD(i).setPath(outputDir);
    MD(i).setFilename(movieFileName);
    MD(i).setSeries(iSeries);
    MD(i).setReader(BioFormatsReader(dataPath, iSeries, 'reader', r));
    
    if ip.Results.askUser,
        status = exist(MD(i).getFullPath(), 'file');
        if status
            msg = ['The output file %s already exist on disk. ' ...
                'Do you want to overwrite?'];
            answer = questdlg(sprintf(msg, MD(i).getFullPath()));
            if ~strcmp(answer, 'Yes'), continue; end
        end
    end
    % Close reader and check movie sanity
    MD(i).sanityCheck;
    
end

function movieArgs = getMovieMetadata(r, iSeries)

import ome.units.UNITS;

% Create movie metadata cell array using read metadata
movieArgs={};
metadataStore = r.getMetadataStore();

% Retrieve pixel size along the X-axis
pixelSize = [];
pixelSizeX = metadataStore.getPixelsPhysicalSizeX(iSeries);
if ~isempty(pixelSizeX)
    pixelSize = pixelSizeX.value(ome.units.UNITS.NM).doubleValue();
end

% Retrieve pixel size along the Y-axis
pixelSizeY = metadataStore.getPixelsPhysicalSizeY(iSeries);
if ~isempty(pixelSizeY)
    if ~isempty(pixelSizeX)
        pixelSizeY = pixelSizeY.value(ome.units.UNITS.NM).doubleValue();
        assert(isequal(pixelSizeX, pixelSizeY),...
            'Pixel size different in x and y');
    else
        pixelSize = pixelSizeY.value(ome.units.UNITS.NM).doubleValue();
    end
end

if ~isempty(pixelSize) && pixelSize ~= 1000  % Metamorph fix
    movieArgs = horzcat(movieArgs, 'pixelSize_', pixelSize);
end

% Retrieve pixel size along the Z-axis
pixelSizeZ = metadataStore.getPixelsPhysicalSizeZ(iSeries);
if ~isempty(pixelSizeZ)
    pixelSizeZ = pixelSizeZ.value(ome.units.UNITS.NM).doubleValue();
    if pixelSizeZ ~= 1000  % Metamorph fix
        movieArgs = horzcat(movieArgs, 'pixelSizeZ_', pixelSizeZ);
    end
end

% Camera bit depth
camBitdepth = metadataStore.getPixelsSignificantBits(iSeries);
hasValidCamBitDepth = ~isempty(camBitdepth) && mod(camBitdepth.getValue(), 2) == 0;
if hasValidCamBitDepth
    movieArgs=horzcat(movieArgs,'camBitdepth_',camBitdepth.getValue());
end

% Time interval
timeInterval = metadataStore.getPixelsTimeIncrement(iSeries);
if ~isempty(timeInterval)
    movieArgs=horzcat(movieArgs,'timeInterval_',double(timeInterval));
end

% Lens numerical aperture
if metadataStore.getInstrumentCount() > 0 &&...
        metadataStore.getObjectiveCount(0) > 0
    lensNA = metadataStore.getObjectiveLensNA(0,0);
    if ~isempty(lensNA)
        movieArgs=horzcat(movieArgs,'numAperture_',double(lensNA));
    elseif ~isempty(metadataStore.getObjectiveID(0,0))
        % Hard-coded for deltavision files. Try to get the objective id and
        % read the objective na from a lookup table
        tokens=regexp(char(metadataStore.getObjectiveID(0,0).toString),...
            '^Objective\:= (\d+)$','once','tokens');
        if ~isempty(tokens)
            [na,mag]=getLensProperties(str2double(tokens),{'na','magn'});
            movieArgs=horzcat(movieArgs,'numAperture_',na,'magnification_',mag);
        end
    end
end

acquisitionDate = metadataStore.getImageAcquisitionDate(iSeries);
if ~isempty(acquisitionDate)
    % The acquisition date is returned as an ome.xml.model.primitives.Timestamp
    % object which is using the ISO 8601 format
    movieArgs=horzcat(movieArgs, 'acquisitionDate_',...
        datevec(char(acquisitionDate.toString()),'yyyy-mm-ddTHH:MM:SS'));
end


function channelArgs = getChannelMetadata(r, iSeries, iChan)

import ome.units.UNITS;

channelArgs={};

% Read channel name
channelName = r.getMetadataStore().getChannelName(iSeries, iChan);
if ~isempty(channelName)
    channelArgs=horzcat(channelArgs, 'name_', char(channelName));
end

% Read excitation wavelength
exwlgth=r.getMetadataStore().getChannelExcitationWavelength(iSeries, iChan);
if ~isempty(exwlgth)
    exwlgth = exwlgth.value(UNITS.NM).doubleValue();
    channelArgs=horzcat(channelArgs, 'excitationWavelength_', exwlgth);
end

% Fill emission wavelength
emwlgth=r.getMetadataStore().getChannelEmissionWavelength(iSeries, iChan);
if ~isempty(emwlgth)
    emwlgth = emwlgth.value(UNITS.NM).doubleValue();
    channelArgs = horzcat(channelArgs, 'emissionWavelength_', emwlgth);
end

% Read imaging mode
acquisitionMode = r.getMetadataStore().getChannelAcquisitionMode(iSeries, iChan);
if ~isempty(acquisitionMode),
    acquisitionMode = char(acquisitionMode.toString);
    switch acquisitionMode
        case {'TotalInternalReflection','TIRF'}
            channelArgs = horzcat(channelArgs, 'imageType_', 'TIRF');
        case 'WideField'
            channelArgs = horzcat(channelArgs, 'imageType_', 'Widefield');
        case {'SpinningDiskConfocal','SlitScanConfocal','LaserScanningConfocalMicroscopy'}
            channelArgs = horzcat(channelArgs, 'imageType_', 'Confocal');
        otherwise
            disp('Acqusition mode not supported by the Channel object');
    end
end

% Read fluorophore
fluorophore = r.getMetadataStore().getChannelFluor(iSeries, iChan);
if ~isempty(fluorophore),
    fluorophores = Channel.getFluorophores();
    isFluorophore = strcmpi(fluorophore, fluorophores);
    if ~any(isFluorophore),
        disp('Fluorophore not supported by the Channel object');
    else
        channelArgs = horzcat(channelArgs, 'fluorophore_',...
            fluorophores(find(isFluorophore, 1)));
    end
end
