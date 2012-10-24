
function [m,isDone]  = manualSegmentationTweakGUI(im,m,displayrange)
%MANUALSEGMENTATIONTWEAKGUI allows manual segmentation creation of masks or alteration of existing masksk
% [masks,isCompleted] = manualSegmentationTweakGUI(images,masks)
%
% This function allows the user to modify a set of masks manually to
% improve them. Based on Deepaks seed point selection GUI - thanks Deepak!!
%
%
%
% Instructions:
%
%    -Go to the frame you want to edit or create mask for (you can use mouse
%    scroll wheel to change frames).
%   -Select one of the options: 
%
%               Add = add an area to the mask
%               Subtract = cut an area out of the mask
%               Restart = redraw this frame from scratch
%
%   -Select a drawing option:
%       Freehand = click and drag to select a region.
%       Polygon = click several times to create the vertices of a polygon.
%       Double click on first vertex to close polygon.
%
%
%   -Click GO or hit spacebar to start drawing your mask or mask correction
%
%   -Hit enter or click the "completed" box when you are done fixing a
%   frame
%
%   -When you are done with all the frames you want to fix, just close the
%   GUI
%
%   NOTE: To segment a cell which touches the image border, you must drag a
%   circle around it OUTSIDE the image area, or if using the polygon tool,
%   move a vertex outside of the image area.
%
% *****Keyboard shortcuts:*****
%
%   =For All the radio button options, just press the first letter
%   =Space - Go (start drawing on the mask)
%   =u - undo (only one step)
%   =m - toggle mask display
%   =enter - mark frame as completed
%   - OR + - Decrease/increase contrast by adjusting upper display limit
%   ( OR ) - Decrease/increase contrast by adjusting lower display limit
%

%Hunter Elliott, 10/2012

%%

if nargin < 3 || isempty(displayRange)
    
    displayrange = double([min(im(:)) max(im(:))]);
    
end

if nargin < 2 || isempty(m)
    m = false(size(im));
end

global data_get_fgnd_bgnd_seeds_3d_points;

hMainFigure = fsFigure(.75);

