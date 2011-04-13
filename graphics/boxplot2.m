%BOXPLOT2 Box plot grouping multiple sets/categories of data, with error bars and SEM.
%
% INPUTS:   prm : matrix or cell array of matrices that contain the box properties:
%                 row 1: mean or median
%                 row 2: optional, SEM
%                 row 2/3: 25th percentile, bottom of box
%                 row 3/4: 75th percentile, top of box
%                 row 4/5: optional, bottom whisker
%                 row 5/6: optional, top whisker
%         color : Nx3 matrix of colors, where N is the number of bars
%       xLabels : cell array of strings, labels for each bar
%        yLabel : string, y-axis label
%
% Example: boxplot2({[3 4; 0.2 0.2; 2 3; 4 5; 0.5 0.5; 0.5 0.5]});

% Francois Aguet, 22 Feb 2011
% Last modified: 12 April 2011

function boxplot2(prm, color, varargin)

if isnumeric(prm)
    prm = {prm};
end
nbars = sum(cellfun(@(x) size(x,2), prm));

ip = inputParser;
ip.CaseSensitive = false;
ip.addRequired('prm', @iscell);
ip.addOptional('color', hsv2rgb([rand(nbars,1) ones(nbars,2)]));
ip.addParamValue('xlabel', [], @ischar);
ip.addParamValue('xlabels', [], @(x) all(cellfun(@(y) ischar(y), x)));
ip.addParamValue('ylabel', [], @ischar);
ip.parse(prm, color, varargin{:});


if size(color,1)==1
    color = repmat(color, [nbars 1]);
end

fsize = 16;
bw = 0.8; % bar width
dx = (1-bw)/2;
dg = 4*dx;

ng = length(prm);
xa = cell(1,ng);

hold on;
for k = 1:ng
    nb = size(prm{k},2);
    
    xa{k} = (1:nb) + (k-1)*(nb + dg);
    plotSEM = mod(size(prm{k},1),2)==0;
    
    mu = prm{k}(1,:);
    if plotSEM
        p25 = prm{k}(3,:);
        p75 = prm{k}(4,:);
    else
        p25 = prm{k}(2,:);
        p75 = prm{k}(3,:);
    end
    
    % whiskers (plot first to mask bar at '0')
    if plotSEM && size(prm{k},1)>4
        w1 = prm{k}(5,:);
        w2 = prm{k}(6,:);
        plotWhiskers = 1;
    elseif size(prm{k},1)>3
        w1 = prm{k}(4,:);
        w2 = prm{k}(5,:);
        plotWhiskers = 1;
    else
        plotWhiskers = 0;
    end
    
    if plotWhiskers
        he = errorbar(xa{k}, p25, w1, zeros(size(mu)), 'k', 'LineStyle', 'none', 'LineWidth', 2);
        setErrorbarStyle(he);
        he = errorbar(xa{k}, p75, zeros(size(mu)), w2, 'k', 'LineStyle', 'none', 'LineWidth', 2);
        setErrorbarStyle(he);
    end
    
    % the box
    lb = xa{k} - bw/2;
    rb = xa{k} + bw/2;
    xv = [lb; rb; rb; lb; lb; rb];
    yv = [p75; p75; p25; p25; p75; p75];
    %patch(xv, yv, 'r', 'LineWidth', 2);

    for b = 1:nb
        patch(xv(:,b), yv(:,b), color(b+(k-1)*nb,:), 'LineWidth', 2);
    end
    
    
    % mean/median line
    line([lb; rb], [mu; mu], 'Color', [0 0 0], 'LineWidth', 3);
    
    % SEM
    if plotSEM
        sigma = prm{k}(2,:);
        he = errorbar(xa{k}, mu, sigma, 'k', 'LineStyle', 'none', 'LineWidth', 2);
        setErrorbarStyle(he, 0.15);
    end
end
hold off;

box off;
xa = [xa{:}];
set(gca, 'FontName', 'Helvetica', 'FontSize', fsize, 'LineWidth', 1.5,...
    'XTick', xa, 'XLim', [0.5-dx/2 xa(end)+0.5+dx/2]);

YLim = get(gca, 'YLim');
set(gca, 'Ylim', [0, YLim(2)+1]);

width = diff(get(gca, 'XLim'));
height = diff(get(gca, 'YLim'));

% get height of default text bounding box
h = text(0, 0, ' ', 'FontName', 'Helvetica', 'FontSize', fsize);
textHeight = get(h, 'extent');
textHeight = textHeight(4);
extent = textHeight/sqrt(2)/2 * width/height;
delete(h);


% x label
if ~isempty(ip.Results.xlabels)
    set(gca, 'XTickLabel', []);
    xlabels = arrayfun(@(k) text(xa(k)-extent,-0.01*height, ip.Results.xlabels{k},...
        'VerticalAlignment', 'Top', 'HorizontalAlignment', 'Right',...
        'Rotation', 45, 'FontName', 'Helvetica', 'FontSize', fsize), 1:length(xa));
    
    maxHeight = max(cellfun(@(x) x(4), arrayfun(@(x) get(x, 'extent'), xlabels, 'UniformOutput', false)));
else
    set(gca, 'XTickLabel', 1:nbars);
    maxHeight = 0;
end

if ~isempty(ip.Results.xlabel)
    hx = xlabel(ip.Results.xlabel, 'FontName', 'Helvetica', 'FontSize', fsize);
    
    position = get(hx, 'Position');
    xlabelHeight = get(hx, 'extent');
    xlabelHeight = xlabelHeight(4) - position(2);
    position(2) = position(2) - 0.02*height - maxHeight;
    set(hx, 'Position', position);
else
    xlabelHeight = 0;
end

% set final axis position
total = (height*1.01 + maxHeight + xlabelHeight) * 1.05;
position = get(gca, 'Position');
position([2 4]) = [height*0.02+maxHeight+xlabelHeight height]/total;
set(gca, 'Position', position);

% y label
if ~isempty(ip.Results.ylabel)
    ylabel(ip.Results.ylabel, 'FontName', 'Helvetica', 'FontSize', fsize);
end




function setErrorbarStyle(he, de)
if nargin<2
    de = 0.2;
end

he = get(he, 'Children');
xd = get(he(2), 'XData');
xd(4:9:end) = xd(1:9:end) - de;
xd(7:9:end) = xd(1:9:end) - de;
xd(5:9:end) = xd(1:9:end) + de;
xd(8:9:end) = xd(1:9:end) + de;
set(he(2), 'XData', xd);
