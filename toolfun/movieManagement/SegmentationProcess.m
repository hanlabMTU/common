classdef SegmentationProcess < Process
% A concrete process for mask process info
    properties (SetAccess = private, GetAccess = public)
    % SetAccess = private - cannot change the values of variables outside object
    % GetAccess = public - can get the values of variables outside object without
    % definging accessor functions
    
       outMaskPaths_             %Folders containing output masks.
       
       maskRefineProcess_  = [ ]; % The mask refinement process pointer
                                 % Used when a segmentation process needs
                                 % postprocessing

    end
    
    methods (Access = public)
        function obj = SegmentationProcess(owner,name,funName, funParams,...
                        outMaskPaths)
           % Constructor of class SegmentationProcess
           if nargin == 0
              super_args = {};
           else
               super_args{1} = owner;
               super_args{2} = name;                
           end
           % Call the superclass constructor - these values are private
           obj = obj@Process(super_args{:});

           if nargin > 2
               obj.funName_ = funName;                              
           end
           if nargin > 3
              obj.funParams_ = funParams;              
           end
           if nargin > 4               
              if ~isempty(outMaskPaths) && numel(outMaskPaths) ...
                      ~= numel(owner.channels_) || ~iscell(outMaskPaths)
                 error('lccb:set:fatal','User-defined: Mask paths must be a cell-array of the same size as the number of image channels!\n\n'); 
              end
              obj.outMaskPaths_ = outMaskPaths;              
           else
               obj.outMaskPaths_ = cell(1,numel(owner.channels_));               
           end
        end
        
        function sanityCheck(obj) % throws exception
        end
        
        function setMaskRefineProcess(obj, proc)
        % Set mask refinement process    
            assert(isa(proc, 'SegmentationProcess'), 'User-defined: error using setMaskRefineProcess, the input process must be a segmentation process.' )
            obj.maskRefineProcess_ = proc; 
        end
        
        function clearMaskRefineProcess(obj)
        % Clear segmenataion process
           obj.maskRefineProcess_ = [ ]; 
        end
            
        %Checks if a particular channel has masks
        function maskStatus = checkChannelOutput(obj,iChan)                        
            
            nChanTot = numel(obj.owner_.channels_);
            if nargin < 2 || isempty(iChan)
                iChan = 1:nChanTot; %Default is to check all channels
            end           
            nChan = numel(iChan);            
            maskStatus = false(1,nChan);            
            if all(obj.checkChanNum(iChan))
                for j = 1:nChan
                    %Check the directory and number of masks in each
                    %channel.
                    if exist(obj.outMaskPaths_{iChan(j)},'dir') && ...
                            length(imDir(obj.outMaskPaths_{iChan(j)})) == obj.owner_.nFrames_;
                        maskStatus(j) = true;
                    end                        
                end
            end
            
        end
        function setOutMaskPath(obj,chanNum,maskPath)           
            if obj.checkChanNum(chanNum)
                obj.outMaskPaths_{chanNum} = maskPath;
            else
                error('lccb:set:fatal','Invalid mask channel number for mask path!\n\n'); 
            end
        end
        function fileNames = getOutMaskFileNames(obj,iChan)
            if obj.checkChanNum(iChan)
                fileNames = cellfun(@(x)(imDir(x)),obj.outMaskPaths_(iChan),'UniformOutput',false);
                fileNames = cellfun(@(x)(arrayfun(@(x)(x.name),x,'UniformOutput',false)),fileNames,'UniformOutput',false);
                nIm = cellfun(@(x)(length(x)),fileNames);
                if ~all(nIm == obj.owner_.nFrames_)                    
                    error('Incorrect number of masks found in one or more channels!')
                end                
            else
                error('Invalid channel numbers! Must be positive integers less than the number of image channels!')
            end    
            
            
        end
        
        function hfigure = resultDisplay(obj)
        % Call resultDisplayGUI to show result
        
            if isa(obj, 'Process')
                hfigure = movieDataVisualizationGUI(obj.owner_, obj);
            else
                error('User-defined: the input is not a Process object.')
            end
        end
        
        function runProcess(obj)
            % Run the process!
            obj.funName_(obj.owner_ );
            
            if ~isa(obj, 'MaskRefinementProcess') && ~isempty(obj.maskRefineProcess_) 
                    
                if ~isa(obj.maskRefineProcess_, 'MaskRefinementProcess')
                   error('User-defined: Attached process is not a MaskRefinementProcess.') 
                end
                
                id = find(cellfun(@(x)isequal(x, obj), obj.owner_.processes_));
                
                if isempty(id)
                    error('User-defined: The given process is not in current movie data''s process list.')

                elseif length(id) ~=1
                   error('User-defined: There should be one identical segmentation processes exists in movie data''s process list.') 
                end  
                
                % Provide SegProcessIndex of function parameters
                funParams = obj.maskRefineProcess_.funParams_;
                funParams.SegProcessIndex = id;
                obj.maskRefineProcess_.setPara(funParams)
                
                obj.maskRefineProcess_.funName_(obj.owner_);
                obj.maskRefineProcess_.setSuccess(true);
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
            description = 'This process provides a series of segmentation methods to create masks for the movie which seperate objects (e.g. cells) from the background. Masks are binary images which contain 1 where there is an object of interest (cell), and 0 where there is background.';       
            paramList = {'Input Channels',...
                         'Settings', ...
                         'Post-Processing'};
                         
            paramDesc = {'This allows you to select which channels you want to create masks for. Select the channels by clicking on them in the "Available Input Channels" box and then clicking "Select->" to move them to the "Selected Channels" box. You can un-select a channel by clicking the "Delete" button',...
                         'Click this drop-down box to select a method to segment your images. Click the ''Setting'' button to customize your settings.',...
                         'Post-process (and hopefully improve) the masks for selected channels of the movie. Click ''Setting'' button to customize your settins. This is generally not needed, but can be used in situations where the masks have problems. This is done by removing small background objects, filling any holes in masks, and so on. For more details, see the Settings help for each parameter. The refined masks will replace the existing masks.'};
            if all
                text = makeHelpText(description,paramList,paramDesc);
            else
                text = makeHelpText(description);
            end
             
        end
    end    
    
    
end