% Create UI controls

    % axis
    data_get_fgnd_bgnd_seeds_3d_points.ui.ah_img = axes( 'Position' , [ 0.001 , 0.2 , 0.7 , 0.7 ] , 'Visible' , 'off' );    
   
    % slice navigation controls
    data_get_fgnd_bgnd_seeds_3d_points.ui.pbh_dec = uicontrol(hMainFigure,'Style','pushbutton','String','<<',...
                    'Units' , 'normalized' , 'Position',[0.20 0.1 0.05 0.05],...
                    'Callback',{@pushFirstSlice_Callback});                        
    
    data_get_fgnd_bgnd_seeds_3d_points.ui.pbh_dec = uicontrol(hMainFigure,'Style','pushbutton','String','<',...
                    'Units' , 'normalized' , 'Position',[0.25 0.1 0.05 0.05],...
                    'Callback',{@pushdec_Callback});
                
    data_get_fgnd_bgnd_seeds_3d_points.ui.eth_sno = uicontrol(hMainFigure,'Style','edit',...
                    'String','0',...
                    'Units' , 'normalized' , 'Position',[0.30 0.1 0.1 0.05]);
                
    data_get_fgnd_bgnd_seeds_3d_points.ui.pbh_inc = uicontrol(hMainFigure,'Style','pushbutton','String','>',...
                    'Units' , 'normalized' , 'Position',[0.40 0.1 0.05 0.05],...
                    'Callback',{@pushinc_Callback});        
                
    data_get_fgnd_bgnd_seeds_3d_points.ui.pbh_inc = uicontrol(hMainFigure,'Style','pushbutton','String','>>',...
                    'Units' , 'normalized' , 'Position',[0.45 0.1 0.05 0.05],...
                    'Callback',{@pushLastSlice_Callback});                
                
    % cursor point info controls
    data_get_fgnd_bgnd_seeds_3d_points.ui.eth_xloc = uicontrol(hMainFigure,'Style','edit',...
                    'String','X: INV',...
                    'Units' , 'normalized' , 'Position',[0.20 0.05 0.1 0.05]);                

    data_get_fgnd_bgnd_seeds_3d_points.ui.eth_yloc = uicontrol(hMainFigure,'Style','edit',...
                    'String','Y: INV',...
                    'Units' , 'normalized' , 'Position',[0.30 0.05 0.1 0.05]);     
                
    data_get_fgnd_bgnd_seeds_3d_points.ui.eth_Imval = uicontrol(hMainFigure,'Style','edit',...
                    'String','I: INV',...
                    'Units' , 'normalized' , 'Position',[0.40 0.05 0.1 0.05]);                                                
                
    % selection mode controls
    data_get_fgnd_bgnd_seeds_3d_points.ui.bgh_mode = uibuttongroup('visible','on', 'Units' , 'normalized' ,'Position',[0.71 0.2 0.2 0.2]);
    data_get_fgnd_bgnd_seeds_3d_points.ui_rbh_fgnd = uicontrol('Style','Radio','String','Add',...
                                 'Units' , 'normalized' ,'Position',[0.05 0.75 0.75 0.15],'parent',data_get_fgnd_bgnd_seeds_3d_points.ui.bgh_mode,'HandleVisibility','off');
    data_get_fgnd_bgnd_seeds_3d_points.ui_rbh_bgnd = uicontrol('Style','Radio','String','Subtract',...
                                 'Units' , 'normalized' ,'Position',[0.05 0.50 0.75 0.15],'parent',data_get_fgnd_bgnd_seeds_3d_points.ui.bgh_mode,'HandleVisibility','off');            
    data_get_fgnd_bgnd_seeds_3d_points.ui_rbh_none = uicontrol('Style','Radio','String','Restart',...
                                 'Units' , 'normalized' ,'Position',[0.05 0.25 0.75 0.15],'parent',data_get_fgnd_bgnd_seeds_3d_points.ui.bgh_mode,'HandleVisibility','off');    
    
    set( data_get_fgnd_bgnd_seeds_3d_points.ui.bgh_mode , 'SelectedObject' , data_get_fgnd_bgnd_seeds_3d_points.ui_rbh_fgnd );            
    
    % selection type controls
    data_get_fgnd_bgnd_seeds_3d_points.ui.sel_mode = uibuttongroup('visible','on', 'Units' , 'normalized' ,'Position',[0.71 0.5 0.2 0.2]);
    data_get_fgnd_bgnd_seeds_3d_points.ui_rbh2_fhan = uicontrol('Style','Radio','String','Freehand',...
                                 'Units' , 'normalized' ,'Position',[0.05 0.75 0.75 0.15],'parent',data_get_fgnd_bgnd_seeds_3d_points.ui.sel_mode,'HandleVisibility','off');
    data_get_fgnd_bgnd_seeds_3d_points.ui_rbh2_poly = uicontrol('Style','Radio','String','Polygon',...
                                 'Units' , 'normalized' ,'Position',[0.05 0.50 0.75 0.15],'parent',data_get_fgnd_bgnd_seeds_3d_points.ui.sel_mode,'HandleVisibility','off');            
    
    set( data_get_fgnd_bgnd_seeds_3d_points.ui.sel_mode , 'SelectedObject' , data_get_fgnd_bgnd_seeds_3d_points.ui_rbh2_fhan );            
    
    
    %Go button
    data_get_fgnd_bgnd_seeds_3d_points.ui_go = uicontrol('Style','pushbutton','String','Go',...
                                 'Units' , 'normalized' ,'Position',[0.71 0.8 0.2 0.1],'parent',hMainFigure,'Callback',{@pushGo_Callback});                
    
    %check box
    data_get_fgnd_bgnd_seeds_3d_points.ui_cb = uicontrol('Style','checkbox','String','Completed',...        
                             'Units' , 'normalized' ,'Position',[0.10 0.1 0.05 0.05],'parent',hMainFigure,'Callback',{@chkBox_Callback});         
                         
    set(data_get_fgnd_bgnd_seeds_3d_points.ui_cb,'Value',0)
                         
    %[0.20 0.1 0.05 0.05]
