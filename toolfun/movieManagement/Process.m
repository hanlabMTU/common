classdef Process < hgsetget
    % Defines the abstract class Process from which every user-defined process
    % will inherit.
    %
    
    properties (SetAccess = private, GetAccess = public)
        name_           % Process name
        owner_          % Movie data object owning the process
        createTime_     % Time process was created
        startTime_      % Time process was last started
        finishTime_     % Time process was last run
    end
    
    properties  (SetAccess = protected)
        % Success/Uptodate flags
        procChanged_   % Whether process parameters have been changed
        success_       % If the process has been successfully run
        % If the parameter of parent process is changed
        % updated_ - false, not changed updated_ - true
        updated_
        
        funName_        % Function running the process
        funParams_      % Parameters for running the process
        
        inFilePaths_    % Path to the process input
        outFilePaths_   % Path to the process output
        
    end
    properties
        notes_          % Process notes
    end
    properties (Transient=true)
        displayMethod_  % Cell array of display methods
    end
   methods (Access = protected)
        function obj = Process(owner, name)
            % Constructor of class Process
            if nargin > 0
                %Make sure the owner is a MovieData object
                if isa(owner,'MovieObject')
                    obj.owner_ = owner;
                else
                    error('lccb:Process:Constructor','The owner of a process must always be a movie object!')
                end
                
                if nargin > 1
                    obj.name_ = name;
                end
                obj.createTime_ = clock;
                obj.procChanged_ = false;
                obj.success_ = false;
                obj.updated_ = true;
            end
        end
    end
    
    methods
        
        function owner = getOwner(obj)
            % Retrieve process owner
            owner = obj.owner_;
        end
        
        function setPara(obj, para)
            % Set process' parameters
            if ~isequal(obj.funParams_,para)
                obj.funParams_ = para;
                obj.procChanged_= true;
                
                % Run sanityCheck on parent package to update dependencies
                for packId = obj.getPackage
                    obj.getOwner().getPackage(packId).sanityCheck(false,'all');
                end
            end
        end
        
        function setUpdated(obj, is)
            % Set update status of the current process
            % updated - true; outdated - false
            obj.updated_ = is;
        end
        
        function setDateTime(obj)
            %The process has been re-run, update the time.
            obj.finishTime_ = clock;
        end
        
        function status = checkChanNum(obj,iChan)
            assert(~isempty(iChan) && isnumeric(iChan),'Please provide a valid channel input');
            status = ismember(iChan,1:numel(obj.getOwner().channels_));
        end
        
        function status = checkFrameNum(obj,iFrame)
            assert(~isempty(iFrame) && isnumeric(iFrame),'Please provide a valid frame input');
            status = ismember(iFrame,1:obj.getOwner().nFrames_);
        end
        
        function sanityCheck(obj)
            % Compare current process fields to default ones (static method)
            crtParams=obj.funParams_;
            defaultParams = obj.getDefaultParams(obj.getOwner());
            crtFields = fieldnames(crtParams);
            defaultFields = fieldnames(defaultParams);
            
            %  Find undefined parameters
            status = ~ismember(defaultFields,crtFields);
            if any(status)
                for i=find(status)'
                    crtParams.(defaultFields{i})=defaultParams.(defaultFields{i});
                end
                obj.setPara(crtParams);
            end
        end
        
        function run(obj,varargin)
            % Reset sucess flags and existing display methods
            obj.resetDisplayMethod();
            obj.success_=false;
            
            % Run the process!
            obj.startTime_ = clock;
            obj.funName_(obj.getOwner(), varargin{:});
            
            % Update flags and set finishTime
            obj.success_= true;
            obj.updated_= true;
            obj.procChanged_= false;
            obj.finishTime_ = clock;
            
            % Run sanityCheck on parent package to update dependencies
            for packId=obj.getPackage
                obj.getOwner().getPackage(packId).sanityCheck(false,'all');
            end
            
            obj.getOwner().save();
        end
        
        function resetDisplayMethod(obj)
            if ~isempty(obj.displayMethod_)
                cellfun(@delete,obj.displayMethod_(~cellfun(@isempty,obj.displayMethod_)));
                obj.displayMethod_ = {};
            end
        end
        
        
        function setDisplayMethod(obj,iOutput,iChan,displayMethod)
            
            assert(isa(displayMethod(),'MovieDataDisplay'));
            try
                delete(obj.displayMethod_{iOutput,iChan});
            end
            obj.displayMethod_{iOutput,iChan} = displayMethod;
        end
        
        
        function setInFilePaths(obj,paths)
            %  Set input file paths
            obj.inFilePaths_=paths;
        end
        
        function setOutFilePaths(obj,paths)
            % Set output file paths
            obj.outFilePaths_ = paths;
        end
        
        function time = getProcessingTime(obj)
            %The process has been re-run, update the time.
            time=sec2struct(24*3600*(datenum(obj.finishTime_)-datenum(obj.startTime_)));
        end
        
        function [packageID, procID] = getPackage(obj)
            % Retrieve package to which the process is associated
            isOwner=@(x)cellfun(@(y) isequal(y,obj),x.processes_);
            validPackage = cellfun(@(x) any(isOwner(x)),obj.getOwner().packages_);
            packageID = find(validPackage);
            procID= cellfun(@(x) find(isOwner(x)), obj.getOwner().packages_(validPackage));
        end
        
        function relocate(obj,oldRootDir,newRootDir)
            % Relocate all paths in various process fields
            relocateFields ={'inFilePaths_','outFilePaths_', 'funParams_'};
            for i=1:numel(relocateFields)
                obj.(relocateFields{i}) = relocatePath(obj.(relocateFields{i}),...
                    oldRootDir,newRootDir);
            end
        end
        
        function hfigure = resultDisplay(obj)
            hfigure = movieViewer(obj.getOwner(), ...
                find(cellfun(@(x)isequal(x,obj),obj.getOwner().processes_)));
        end
        
        function h=draw(obj,iChan,varargin)
            % Template function to draw process output
            
            % Input check
            if ~ismember('getDrawableOutput',methods(obj)), h=[]; return; end
            outputList = obj.getDrawableOutput();
            ip = inputParser;
            ip.addRequired('obj',@(x) isa(x,'Process'));
            ip.addRequired('iChan',@isnumeric);
            ip.addOptional('iFrame',[],@isnumeric);
            ip.addParamValue('output',outputList(1).var,@(x) any(cellfun(@(y) isequal(x,y),{outputList.var})));
            ip.KeepUnmatched = true;
            ip.parse(obj,iChan,varargin{:})
            
            % Load data
            if ~isempty(ip.Results.iFrame)
                data=obj.loadChannelOutput(iChan,ip.Results.iFrame,'output',ip.Results.output);
            else
                data=obj.loadChannelOutput(iChan,'output',ip.Results.output);
            end
            iOutput= find(cellfun(@(y) isequal(ip.Results.output,y),{outputList.var}));
            if ~isempty(outputList(iOutput).formatData),
                data=outputList(iOutput).formatData(data);
            end
            
            % Initialize display method
            displayDims = size(obj.displayMethod_);
            if any(displayDims(1:2)<[iOutput iChan]) || ...
                    isempty(obj.displayMethod_{iOutput,iChan})
                obj.displayMethod_{iOutput,iChan}=outputList(iOutput).defaultDisplayMethod(iChan);
            end
            
            % Create graphic tag and delegate drawing to the display class
            tag = ['process' num2str(obj.getIndex()) '_channel' num2str(iChan) '_output' num2str(iOutput)];
            drawArgs=reshape([fieldnames(ip.Unmatched) struct2cell(ip.Unmatched)]',...
                2*numel(fieldnames(ip.Unmatched)),1);
            h=obj.displayMethod_{iOutput,iChan}.draw(data,tag,drawArgs{:});
        end
        
        function index = getIndex(obj)
            % Retrieve index of process in the owner object
            index = find(cellfun(@(x) isequal(x,obj),obj.getOwner().processes_));
            assert(numel(index)==1);
        end
    end
    
    methods (Static)
        function status = isProcess(name)
            % Check if the input classname is of class Process
            status = exist(name, 'class') == 8 && isSubclass(name, 'Process');
        end
        
        function status = hasGUI(name)
            % Check if process has a settings graphical interface
            m = meta.class.fromName(name);
            status = ismember('GUI',{m.MethodList.Name});
        end
        
    end
    
    methods (Static,Abstract)
        getDefaultParams
        getName
    end
end