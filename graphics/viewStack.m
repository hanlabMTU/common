function viewStack(imageMat)

% viewStack(imageMat)
% 
% This is designed for viewing 3D confocal image stacks, but can be applied
% to any 3D matrix. The matrix is displayed in 3D with the intensity at
% each point represented by it's opacity/transparency.
% 
% Input:
% 
%   imageMat - The 3D image matrix to view.
% 
% Hunter Elliott
% 1/2010


if ndims(imageMat) ~= 3
    error('Must input a 3D matrix for image data!')
end

[M,N,P] = size(imageMat);

imageMat = double(imageMat);

hold on
set(gca,'color','k')
for p = 1:P
    
    surf(ones(M,N)*p,'EdgeColor','none','FaceAlpha','interp',...
        'AlphaDataMapping','scaled','AlphaData',imageMat(:,:,p),...
        'FaceColor','g')
    
    
end

view(-45,45);
axis image;