% set callbacks
set( hMainFigure , 'WindowScrollWheelFcn' , @FnSliceScroll_Callback );  
%set( hMainFigure , 'WindowButtonDownFcn' , @FnMainFig_MouseButtonDownFunc );  
%set( hMainFigure , 'WindowButtonMotionFcn' , @FnMainFig_MouseMotionFunc );  
set( hMainFigure , 'WindowKeyPressFcn' , @FnKeyPress_Callback );  


% data_get_fgnd_bgnd_seeds_3d_points                         
data_get_fgnd_bgnd_seeds_3d_points.im = im;
data_get_fgnd_bgnd_seeds_3d_points.m = m;
data_get_fgnd_bgnd_seeds_3d_points.prevm = m;
data_get_fgnd_bgnd_seeds_3d_points.showMask = true;
data_get_fgnd_bgnd_seeds_3d_points.isDone = false(size(im,3),1);
data_get_fgnd_bgnd_seeds_3d_points.sliceno = 1;
data_get_fgnd_bgnd_seeds_3d_points.displayrange = displayrange;
data_get_fgnd_bgnd_seeds_3d_points.fgnd_seed_points = [];
data_get_fgnd_bgnd_seeds_3d_points.bgnd_seed_points = [];

imsliceshow(data_get_fgnd_bgnd_seeds_3d_points);



% wait until the window is closed
errCatch = 0;
try
    waitfor( hMainFigure );
catch
    errCatch = 1;
end
    
if errCatch == 0         

    m = data_get_fgnd_bgnd_seeds_3d_points.m;
    isDone = data_get_fgnd_bgnd_seeds_3d_points.isDone;
    
    clear data_get_fgnd_bgnd_seeds_3d_points;
    
else
        
    clear data_get_fgnd_bgnd_seeds_3d_points;
    error( 'Error: Unknown error occured while getting seed points from the user' );
    
end
    
%%
function imsliceshow(data_get_fgnd_bgnd_seeds_3d_points)

    

    %Just show a blank mask so we can be lazy and still use deepaks display function
    %and have consistant image display/contrast etc.
    if data_get_fgnd_bgnd_seeds_3d_points.showMask
        mShow = data_get_fgnd_bgnd_seeds_3d_points.m(:,:,data_get_fgnd_bgnd_seeds_3d_points.sliceno);
    else
        mShow = false(size(data_get_fgnd_bgnd_seeds_3d_points.m(:,:,data_get_fgnd_bgnd_seeds_3d_points.sliceno)));
    end
    
    imHan = imshow(genImageMaskOverlay_loc(data_get_fgnd_bgnd_seeds_3d_points.im(:,:,data_get_fgnd_bgnd_seeds_3d_points.sliceno),...
                                   mShow,[0 1 0],.17,data_get_fgnd_bgnd_seeds_3d_points.displayrange));
    
%data_get_fgnd_bgnd_seeds_3d_points.displayrange);
    set(data_get_fgnd_bgnd_seeds_3d_points.ui.eth_sno,'String',sprintf('%d / %d' , data_get_fgnd_bgnd_seeds_3d_points.sliceno , size( data_get_fgnd_bgnd_seeds_3d_points.im , 3 ) ));    

    set(data_get_fgnd_bgnd_seeds_3d_points.ui_cb,'Value',data_get_fgnd_bgnd_seeds_3d_points.isDone(data_get_fgnd_bgnd_seeds_3d_points.sliceno))

