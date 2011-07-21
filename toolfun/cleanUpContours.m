function [cleanContours,iClean] = cleanUpContours(contoursIn,nPtsMin)
%CLEANUPCONTOURS removes redundant points and short contours from the input contours
%
% cleanContours = cleanUpContours(contoursIn)
% cleanContours = cleanUpContours(contoursIn,nPtsMin)
% [cleanContours,iClean] = cleanUpContours(contoursIn,nPtsMin)
% 
% Description:
% 
%   The contours returned by contours.m or contourc.m should first be
%   seperated into a cell array using separateContours.m. These contours
%   will often contain "redundant" points - multiple points in the same
%   pixel of the image which was contoured. (I'm not sure why this is...)
%   This function removes these points. Also, they may contain very short
%   contours which surround a single pixel. These contours will be removed
%   if they are shorter than nPtsMin.
% 
% 
% Input:
% 
%   contoursIn - A cell array containing the contours to process, as output
%                by separateContours.m
% 
%   nPtsMin - The minimum number of points a contour must contain to be
%             kept. Contours shorter than this will be removed. 
%             Optional. Default is 3 - just enough to make a triangle. 
% 
% 
% Output:
% 
%   cleanContours - The contours with redundant points and short contours
%                   removied.
% 
%   iClean - The indices of the returned clean contours in the original
%            contour array.
% 
% 
% 
% 
% Hunter Elliott 
% Re-Written 4/2010

%% ------- Input ------- &&

if nargin < 1 || isempty(contoursIn) || ~iscell(contoursIn)
    error('1st input "contoursIn" must be a cell-array of contours!')    
end

if nargin < 2 || isempty(nPtsMin)
    nPtsMin = 3; %Just enough to make a triangle - only contours that can actually contain something will be returned.
end

%% ----- Parameters ----- %%

%threshold for considering two points on a contour redundant
distThreshold = .1;

nContours = length(contoursIn);

%% ------ Clean Up----- %%

%Find the sum difference in the coordinates at each point
%Don't use distance, to keep it fast!
allDiffs = cellfun(@(x)(sum(vertcat(abs(diff(x(1,:))),abs(diff(x(2,:)))))),contoursIn,'UniformOutput',false) ;

%Remove points which are seperated by less than the threshold
cleanContours = arrayfun(@(x)(contoursIn{x}(:,[(allDiffs{x} > distThreshold) true])),1:nContours,'UniformOutput',false)';

%Find the contours that are long enough
nPall = cellfun(@(x)(size(x,2)),cleanContours);
iClean = find(nPall >= nPtsMin);

%Return only these long contours
cleanContours = cleanContours(iClean)';

