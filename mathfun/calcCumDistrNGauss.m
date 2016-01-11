function [cumDistrNGauss,J] = calcCumDistrNGauss(param,abscissa,variableMean,...
    variableStd,logData,gaussParamIn,ratioTol)
%CALCCUMDISTRNGAUSS calculates the cumulative distribution of N Gaussians
%
%SYNOPSIS cumDistrNGauss = calcCumDistrNGauss(param,abscissa,variableMean,...
%     variableStd,logData,gaussParamIn)
%
%INPUT  param       : Vector of parameters indicating the means,
%                     stds and amplitudes of the N Gaussians.
%       abscissa    : Abscissa values at which the cumulative
%                     distribution is calculated.
%       variableMean: Flag with potential values:
%                     - 0 if assuming the fixed relationship
%                     (mean of nth Gaussian) = n * (mean of 1st Gaussian).
%                     - 1 if there is no relationship between the means of
%                     different Gaussians.
%                     - 2, 3, etc. if assuming the same fixed relationship
%                     as 0 but that the first detected Gaussian is actually
%                     the 2nd, 3rd, etc. Gaussian in the relationship.
%                     Optional. Default: 1.
%       variableStd : Flag with potential values:
%                     - 0 if assuming that all Gaussians have the same
%                     standard deviation. 
%                     - 1 if there is no relationship
%                     between the standard deviations of different
%                     Gaussians.
%                     - 2 if assuming the relationship
%                     (std of nth Gaussian) = sqrt(n) * (std of 1st Gaussian).
%                     This relationship is generalized if variableMean > 1.
%                     *** variableStd can equal 2 only if variableMean is
%                     not 1. ***
%                     - 3 if assuming the relationship
%                     (std of nth Gaussian) = n * (std of 1st Gaussian).
%                     This relationship is generalized if variableMean > 1.
%                     *** variableStd can equal 3 only if variableMean is
%                     not 1. ***
%                     Optional. Default: 1.
%       logData     : 1 for log normal data, where the log(data) is being
%                     fitted to a normal distribution, 0 otherwise. Note
%                     that data are passed to this function already after
%                     taking the log.
%                     Optional. Default: 0.
%       gaussParamIn: Matrix with number of rows equal to number of
%                     modes and two columns indicating the mean and
%                     standard deviation of each mode. If input, the
%                     specified mode parameters are used, and only the
%                     mode amplitudes are determined by data fitting. In
%                     this case, the input variableMean and variableStd
%                     are not used.
%                     Optional. Default: [].
%       ratioTol    : Tolerance for ratio between mean/std of 1st Gaussian
%                     and mean/std of subsequent Gaussians.
%                     If 0, ratio is taken strictly.
%                     If > 0, ratio is allowed to wiggle by ratioTol about
%                     the theoretial ratio. 
%                     Optional. Default: 0.
%                     Option currently implemented only for 3 cases:
%                     variableMean ~= 1 and variableStd = 1, 2 or 3.
%
%OUTPUT cumDistrNGauss: Values of the resulting cumulative distribution
%                       given the input abscissa values.
%
%Khuloud Jaqaman, August 2006; major updates in 2014 and 2015

%% Output
% cumDistrNGauss    : cumulative sum of N gaussians, same size as abscissa
% J                 : Jacobian, length(absicissa) x length(param)

cumDistrNGauss = [];

%% Input

%check whether correct number of input arguments was used
if nargin < 2
    disp('--calcCumDistrNGauss: Incorrect number of input arguments!');
    return
end

if nargin < 3 || isempty(variableMean)
    variableMean = 1;
end

if nargin < 4 || isempty(variableStd)
    variableStd = 1;
end

if nargin < 5 || isempty(logData)
    logData = 0;
end
if logData && (variableMean==1&&variableStd~=1)
    disp('--fitHistWithGaussians: For log-normal fit, no current implementation for constrained std but variable mean. Exiting.')
    return
end

if nargin < 6 || isempty(gaussParamIn)
    gaussParamIn = [];