%Old method - show by transparency
%     imHan = imshow(data_get_fgnd_bgnd_seeds_3d_points.im(:,:,data_get_fgnd_bgnd_seeds_3d_points.sliceno),data_get_fgnd_bgnd_seeds_3d_points.displayrange);
%     set(data_get_fgnd_bgnd_seeds_3d_points.ui.eth_sno,'String',sprintf('%d / %d' , data_get_fgnd_bgnd_seeds_3d_points.sliceno , size( data_get_fgnd_bgnd_seeds_3d_points.im , 3 ) ));
%     set(imHan,'AlphaData',double(data_get_fgnd_bgnd_seeds_3d_points.m(:,:,data_get_fgnd_bgnd_seeds_3d_points.sliceno))+1);
%     set(imHan,'AlphaDataMapping','scaled')
%     alim(get(imHan,'Parent'),[0 2])
%     hold on;
% 
%         if ~isempty( data_get_fgnd_bgnd_seeds_3d_points.fgnd_seed_points )
%             
%             fgnd_pt_ind = find( data_get_fgnd_bgnd_seeds_3d_points.fgnd_seed_points( : , 3 ) == data_get_fgnd_bgnd_seeds_3d_points.sliceno );
%             plot( data_get_fgnd_bgnd_seeds_3d_points.fgnd_seed_points( fgnd_pt_ind , 1 ) , data_get_fgnd_bgnd_seeds_3d_points.fgnd_seed_points( fgnd_pt_ind , 2 ) , 'g+' );
% 
%         end
%         
%         if ~isempty( data_get_fgnd_bgnd_seeds_3d_points.bgnd_seed_points )
%             
%             bgnd_pt_ind = find( data_get_fgnd_bgnd_seeds_3d_points.bgnd_seed_points( : , 3 ) == data_get_fgnd_bgnd_seeds_3d_points.sliceno );       
%             plot( data_get_fgnd_bgnd_seeds_3d_points.bgnd_seed_points( bgnd_pt_ind , 1 ) , data_get_fgnd_bgnd_seeds_3d_points.bgnd_seed_points( bgnd_pt_ind , 2 ) , 'r+' );
% 
%         end
        
%    hold off;

%% First Slice
function pushFirstSlice_Callback(hSrc,eventdata_get_fgnd_bgnd_seeds_3d_points)

    global data_get_fgnd_bgnd_seeds_3d_points;

    data_get_fgnd_bgnd_seeds_3d_points.sliceno = 1;    
    
    imsliceshow(data_get_fgnd_bgnd_seeds_3d_points);    

%% Last Slice
function pushLastSlice_Callback(hSrc,eventdata_get_fgnd_bgnd_seeds_3d_points)

    global data_get_fgnd_bgnd_seeds_3d_points;

    data_get_fgnd_bgnd_seeds_3d_points.sliceno = size( data_get_fgnd_bgnd_seeds_3d_points.im , 3 );    
    
    imsliceshow(data_get_fgnd_bgnd_seeds_3d_points);    
    
%%
function pushdec_Callback(hSrc,eventdata_get_fgnd_bgnd_seeds_3d_points)

    global data_get_fgnd_bgnd_seeds_3d_points;

    if(data_get_fgnd_bgnd_seeds_3d_points.sliceno>1)
        data_get_fgnd_bgnd_seeds_3d_points.sliceno = data_get_fgnd_bgnd_seeds_3d_points.sliceno-1;
    end    
    
    imsliceshow(data_get_fgnd_bgnd_seeds_3d_points);

%%
function pushinc_Callback(hSrc,eventdata_get_fgnd_bgnd_seeds_3d_points)

    global data_get_fgnd_bgnd_seeds_3d_points;

    if(data_get_fgnd_bgnd_seeds_3d_points.sliceno<size(data_get_fgnd_bgnd_seeds_3d_points.im,3))
        data_get_fgnd_bgnd_seeds_3d_points.sliceno = data_get_fgnd_bgnd_seeds_3d_points.sliceno+1;
    end
        
    imsliceshow(data_get_fgnd_bgnd_seeds_3d_points);

