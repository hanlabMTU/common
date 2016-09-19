function ML=indexLSFMData(moviePaths,movieListAnalysisDir,varargin)
% - If necessary, batch sort time points in ch0/, ch1/ 
% - Optionnaly deskew, dezip on demand)
% - Create movieData and analysis folder for each movie
% - Print MIP in analysis folder
% - Create a movieList saved in an analysis folder below <moviesRoot>
%
% EXAMPLE1:  indexLSFMData(  '/path/to/your/cells/Cell_*/whatever/CAM_0{ch}*.tif','/path/to/your/cells', ... 
%                           'lateralPixelSize',160,'axialPixelSize',400,'timeInterval',0.5,'copyFile',true)
%
% INPUT:  - moviePaths is either: 
%              ** A regular expression describing all the file of intereste using the following format: 
%                '/path/to/cell/Cell_*/path/to/tiff/xp_whatever_chanel_{ch}_*.tif'
%                - each images related to a cell must be in a separate folder
%                - the token {ch} represents the location of the channel number. It is mandatory.  
%                
%              ** a  matlab cell of path  that represent cell  directories containing *.tif files  ( or optionnaly compressed  *.tif.bz2) describing
%                 individual timepoint.
%                 - The option 'filePattern' must thus be used to describe channel name for example: 
%                   'Iter_ sample_scan_3p35ms_zp4um_ch{ch}_stack*'
%
%         - moviesRoot: original root for the list of movies:
%               ** contain the analysis folder with the movieList.mat and
%               associated outputdir
%               **  
%         
%
% OPTION: - newDataPath {[]}: if specificied, all the new
%           cell folders are writen under this folder ( analysis file with MD with or
%           without data) WARNING: 
%         - copyFile {false}: copy of move file. 
%         - copyFile {false}: if true copy the file instead of moving them. 
%         - 'writeData' {true}: If false, do not write data, only create MovieData under movieRoots or  NewDataPath



ip = inputParser;
ip.CaseSensitive = false;
ip.KeepUnmatched = true;
ip.addRequired('moviePaths', @(x)(iscell(x)||ischar(x)));
ip.addRequired('movieListAnalysisDir', @ischar);
ip.addParamValue('movieListName','movieList.mat', @ischar);
ip.addParamValue('movieDataName','movieData.mat', @ischar);
ip.addParamValue('deskew',false, @islogical);
ip.addParamValue('writeData',true, @islogical);
ip.addParamValue('copyFile',false, @islogical);
ip.addParamValue('translocateMovieData',false, @islogical);
ip.addParamValue('createMIP',true, @islogical);
ip.addParamValue('is3D',true, @islogical);
ip.addParamValue('lateralPixelSize',1, @isfloat);
ip.addParamValue('axialPixelSize',1, @isfloat);
ip.addParamValue('timeInterval',1, @isfloat);
ip.addParamValue('newDataPath',[], @ischar);
ip.addParamValue('chStartIdx',1, @isnumeric);
ip.addParamValue('filePattern','Iter_ sample_scan_3p35ms_zp4um_ch{ch}_stack*', @ischar); 
ip.parse(moviePaths,movieListAnalysisDir,varargin{:});

p=ip.Results;
writeData=p.writeData;
    
% Optional regexp processing: 
% - Define a path per cell <moviePaths> from the regexp
% - Define a canonical path for each original channel subfolder <channelOriginalFilePattern> (if there is not subfolder, just the file pattern).
% - Define a cannonical ouput channel subfolder <channelFileOutputPattern> (can be the same as <channelOriginalFilePattern>) (in the non-BF mode).
channelFileOutputPattern=p.filePattern;
channelOriginalFilePattern=p.filePattern;
if(ischar(moviePaths))
    moviePathsRep=strrep(moviePaths,'{ch}',num2str(p.chStartIdx));

    % Initialize a path for each Cell from the regexp
    %fileDirRegexp=fileparts(moviePathsRep);
    
    files=rdir([moviePathsRep]);    % filesep is important due to a bug in rdir ...
    moviePathsRes=unique(cellfun(@(x) fileparts(x),{files.name},'unif',0)); 



    % If {ch} is specified in the folder name then redefine the cell folder. 
    % Otherwise do not change the cell path and create a subfolder
    [fileDirRegexp,fileRegexp,ext]=fileparts(moviePaths);
    if(strfind(fileDirRegexp,'{ch}'))
        channelOriginalFilePattern=[fileRegexp ext];
        while(strfind(fileDirRegexp,'{ch}'))
          [fileDirRegexp,fileRegexp,ext]=fileparts(fileDirRegexp);
           channelOriginalFilePattern=[filesep fileRegexp  filesep channelOriginalFilePattern];
            moviePathsRes=cellfun(@(x) fileparts(x),moviePathsRes,'unif',0);
        end
        channelFileOutputPattern=channelOriginalFilePattern;
    else
        filePattern=[fileRegexp,ext];
        channelFileOutputPattern=[filesep 'ch{ch}' filesep filePattern];
        channelOriginalFilePattern=[filesep filePattern];
        % If no file have been found, maybe the user is trying to relaunch
        % an automated sorting command. 
        if(isempty(moviePathsRes))
           files=rdir([fileDirRegexp filesep 'ch' num2str(p.chStartIdx) filesep]);
           if(~isempty(files))
                channelFileOutputPattern=[filesep 'ch{ch}' filesep filePattern];
                channelOriginalFilePattern=channelFileOutputPattern;
                [moviePathsRes]=unique(cellfun(@(x) [fileparts(fileparts(x)) filesep],{files.name},'unif',0));
           end
        end     
    end
    

    
    moviePaths=moviePathsRes;
    if(isempty(moviePaths))
        warning('Files not found')
    end
