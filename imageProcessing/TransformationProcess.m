classdef TransformationProcess < ImageProcessingProcess
    
    %A class for applying spatial transformations to images using
    %transformMovie.m
    %
    %Hunter Elliott, 5/2010
    %
    
    
    methods (Access = public)
        
        
        function obj = TransformationProcess(owner,outputDir,funParams,...                                              
                                              inImagePaths,outImagePaths,...
                                              transformFilePath)
            
            if nargin == 0
                super_args = {};
            else

                super_args{1} = owner;
                super_args{2} = 'Transformation';
                super_args{3} = @transformMovie;
                
                if nargin < 3 || isempty(funParams)                                                        
                    
                    %------Defaults-------%
                    funParams.OutputDirectory = ...
                    [outputDir  filesep 'transformed_images'];  
                    funParams.ChannelIndex = 1 : numel(owner.channels_);
                    funParams.TransformFilePaths = cell(1,numel(owner.channels_));%No default...
                    funParams.TransformMasks = true;
                    funParams.SegProcessIndex = []; %No Default
                    funParams.BatchMode = false;                                                            
                    
                end
                
                super_args{4} = funParams;
                
                if nargin > 3
                    super_args{5} = inImagePaths;
                end
                if nargin > 4
                    super_args{6} = outImagePaths;
                end
                                
            end
            
            obj = obj@ImageProcessingProcess(super_args{:});
            
            if nargin > 5                
                setTransformFilePath(transformFilePath);
            end
            
        end                 
        
        function setTransformFilePath(obj,iChan,transformPath)                                   
        
            %Make sure the specified channels are valid
            if ~obj.checkChanNum(iChan)
                error('The channel indices specified for transform files are invalid!')
            end
                
            %If only one transform path was input, convert to a cell
            if ~iscell(transformPath)
                transformPath = {transformPath};
            end            
            if length(iChan) ~= length(transformPath)
                error('A sparate path must be specified for each channel!')
            end

            for j = 1:length(iChan)

                if exist(transformPath{j},'file')
                    obj.funParams_.TransformFilePaths{iChan(j)} = transformPath{j};
                else
                   error(['The transform file name specified for channel ' ...
                       num2str(iChan(j)) ' is not valid!!']) 
                end
            end
            
        end
        
        function transforms = getTransformation(obj,iChan)                                                                        
            
            %Loads and checks specified transformation(s).            
            if ~ obj.checkChanNum(iChan)
                error('Invalid channel index!')
            end
            
            nChan = length(iChan);
            transforms = cell(1,nChan);
            
            for j = 1:nChan   
                
                tmp = load(obj.funParams_.TransformFilePaths{iChan(j)});
                
                fNames = fieldnames(tmp);
                
                isXform = cellfun(@(x)(istransform(tmp.(x))),fNames);
                
                if ~any(isXform)
                    error(['The transform file specified for channel ' ...
                        num2str(iChan(j)) ...
                        '  does not contain a valid image transformation!']);
                elseif sum(isXform) > 1
                    error(['The transform file specified for channel ' ...
                        num2str(iChan(j)) ...
                        '  contains more than one valid image transformation!']);
                else                
                    transforms{j} = tmp.(fNames{isXform});
                end
                    
                
            end
            
        end  
        function h = resultDisplay(obj)
            
            %Overrides the default result display so the transformed image can be
            %compared to the other channels.
            
            
            %Now Give the user the option to compare the alignment between
            %two channels
            
            %Find out which channel(s) have been transformed
            hasX = obj.checkChannelOutput;
            iHasX = find(hasX);
            if numel(iHasX) > 1
                chanList = arrayfun(@(x)(['Channel ' num2str(x)]),...
                                      iHasX,'UniformOutput',false);
                                  
                iXchan = listdlg('ListString',chanList,'ListSize',[500 500],...
                            'SelectionMode','single',...
                            'PromptString','Select a transformed channel to view:');                        
                            
                if isempty(iXchan)                
                    h = 1000;%Return SOMETHING so charles' gui doesn't go nuts
                    return
                else
                    iXchan = iHasX(iXchan);
                end
            elseif numel(iHasX) == 1
                iXchan = iHasX;
            else
                error('There are no transformed channels to view!')
            end
            
            
            chanList = arrayfun(@(x)(['Channel ' num2str(x)]),...
                    1:numel(obj.owner_.channels_),'UniformOutput',false);
                
            iComp = listdlg('ListString',chanList,'ListSize',[500 500],...
                            'SelectionMode','single',...
                            'PromptString','Select a channel to compare transformed channel to:');
                        
            if isempty(iComp)
                h = 1000;
                return
            end
            
            nIm = obj.owner_.nFrames_;
            
            %Load and display the images.
            compDir = obj.owner_.channels_(iComp).channelPath_;
            compName = obj.owner_.getImageFileNames(iComp);
            compIm1 = imread([compDir filesep compName{1}{1}]);
            
            xDir = obj.outImagePaths_{iXchan};
            xName = obj.getOutImageFileNames(iXchan);
            xIm1 = imread([xDir filesep xName{1}{1}]);
            
            h = fsFigure(.75);
            
            if nIm > 1
                compIm2 = imread([compDir filesep compName{1}{end}]);
                xIm2 = imread([xDir filesep xName{1}{end}]);
                subplot(1,2,1)               
            end
            image(cat(3,mat2gray(xIm1),mat2gray(compIm1),zeros(size(compIm1))));
            axis image,axis off
            title({'Transformed image (Red) and comparison image (green)','Overlay of frame 1'})
            if nIm > 1
                subplot(1,2,2)
                image(cat(3,mat2gray(xIm2),mat2gray(compIm2),zeros(size(compIm1))));
                title(['Overlay of frame ' num2str(nIm)])
                axis image,axis off
            end                        
                
        end
        
    end
    
    
    
    methods (Static)
        function text = getHelp(all)
            %Note: This help is designed for the GUI, and is a simplified
            %and shortened version of the help which can be found in the
            %function.
            if nargin < 1  % Static method does not have object as input
                all = false;
            end
            description = 'This process can be used to align or "register" the images in different channels. Spatial misalignment between image channels is primarily an issue when multiple cameras are used to acquire the different images, but is occasionally still an issue near the edges of images taken with a single camera, primarily due to chromatic aberration. Misalignment between the channels can cause serious artifacts in the ratio image, especially near the edge of the fluorescent objects. This function can transform one image so that it aligns with the other, eliminating these artifacts. First, a transform must be created using the function calculateMovieTransform.m - see the user''s manual for more details. For normal ratio imaging, the localization channel and activation channels (e.g. Donor and FRET) must be aligned. If bleedthrough correction is to be performed, the bleed channels should also be aligned with the activation channel. Alignment between pairs of channels may be visually verified by clicking the "Result" button.';
            paramList = {'Input Channels',...
                         'Transformation Data',...
                         'Mask Transformation'};
                         
                         
            paramDesc = {'This allows you to select which channels you want to transform. This should be applied to ONE of the two channels that are going to be used for ratioing (usually the numerator, or FRET channel). Additionally, if bleedthrough correction is to be applied, any channels that will be used in this correction may need to be transformed.',...
                         'This allows you to specify the location of a file which contains the transformation to be applied to the images in each input channel. If only one file is specified, it will be used for all selected channels. Alternatively, one transformation file per-channel may be specified. This transformation is usually determined using alignment images taken in each channel, either of a grid micrometer, or multispectral beads, and can be created from these type of images using calculateMovieTransform.m - see the user''s manual for more details.',...
                         'If this box is checked, the masks for the channel to be transformed will also be transformed. This is generally recommended, especially if the ratios are to be masked later on.'};
                         
            if all
                text = makeHelpText(description,paramList,paramDesc);
            else
                text = makeHelpText(description);
            end
             
        end
    end    
end