%%
function FnSliceScroll_Callback( hSrc , evnt )
    
      global data_get_fgnd_bgnd_seeds_3d_points;
      
      if evnt.VerticalScrollCount > 0 
          
          if(data_get_fgnd_bgnd_seeds_3d_points.sliceno<size(data_get_fgnd_bgnd_seeds_3d_points.im,3))
              data_get_fgnd_bgnd_seeds_3d_points.sliceno = data_get_fgnd_bgnd_seeds_3d_points.sliceno+1;
          end
          
      elseif evnt.VerticalScrollCount < 0 
          
          if(data_get_fgnd_bgnd_seeds_3d_points.sliceno>1)
             data_get_fgnd_bgnd_seeds_3d_points.sliceno = data_get_fgnd_bgnd_seeds_3d_points.sliceno-1;
          end
          
      end   
          
      imsliceshow(data_get_fgnd_bgnd_seeds_3d_points);      
      UpdateCursorPointInfo(data_get_fgnd_bgnd_seeds_3d_points);
      
%%
function FnMainFig_MouseButtonDownFunc( hSrc , evnt )

    global data_get_fgnd_bgnd_seeds_3d_points;
    
    cp = get( gca , 'CurrentPoint' );
    
    if IsPointInsideImage( cp(1,1:2) , data_get_fgnd_bgnd_seeds_3d_points ) && strcmp( get(hSrc ,'SelectionType'),'normal' )       
          

       
        switch get( data_get_fgnd_bgnd_seeds_3d_points.ui.bgh_mode , 'SelectedObject' )
           
            case data_get_fgnd_bgnd_seeds_3d_points.ui_rbh_fgnd
                
                data_get_fgnd_bgnd_seeds_3d_points.fgnd_seed_points = [ data_get_fgnd_bgnd_seeds_3d_points.fgnd_seed_points ; cp(1,1:2) data_get_fgnd_bgnd_seeds_3d_points.sliceno ];

            case data_get_fgnd_bgnd_seeds_3d_points.ui_rbh_bgnd
                
                data_get_fgnd_bgnd_seeds_3d_points.bgnd_seed_points = [ data_get_fgnd_bgnd_seeds_3d_points.bgnd_seed_points ; cp(1,1:2) data_get_fgnd_bgnd_seeds_3d_points.sliceno ];                
        end

    end
    
    imsliceshow(data_get_fgnd_bgnd_seeds_3d_points);
    

%% Update cursor point info -- xloc, yloc, int_val
function UpdateCursorPointInfo( data_get_fgnd_bgnd_seeds_3d_points )

%     global data_get_fgnd_bgnd_seeds_3d_points;
    
    cp = get( gca , 'CurrentPoint' );       

    if IsPointInsideImage( cp(1,1:2) , data_get_fgnd_bgnd_seeds_3d_points )
        
        set(data_get_fgnd_bgnd_seeds_3d_points.ui.eth_xloc,'String' ,sprintf('X: %d / %d' , round( cp(1,1) ) , size( data_get_fgnd_bgnd_seeds_3d_points.im , 2 ) ));
        set(data_get_fgnd_bgnd_seeds_3d_points.ui.eth_yloc,'String' ,sprintf('Y: %d / %d' , round( cp(1,2) ) , size( data_get_fgnd_bgnd_seeds_3d_points.im , 1 ) ));        
        set(data_get_fgnd_bgnd_seeds_3d_points.ui.eth_Imval,'String',sprintf('I: %.1f' , data_get_fgnd_bgnd_seeds_3d_points.im( round( cp(1,2) ) , round( cp(1,1) ) , data_get_fgnd_bgnd_seeds_3d_points.sliceno ) ));                
        
    else
        
        set(data_get_fgnd_bgnd_seeds_3d_points.ui.eth_xloc,'String',sprintf('X: INV') );
        set(data_get_fgnd_bgnd_seeds_3d_points.ui.eth_yloc,'String',sprintf('Y: INV') );        
        set(data_get_fgnd_bgnd_seeds_3d_points.ui.eth_Imval,'String',sprintf('I: INV') );        
        
    end

