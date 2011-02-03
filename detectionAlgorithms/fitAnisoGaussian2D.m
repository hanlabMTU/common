%FITANISOGAUSSIAN2D Fit a 2-D Anisotropic Gaussian function to data in a square image window.
%    [prmVect prmStd C res J] = fitGaussian2D(data, prmVect, mode, options)
%
%    Symbols: xp : x-position
%             yp : y-position
%              A : amplitude
%             sx : standard deviation along the rotated x axis
%             sy : standard deviation along the rotated y axis
%              t : angle
%              c : background
%
%    The origin is defined at the center of the input window.
%
%    Inputs:     data : 2-D image array
%             prmVect : parameter vector with order: [xp, yp, A, sx, sy, t, c]
%                mode : string that defines parameters to be optimized; any among 'xyarstc' (r = sx, s = sy)
%           {options} : vector [MaxIter TolFun TolX]; max. iterations, precision on f(x), precision on x
%
%    Outputs: prmVect : parameter vector
%              prmStd : parameter standard deviations
%                   C : covariance matrix
%                 res : residuals
%                   J : Jacobian
%
% Axis conventions: image processing, see meshgrid
%
% Example: [prmVect prmStd C res J] = fitGaussian2D(data, [0 0 max(data(:)) 1.5 1.5 pi/6 min(data(:))], 'xyarstc');

% (c) Francois Aguet & Sylvain Berlemont, 2011