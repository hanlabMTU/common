function y=isImgRGB(x)
%ISIMGRGB Return true for RGB image.
%   FLAG = ISIMGRGB(A) returns 1 if A is an RGB truecolor image and
%   0 otherwise.
%
%   This function replaces the original MATLAB function isrgb, which has
%   been declared obsolete by Mathworks and might be removed in a future
%   MATLAB revision. Currently the function is exactly the same as isrgb.
%
%   ISIMGRGB uses these criteria to determine if A is an RGB image:
%
%   - If A is of class double, all values must be in the range
%     [0,1], and A must be M-by-N-by-3.
%
%   - If A is of class uint8 or uint16, A must be M-by-N-by-3.
%
%   Note that a four-dimensional array that contains multiple RGB
%   images returns 0, not 1.
%
%   Class Support
%   -------------
%   A can be of class uint8, uint16, or double. If A is of 
%   class logical it is considered not to be RGB.
%
%   See also ISBW, ISGRAY, ISIND.

%   Original Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.15.4.2 $  $Date: 2003/08/23 05:52:55 $

fprintf(2, 'Warning: ''isImgRGB'' is deprecated and should no longer be used.\nUse the built-in ''imfinfo'' instead.\n');

y = size(x,3)==3;
if y
   if isa(x, 'logical')
      y = false;
   elseif isa(x, 'double')
      % At first just test a small chunk to get a possible quick negative  
      m = size(x,1);
      n = size(x,2);
      chunk = x(1:min(m,10),1:min(n,10),:);         
      y = (min(chunk(:))>=0 && max(chunk(:))<=1);
      % If the chunk is an RGB image, test the whole image
      if y
         y = (min(x(:))>=0 && max(x(:))<=1);
      end
   end
end