%%    
function FnMainFig_MouseMotionFunc( hSrc , evnt )    
    
    global data_get_fgnd_bgnd_seeds_3d_points;
    
    cp = get( gca , 'CurrentPoint' );       
    
    if IsPointInsideImage( cp(1,1:2) , data_get_fgnd_bgnd_seeds_3d_points )
        
        set( hSrc ,'Pointer','crosshair');        
        
    else
        
        set( hSrc ,'Pointer','arrow');        

    end    
    
    
    imsliceshow(data_get_fgnd_bgnd_seeds_3d_points);    
    UpdateCursorPointInfo( data_get_fgnd_bgnd_seeds_3d_points );

%%    
function [ blnInside ] = IsPointInsideImage( cp , data_get_fgnd_bgnd_seeds_3d_points )

%     global data_get_fgnd_bgnd_seeds_3d_points;

    volsize = size( data_get_fgnd_bgnd_seeds_3d_points.im );
    
    blnInside = all( cp <= volsize([2 1]) ) && all( cp >= [1 1] );
  
function pushGo_Callback(hSrc,eventdata_get_fgnd_bgnd_seeds_3d_points)

    global data_get_fgnd_bgnd_seeds_3d_points;
    
    
    switch get( data_get_fgnd_bgnd_seeds_3d_points.ui.sel_mode , 'SelectedObject' )
        
        case data_get_fgnd_bgnd_seeds_3d_points.ui_rbh2_fhan
            
            fH = imfreehand(data_get_fgnd_bgnd_seeds_3d_points.ui.ah_img);
            
        case data_get_fgnd_bgnd_seeds_3d_points.ui_rbh2_poly
            
            fH = impoly(data_get_fgnd_bgnd_seeds_3d_points.ui.ah_img);            
            
    end
    
    if ~isempty(fH)
        currROI = fH.createMask;    
        
        data_get_fgnd_bgnd_seeds_3d_points.prevm = data_get_fgnd_bgnd_seeds_3d_points.m;

        switch get( data_get_fgnd_bgnd_seeds_3d_points.ui.bgh_mode , 'SelectedObject' )

                case data_get_fgnd_bgnd_seeds_3d_points.ui_rbh_fgnd

                    data_get_fgnd_bgnd_seeds_3d_points.m(:,:,data_get_fgnd_bgnd_seeds_3d_points.sliceno) = ...
                        data_get_fgnd_bgnd_seeds_3d_points.m(:,:,data_get_fgnd_bgnd_seeds_3d_points.sliceno) | currROI;

                case data_get_fgnd_bgnd_seeds_3d_points.ui_rbh_bgnd

                    data_get_fgnd_bgnd_seeds_3d_points.m(:,:,data_get_fgnd_bgnd_seeds_3d_points.sliceno) = ...
                        data_get_fgnd_bgnd_seeds_3d_points.m(:,:,data_get_fgnd_bgnd_seeds_3d_points.sliceno) ~= ...
                        (currROI & data_get_fgnd_bgnd_seeds_3d_points.m(:,:,data_get_fgnd_bgnd_seeds_3d_points.sliceno));

                case data_get_fgnd_bgnd_seeds_3d_points.ui_rbh_none

                    data_get_fgnd_bgnd_seeds_3d_points.m(:,:,data_get_fgnd_bgnd_seeds_3d_points.sliceno) = currROI;



        end
    end
    
    imsliceshow(data_get_fgnd_bgnd_seeds_3d_points);    

function FnKeyPress_Callback(hSrc,eventdata_get_fgnd_bgnd_seeds_3d_points)    

global data_get_fgnd_bgnd_seeds_3d_points;