else
    variableMean = -1;
    variableStd = -1;
end

if nargin < 7 || isempty(ratioTol)
    ratioTol = 0;
end

%% Calculating the cumulative distribution

%get the means, standard deviations and amplitudes of the Gaussians from the input
%parameter vector
switch variableMean
    
    case -1 %if mean is given
        
        switch variableStd
            
            case -1 %if std is given
                
                %get number of Gaussians
                numGauss = length(param);
                
                %get their means, stds and amplitudes
                gaussMean = gaussParamIn(:,1);
                gaussStd  = gaussParamIn(:,2);
                gaussAmp  = param;
                
        end
        
    case 1 %if mean is variable

        switch variableStd

            case 0 %if std is constrained to all stds are equal
                %caseCode = 0100
                %get number of Gaussians
                numGauss = floor(length(param)/2);

                %get their means, stds and amplitudes
                gaussMean = param(1:numGauss);
                gaussStd  = repmat(param(numGauss+1),numGauss,1);
                gaussAmp  = param(numGauss+2:end);

            case 1 %if std is variable
                %caseCode = 0110
                %get number of Gaussians
                numGauss = length(param)/3;

                %get their means, stds and amplitudes
                gaussMean = param(1:numGauss);
                gaussStd  = param(numGauss+1:2*numGauss);
                gaussAmp  = param(2*numGauss+1:end);

        end %(switch variableStd)

    otherwise %if mean is constrained to mean_n = n * mean_1
        
        %get relationship of first fitted Gaussian to real first
        %Gaussian in series
        firstGauss = max(variableMean,1);

        switch variableStd
            
            case 0 %if std is constrained to all stds are equal
                
                %get number of Gaussians
                numGauss = length(param)-2;
                
                %get their means, stds and amplitudes
                if ~logData
                    %caseCode = 0000
                    tmpMean = param(1)/firstGauss;
                    gaussMean = (firstGauss:numGauss+firstGauss-1)' * tmpMean;
                    gaussStd  = repmat(param(2),numGauss,1);
                else
                    %caseCode = 1000
                    % mu = log(m / sqrt(1 + v/m^2)) = log(m^2 / sqrt(m^2 + v)
                    % sigma = sqrt(log(1 + v/m^2)) 
                    % calculate mean of the non-logarithmized sample,m
                    % m = exp(mu + sigma^2) = exp(mu)*exp(sigma^2)
                    dataMean1 = exp(param(1)+param(2)^2/2);
                    dataMean1 = dataMean1 / firstGauss;
                    % calculate variance of the non-logarithmized sample,v
                    % v = exp(sigma^2 + 2*mu)*[exp(sigma^2)-1]
                    %   = m^2 * [v/m^2]
                    dataVar1 = exp(param(2)^2+2*param(1))*(exp(param(2)^2)-1);
                    % means of other gaussians are multiples of first mean
                    dataMeanN = (firstGauss:numGauss+firstGauss-1)'*dataMean1;
                    dataVarN = repmat(dataVar1,numGauss,1);
                    % compute the expected logarithmic mean and std
                    gaussMean = log(dataMeanN.^2./sqrt(dataVarN+dataMeanN.^2));
                    gaussStd = sqrt(log(dataVarN./dataMeanN.^2+1));
                end
                gaussAmp  = param(3:end);
                
            case 1 %if std is variable
                
                if sum(ratioTol) == 0 %if strict ratio
                    %get number of Gaussians
                    numGauss = floor(length(param)/2);
                    
                    %get their means, stds and amplitudes
                    if ~logData
                        %caseCode = 0010
                        tmpMean = param(1)/firstGauss;
                        gaussMean = (firstGauss:numGauss+firstGauss-1)' * tmpMean;
                    else
                        %caseCode = 1010
                        dataMean1= exp(param(1)+param(2)^2/2);
                        dataMean1 = dataMean1 / firstGauss;
                        dataMeanN = (firstGauss:numGauss+firstGauss-1)' * dataMean1;
                        gaussMean = log(dataMeanN) - param(2:numGauss+1).^2/2;
                    end
                    gaussStd  = param(2:numGauss+1);
                    gaussAmp  = param(numGauss+2:end);
                    
                else %if there is wiggle room
                    %caseCode = 0011
                    %get number of Gaussians
                    numGauss = length(param)/3;
                    
                    %get their means, stds and amplitudes
                    param = reshape(param,numGauss,3);
                    if ~logData
                        % mktiti: What is firstMode? firstGauss maybe?
                        tmpMean = param(1,1) / firstMode;
                        gaussMean = [firstGauss; param(2:end,1)] * tmpMean;
                    else
                        dataMean1 = exp(param(1,1)+param(1,2)^2/2);
                        dataMean1 = dataMean1 / firstGauss;
                        dataMeanN = [firstGauss; param(2:end,1)] * dataMean1;
                        gaussMean = log(dataMeanN) - param(:,2).^2/2;
                    end
                    gaussStd  = param(:,2);
                    gaussAmp  = param(:,3);
                    
                end
                
            case 2 %if std is constrained to std_n = sqrt(n)*std_1
                
                if sum(ratioTol) == 0 %if strict ratio
                    
                    %get number of Gaussians
                    numGauss = length(param)-2;
                    
                    %get their means, stds and amplitudes
                    if ~logData
                        %caseCode = 0020
                        tmpMean = param(1)/firstGauss;
                        gaussMean = (firstGauss:numGauss+firstGauss-1)' * tmpMean;
                        tmpStd = param(2) / sqrt(firstGauss);
                        gaussStd  = sqrt(firstGauss:numGauss+firstGauss-1)' * tmpStd;
                    else
                        %caseCode = 1020
                        dataMean1 = exp(param(1)+param(2)^2/2);
                        dataMean1 = dataMean1 / firstGauss;
                        dataVar1 = exp(param(2)^2+2*param(1))*(exp(param(2)^2)-1);
                        dataVar1 = dataVar1 / firstGauss;
                        dataMeanN = (firstGauss:numGauss+firstGauss-1)' * dataMean1;
                        dataVarN = (firstGauss:numGauss+firstGauss-1)' * dataVar1;
                        gaussMean = log(dataMeanN.^2./sqrt(dataVarN+dataMeanN.^2));
                        gaussStd = sqrt(log(dataVarN./dataMeanN.^2+1));
                    end
                    gaussAmp  = param(3:end);
                    
                else %if there is wiggle room
                    
                    %get number of Gaussians
                    numGauss = length(param)/3;
                    
                    %get their means, stds and amplitudes
                    param = reshape(param,numGauss,3);
                    if ~logData
                        %caseCode = 0021
                        tmpMean = param(1,1) / firstGauss;
                        gaussMean = [firstGauss; param(2:end,1)] * tmpMean;
                        tmpStd = param(1,2) / sqrt(firstGauss);
                        gaussStd = sqrt([firstGauss; param(2:end,2)]) * tmpStd;
                    else
                        %caseCode = 1021
                        dataMean1 = exp(param(1,1)+param(1,2)^2/2);
                        dataMean1 = dataMean1 / firstGauss;
                        dataVar1 = exp(param(1,2)^2+2*param(1,1))*(exp(param(1,2)^2)-1);
                        dataVar1 = dataVar1 / firstGauss;
                        dataMeanN = [firstGauss; param(2:end,1)] * dataMean1;
                        dataVarN = [firstGauss; param(2:end,2)] * dataVar1;
                        gaussMean = log(dataMeanN.^2./sqrt(dataVarN+dataMeanN.^2));
                        gaussStd = sqrt(log(dataVarN./dataMeanN.^2+1));
                    end
                    gaussAmp = param(:,3);
                    
                end

            case 3 %if std is constrained to std_n = n*std_1
                
                if sum(ratioTol) == 0 %if strict ratio
                    
                    %get number of Gaussians
                    numGauss = length(param)-2;
                    
                    %get their means, stds and amplitudes
                    if ~logData
                        %caseCode = 0030
                        tmpMean = param(1)/firstGauss;
                        gaussMean = (firstGauss:numGauss+firstGauss-1)' * tmpMean;
                        tmpStd = param(2) / firstGauss;
                        gaussStd  = (firstGauss:numGauss+firstGauss-1)' * tmpStd;
                    else
                        %caseCode = 1030
                        dataMean1 = exp(param(1)+param(2)^2/2);
                        dataMean1 = dataMean1 / firstGauss;
%                         dataVar1 = exp(param(2)^2+2*param(1))*(exp(param(2)^2)-1);
%                         dataVar1 = dataVar1 / (firstGauss^2);
                        dataMeanN = (firstGauss:numGauss+firstGauss-1)' * dataMean1;
%                         dataVarN = (firstGauss:numGauss+firstGauss-1)'.^2 * dataVar1;
%                         gaussMean = log(dataMeanN.^2./sqrt(dataVarN+dataMeanN.^2));
                        % mkitti: param(2) is gaussStd for all gaussians
                        gaussMean = log(dataMeanN) - param(2)^2/2;
                        % umm isn't all(gaussStd(:) == gaussStd(1)) ?? yes
                        % gaussStd = sqrt(log(dataVarN./dataMeanN.^2+1));
                        % mkitti: gaussStd is same for all gaussians
                        gaussStd = repmat(param(2),numGauss,1);
                    end
                    gaussAmp  = param(3:end);
                    
                else %if there is wiggle room
                    
                    %get number of Gaussians
                    numGauss = length(param)/3;
                    
                    %get their means, stds and amplitudes
                    param = reshape(param,numGauss,3);
                    if ~logData
                        %caseCode = 0031
                        tmpMean = param(1,1) / firstGauss;
                        gaussMean = [firstGauss; param(2:end,1)] * tmpMean;
                        tmpStd = param(1,2) / firstGauss;
                        gaussStd = [firstGauss; param(2:end,2)] * tmpStd;
                    else
                        %caseCode = 1031
                        dataMean1 = exp(param(1,1)+param(1,2)^2/2);
                        dataMean1 = dataMean1 / firstGauss;
                        dataVar1 = exp(param(1,2)^2+2*param(1,1))*(exp(param(1,2)^2)-1);
                        dataVar1 = dataVar1 / (firstGauss^2);
                        dataMeanN = [firstGauss; param(2:end,1)] * dataMean1;
                        dataVarN = [firstGauss; param(2:end,2)].^2 * dataVar1;
                        gaussMean = log(dataMeanN.^2./sqrt(dataVarN+dataMeanN.^2));
                        gaussStd = sqrt(log(dataVarN./dataMeanN.^2+1));
                    end
                    gaussAmp = param(:,3);
                    
                end
                
        end %(switch variableStd)
        
end %(switch variableMean)

%% mkitti original code
%calculate the cumulative distribution
% cumDistrNGauss = zeros(size(abscissa));
% for i=1:numGauss
%     cumDistrNGauss = cumDistrNGauss + gaussAmp(i)*normcdf(abscissa,...
%         gaussMean(i),gaussStd(i));
% end

%% mkitti: vectorization of normcdf
% abscissaSize = size(abscissa);
% nAbscissa = prod(abscissaSize);
% abscissa = abscissa(:);
% % gaussMean, gaussStd should be a 1 x numGauss row vectors
% gaussMean = gaussMean(:)';
% gaussStd = gaussStd(:)';
% % expand to match
% abscissa = abscissa(:,ones(1,numGauss));
% nAbscissaOnes = ones(1,nAbscissa);
% gaussMean = gaussMean(nAbscissaOnes,:);
% gaussStd = gaussStd(nAbscissaOnes,:);
% % produce a numel(abscissa) X numGauss matrix
% cumDistrNGauss = ...
%      normcdf(    abscissa ...
%               , gaussMean ...
%               ,  gaussStd ...
%               );

% %% mkitti: inlining normcdf
% % TODO: Check if gaussStd == 0
abscissaSize = size(abscissa);
% nAbscissa = prod(abscissaSize);
abscissa = abscissa(:);
% gaussMean, gaussStd should be a 1 x numGauss row vectors
gaussMean = gaussMean(:)';
gaussStd = gaussStd(:)';
% z = (x-mu) ./ sigma
z = bsxfun(@rdivide,bsxfun(@minus,abscissa,gaussMean),gaussStd);
% sqrt because we want the normalized cdf
cumDistrNGauss = 0.5 * erfc(-z ./ sqrt(2));
% check for zeros
gaussStdEqZero = ~gaussStd;
if(any(gaussStdEqZero))
    cumDistrNGauss(:,gaussStdEqZero) = bsxfun(@ge,abscissa,gaussMean(gaussStdEqZero));
end


%% Calculate Jacobian
if(nargout > 1)
    % d(erfc(z)) / dz = -2e^{-z^2} / sqrt(pi)
    % d(cumDistrNGauss) / dz = e^{-z^2/2} / sqrt(2*pi)
    dcumDistrNGauss_dz = exp(-z.^2/2)./sqrt(2*pi);
    % d(z) / d(abscissa)  = 1 / gaussStd
    % d(z) / d(gaussMean) = - 1 / gaussStd
    % d(cumDistrNGauss) / d(gaussMean) = d(cumDistrNGauss) / dz * -1/gaussStd
    dcumDistrNGauss_dgaussMean = -bsxfun(@times,dcumDistrNGauss_dz,gaussAmp(:)'./gaussStd);
    % d(z) / d(gaussStd)  = -(abscissa - gaussMean)/gaussStd.^2
    %                     = -z/gaussStd
    % d(cumDistrNGauss) / d(gaussStd) = d(cumDistrNGauss) / dz * -z/gaussStd
    % dcumDistrNGauss_dgaussStd = bsxfun(@rdivide,dcumDistrNGauss_dz.*z,gaussStd);
    %
    % d(cumDistrNGauss) / d(gaussStd) = d(cumDistrNGauss) / d(gaussMean) * z
    
    % Maximum relative difference between user-supplied and
    % finite-difference derivatives exceeds 1e-6 for the Std calculation
    dcumDistrNGauss_dgaussStd = dcumDistrNGauss_dgaussMean .* z;
    dcumDistrNGauss_dgaussAmp = cumDistrNGauss;

    if(variableMean == -1 || variableStd == -1)
            J = dcumDistrNGauss_dgaussAmp;
    else
        % caseCode in decimal: LMSR (we should use this above)
        caseCode = logData*1000 + (variableMean == 1)*100 + variableStd*10 + (sum(ratioTol)~=0);
        switch(caseCode)
%                 case 0100
%                         % variableMean
%                         % J = nAbscissa x 2 numGauss + 1 = nX x (nGaussMean,1 gaussStd, nGaussAmp)
%                         J = [dcumDistrNGauss_dgaussMean sum(dcumDistrNGauss_dgaussStd,2) dcumDistrNGauss_dgaussAmp];
%                 case 0110
%                         % variableMean and variableStd
%                         % J = nAbscissa x 3 numGauss = nX x (nGaussMean,nGaussStd,nGaussAmp)
%                         J = [dcumDistrNGauss_dgaussMean dcumDistrNGauss_dgaussStd dcumDistrNGauss_dgaussAmp];
%                 case 0000
%                         % constrained mean and single std
%                         % J = nAbscissa x 2 + numGauss = nX x (gaussMean, gaussStd, nGaussAmp)
%                         J = [dcumDistrNGauss_dguassMean*(1+(0:numGauss-1)/firstGauss)' sum(dcumDistrNGauss_dgaussStd,2) dcumDistrNGauss_dgaussAmp];
%                 case 1000
%                         % logData constrained mean, single std
%                         J = [sum(dcumDistrNGauss_dguassMean,2) sum(dcumDistrNGauss_dgaussStd,2) dcumDistrNGauss_dgaussAmp];
%                 case 0010
%                         % constrained mean, variable std
%                         % J = nAbscissa x 1 + 2*numGAuss = nX x (guassMean, nGaussStd, nGaussAmp)
%                         J = [dcumDistrNGauss_dguassMean*(1+(0:numGauss-1)/firstGauss)' dcumDistrNGauss_dgaussStd dcumDistrNGauss_dgaussAmp];
%                 case 1010
%                         % logData, constrained mean, variable std
%                         J = [sum(dcumDistrNGauss_dguassMean,2) dcumDistrNGauss_dgaussStd dcumDistrNGauss_dgaussAmp];
%                 case 0011
%                         % constrained mean, variable std, wiggle room
%                         % J = nAbscissa x 3 numGauss = nX x (nGaussMean,nGaussStd,nGaussAmp)
%                         J = [dcumDistrNGauss_dgaussMean dcumDistrNGauss_dgaussStd dcumDistrNGauss_dgaussAmp];
%                 case 0020
%                         % J = nAbscissa x 2 + numGauss
%                         %   = nX x (gaussMean,gaussStd,nGaussAmp)
%                         J = [dcumDistrNGauss_dguassMean*(1+(0:numGauss-1)/firstGauss)' dcumDistrNGauss_dgaussStd*sqrt(1+(0:numGauss-1)/firstGauss)' dcumDistrNGauss_dgaussAmp];
%                 case 1020
%                 case 0021
%                         % J = nAbscissa x 3 numGauss = nX x (nGaussMean,nGaussStd,nGaussAmp)
%                         J = [dcumDistrNGauss_dgaussMean dcumDistrNGauss_dgaussStd*[1 sqrt(param(2:end,2)/firstGauss)]' bsxfun(@rdivide,dcumDistrNGauss_dgaussStd(:,2:end),param(2:end,2)')/2 dcumDistrNGauss_dgaussAmp];
%                 case 1021
%                 case 0030
%                         % J = nAbscissa x (2 + numGauss )
%                         %   = nAbscissa x (gaussMean,gaussStd,nGaussAmp)
%                         J = [dcumDistrNGauss_dgaussMean*(1+(0:numGauss-1)/firstGauss)' dcumDistrNGauss_dgaussStd*(1+(0:numGauss-1)/firstGauss)' dcumDistrNGauss_dgaussAmp];
                case 1030
                        % J = nAbscissa x (2 + numGauss )
                        %   = nAbscissa x (gaussMean,gaussStd,nGaussAmp)
                        J = [sum(dcumDistrNGauss_dgaussMean,2) sum(dcumDistrNGauss_dgaussStd,2) dcumDistrNGauss_dgaussAmp];
                        assert(~any(isnan(J(:))));
%                 case 0031
%                         % J = nAbscissa x 3 numGauss = nX x (nGaussMean,nGaussStd,nGaussAmp)
%                         J = [dcumDistrNGauss_dgaussMean dcumDistrNGauss_dgaussStd dcumDistrNGauss_dgaussAmp];
%                 case 1031
%                         % J = nAbscissa x 3 numGauss = nX x (nGaussMean,nGaussStd,nGaussAmp)
%                         J = [dcumDistrNGauss_dgaussMean dcumDistrNGauss_dgaussStd dcumDistrNGauss_dgaussAmp];
                otherwise
                        error('calcCumDistrNGauss:JacobianCaseNotImplemented', ...
                                'The Jacobian has not been implemented for this input case');
        end
    end

end

%% mkitti: Finish vectorization / inlining by summing gaussians together
% gaussAmp(:) should be a numGauss x 1 column vector
% product should be a numel(abscissa) x 1 column vector
cumDistrNGauss = cumDistrNGauss * gaussAmp(:);
cumDistrNGauss = reshape(cumDistrNGauss,abscissaSize);

%% %%% ~~ the end ~~ %%%%%