end

% Move files if needed, build MovieData and create MIP. 
MDs=cell(1,length(moviePaths));
for cellIdx=1:length(moviePaths)
    cPath=moviePaths{cellIdx};
    channelList=[];

    chIdx=ip.Results.chStartIdx;
    % While there is new channels
    while(true)      

        
        filelistCH=dir([cPath filesep strrep(channelOriginalFilePattern,'{ch}',num2str(chIdx))]);
        outputDirCH=[cPath filesep fileparts(strrep(channelFileOutputPattern,'{ch}',num2str(chIdx)))];
        
        % If this channel does not exist, stop building channels. 
        if(isempty(filelistCH))
           break;
        end
        
        if(~exist(outputDirCH,'dir')) mkdir(outputDirCH); end;
        if( writeData && (~strcmp(channelOriginalFilePattern,channelFileOutputPattern)))
            for fileIdx=1:length(filelistCH)
                file=filelistCH(fileIdx).name;
                if(p.deskew)
                    writeDeskewedFile([cPath filesep file],outputDirCH);
                else
                    if(p.copyFile)
                        copyfile([cPath filesep file],outputDirCH);
                    else
                        movefile([cPath filesep file],outputDirCH);
                    end
                end
                
            end
        end
        channelList=[channelList Channel(outputDirCH)];
        chIdx=chIdx+1;
    end
    

    if(~exist([cPath filesep 'analysis'],'dir')) mkdir([cPath filesep 'analysis']); end
    %%
    MD=[];
    try
    if(~isempty(channelList))
        %%
        MD=MovieData(channelList,[cPath filesep 'analysis'],'movieDataFileName_','movieData.mat','movieDataPath_',[cPath filesep 'analysis'], ...
            'pixelSize_',p.lateralPixelSize,'pixelSizeZ_',p.axialPixelSize,'timeInterval_',p.timeInterval);
        
        if(p.is3D)
            tiffReader=TiffSeriesReader({channelList.channelPath_},'force3D',true);
            MD.setReader(tiffReader);
        end;
        MD.sanityCheck();
        MD.save();
        if(p.is3D)
            if(p.createMIP)
                printMIP(MD);
            end
        end
    else
        warning(['No files found for movie ' num2str(cellIdx)]);
        MD=MovieData([],[cPath filesep 'analysis'],'movieDataFileName_',p.movieDataName,'movieDataPath_',[cPath filesep 'analysis']);
    end;

    MDs{cellIdx}=MD;
    catch
        warning(['Movie building fail, exluding ' cPath ]);
        MDs{cellIdx}=[];
    end
        
end
builtMovies=cellfun(@(x) ~isempty(x),MDs)
MDs=[MDs{builtMovies}];

mkdir([movieListAnalysisDir filesep 'analysis']);
ML=MovieList(MDs,[movieListAnalysisDir filesep 'analysis'],'movieListFileName_',p.movieListName,'movieListPath_',[movieListAnalysisDir filesep 'analysis']);
ML.save();


function writeDeskewedFile(filePath,outputDir)
[~,~,ef]=fileparts(filePath);
written=false;
% This while loop handles server instability
while ~written
    try
        if(strcmp(ef,'.bz2'))
            unzipAndDeskewLatticeTimePoint(filePath,outputDir);
        elseif((strcmp(ef,'.tif')))
            deskewLatticeTimePoint(filePath,outputDir);
        else
            error('unsupported format')
        end
        written=true;
    catch
        written=false;
    end;
end

%% SNIPPETS
%     outputDirFinal=[cPath filesep 'deskew' filesep 'final'];
%     if(~isempty(p.rootPath))
%         outputDirFinal=strrep(outputDirFinal,p.rootPath,p.movieListOutputPath);
%     end
%     mkdir(outputDirFinal);
%     filelistFinal=dir([cPath filesep 'Iter_ sample_scan_3p35ms_zp4um_final*.*']);
%     for fileIdx=1:length(filelistFinal)
%         file=filelistFinal(fileIdx).name;
%         writeDeskewedFile([cPath filesep file],outputDirFinal);
%     end    