switch eventdata_get_fgnd_bgnd_seeds_3d_points.Key
    
        
    case 'space'
        %Call the go button function
        pushGo_Callback(hSrc,eventdata_get_fgnd_bgnd_seeds_3d_points)
        
    case 'a'
        
        set( data_get_fgnd_bgnd_seeds_3d_points.ui.bgh_mode , 'SelectedObject' , data_get_fgnd_bgnd_seeds_3d_points.ui_rbh_fgnd);

    case 's'
        
        set( data_get_fgnd_bgnd_seeds_3d_points.ui.bgh_mode , 'SelectedObject' , data_get_fgnd_bgnd_seeds_3d_points.ui_rbh_bgnd);
        
    case 'r'
        
        set( data_get_fgnd_bgnd_seeds_3d_points.ui.bgh_mode , 'SelectedObject' , data_get_fgnd_bgnd_seeds_3d_points.ui_rbh_none);
        
        
    case 'f'
        
        set( data_get_fgnd_bgnd_seeds_3d_points.ui.sel_mode , 'SelectedObject' , data_get_fgnd_bgnd_seeds_3d_points.ui_rbh2_fhan);            
        
    case 'p'
        
        set( data_get_fgnd_bgnd_seeds_3d_points.ui.sel_mode , 'SelectedObject' , data_get_fgnd_bgnd_seeds_3d_points.ui_rbh2_poly);
        
    case 'equal'
        
        data_get_fgnd_bgnd_seeds_3d_points.displayrange = data_get_fgnd_bgnd_seeds_3d_points.displayrange - [0 100];
        
    case 'hyphen'
        
        data_get_fgnd_bgnd_seeds_3d_points.displayrange = data_get_fgnd_bgnd_seeds_3d_points.displayrange + [0 100];                
        
    case '0'
        
        data_get_fgnd_bgnd_seeds_3d_points.displayrange = data_get_fgnd_bgnd_seeds_3d_points.displayrange - [100 0];
        
    case '9'
        
        data_get_fgnd_bgnd_seeds_3d_points.displayrange = data_get_fgnd_bgnd_seeds_3d_points.displayrange + [100 0];                
        
    case 'm'
        
        data_get_fgnd_bgnd_seeds_3d_points.showMask = ~data_get_fgnd_bgnd_seeds_3d_points.showMask;
        
    case 'return'
        chkBox_Callback(hSrc,eventdata_get_fgnd_bgnd_seeds_3d_points)
        
    case 'u'
        
        tmp = data_get_fgnd_bgnd_seeds_3d_points.m;
        data_get_fgnd_bgnd_seeds_3d_points.m = data_get_fgnd_bgnd_seeds_3d_points.prevm;
        data_get_fgnd_bgnd_seeds_3d_points.prevm = tmp;
        
        
end    

imsliceshow(data_get_fgnd_bgnd_seeds_3d_points);    

function chkBox_Callback(hSrc,eventdata_get_fgnd_bgnd_seeds_3d_points)  
    global data_get_fgnd_bgnd_seeds_3d_points
    data_get_fgnd_bgnd_seeds_3d_points.isDone(data_get_fgnd_bgnd_seeds_3d_points.sliceno) = ~data_get_fgnd_bgnd_seeds_3d_points.isDone(data_get_fgnd_bgnd_seeds_3d_points.sliceno);
    
    
    
function imRGB = genImageMaskOverlay_loc( im, mask, maskColor, maskAlpha,displayRange)

    imr = im2uint8( mat2gray( im ,displayRange) );
    img = imr;
    imb = imr;
    mask = mask > 0;
    maxVal = 255;
    
    imr(mask) = uint8( double( (1 - maskAlpha) * imr(mask) ) + maxVal * maskAlpha * maskColor(1) );
    img(mask) = uint8( double( (1 - maskAlpha) * img(mask) ) + maxVal * maskAlpha * maskColor(2) );
    imb(mask) = uint8( double( (1 - maskAlpha) * imb(mask) ) + maxVal * maskAlpha * maskColor(3) );
    
    imRGB = cat(3, imr, img, imb );
    
            