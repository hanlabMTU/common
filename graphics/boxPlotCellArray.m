function [sucess]=boxPlotCellArray(cellArrayData,nameList,convertFactor,notchOn,plotIndivPoint,forceShowP,markerSize)
% function []=boxPlotCellArray(cellArrayData,nameList,convertFactor,notchOn,plotIndivPoint,forceShowP) automatically converts cell array
% format input to matrix input to use matlab function 'boxplot'
% input: cellArrayData          cell array data
%           nameList            cell array containing name of each
%                               condition (ex: {'condition1' 'condition2' 'condition3'})
%           convertFactor       conversion factor for physical unit (ex.
%                               pixelSize, timeInterval etc...)
%           forceShowP          0 if you want to show only significant p
%                               1 if you want to show all p 
%                               2 if you do not want to show any p
% Sangyoon Han, March 2016
[lengthLongest]=max(cellfun(@(x) length(x),cellArrayData));
%If there is no data, exclude them in the plot
idEmptyData = cellfun(@isempty,cellArrayData);
cellArrayData(idEmptyData)=[];
sucess=false;
% Return when one of columns are all NaNs
isAnyGroupAllNaNs = cellfun(@(x) all(isnan(x)), cellArrayData);
if any(isAnyGroupAllNaNs)
    disp([num2str(find(isAnyGroupAllNaNs)) 'th group contains all NaNs. Returning...'])
    return
end

numConditions = numel(cellArrayData);
matrixData = NaN(lengthLongest,numConditions);
for k=1:numConditions
    matrixData(1:length(cellArrayData{k}),k) = cellArrayData{k};
end
if all(isnan(matrixData(:)))
    disp('All data are NaNs. Returning...')
    return
end

if nargin<7
    markerSize=2;
end
if isempty(matrixData)
    text(0.4,0.5,'Empty Data')
    return
end
if nargin<6
    markerSize=2;
    forceShowP=false;
end
if nargin<5
    markerSize=2;
    forceShowP=false;
    plotIndivPoint = true;
end
if nargin<4
    markerSize=2;
    forceShowP=false;
    notchOn=true;
    plotIndivPoint = true;
end
if nargin<3
    markerSize=2;
    forceShowP=false;
    convertFactor = 1;
    notchOn=true;
end
if nargin<2
    markerSize=2;
    nameList=arrayfun(@(x) num2str(x),(1:numConditions),'UniformOutput',false);
    convertFactor = 1;
    notchOn=true;
    forceShowP=false;
end
nameList(idEmptyData)=[];

boxWidth=0.5;
whiskerRatio=1.5;
matrixData=matrixData*convertFactor;
nameListNew = cellfun(@(x,y) [x '(N=' num2str(sum(~isnan(y))) ')'],nameList,cellArrayData,'UniformOutput', false);

onlyOneDataAllGroups=false;
numCategories = numel(cellArrayData);
onlyOneDataPerEachGroup=false(1,numCategories);
if plotIndivPoint
    % individual data jitter plot
%     numCategories = size(matrixData,2);
    % width=boxWidth/2;
    for ii=1:numCategories
        curNumData = numel(matrixData(:,ii));
        if curNumData==1
            plot(ii,matrixData(:,ii),'k.')
            onlyOneDataPerEachGroup(ii)=true;
        else
            xData = ii+0.1*boxWidth*(randn(size(matrixData,1),1));
            scatter(xData,matrixData(:,ii),'filled','MarkerFaceColor',[.3 .3 .3],'MarkerEdgeColor','none','SizeData',markerSize)
        end
        hold on
    end
    alpha(.5)
end
if all(onlyOneDataPerEachGroup)
    onlyOneDataAllGroups=true;
end
if ~onlyOneDataAllGroups
    if notchOn %min(sum(~isnan(matrixData),1))>20 || 
        boxplot(matrixData,'whisker',whiskerRatio,'notch','on',...
            'labels',nameListNew,'symbol','','widths',boxWidth,'jitter',1,'colors','k');%, 'labelorientation','inline');
    else % if the data is too small, don't use notch
%         boxplot(matrixData,'whisker',whiskerRatio*0.95,'notch','off',...
%             'labels',nameListNew,'symbol','','widths',boxWidth,'jitter',0,'colors','k');%, 'labelorientation','inline');
        boxplot(matrixData,...
            'labels',nameListNew,'symbol','','widths',boxWidth,'jitter',0,'colors','k');%, 'labelorientation','inline');
    end
else
    xlim([0 numCategories+1])
    set(gca,'XTick',1:numCategories)
    set(gca,'XTicklabel',nameListNew)
end    
set(findobj(gca,'LineStyle','--'),'LineStyle','-')
set(findobj(gca,'tag','Median'),'LineWidth',2)
% set(gca,'XTick',1:numel(nameList))
% set(gca,'XTickLabel',nameList)
set(gca,'XTickLabelRotation',45)
curAxes = gca;

% hold on
% perform ranksum test for every single combination
maxPoint = quantile(matrixData,[0.25 0.75]);
if size(matrixData,2)>1
    maxPoint2 = maxPoint(2,:)+(maxPoint(2,:)-maxPoint(1,:))*whiskerRatio;
    maxPoint2 = max(maxPoint2);
else
    maxPoint2 = maxPoint(2)+(maxPoint(2)-maxPoint(1))*whiskerRatio;
end
lineGap=maxPoint2*0.05;
q=0;
for k=1:(numConditions-1)
    for ii=k+1:numConditions
        if numel(cellArrayData{k})>1 && numel(cellArrayData{ii})>1
            if kstest(cellArrayData{k}) % this means the test rejects the null hypothesis
                [p]=ranksum(cellArrayData{k},cellArrayData{ii});
                if (p<0.05 && forceShowP~=2) || forceShowP==1 
                    q=q+lineGap;
                    line([k ii], ones(1,2)*(maxPoint2+q),'Color','k')    
                    q=q+lineGap;
                    text(floor((k+ii)/2)+0.3, maxPoint2+q,['p=' num2str(p) ' (r)'])
                end
            else
                [~,p]=ttest2(cellArrayData{k},cellArrayData{ii});
                if (p<0.05 && forceShowP~=2) || forceShowP==1
                    q=q+lineGap;
                    line([k ii], ones(1,2)*(maxPoint2+q),'Color','k')    
                    q=q+lineGap;
                    text(floor((k+ii)/2)+0.3, maxPoint2+q,['p=' num2str(p) ' (t)'])
                end
            end
        end
    end
end
q=q+lineGap*3;
minPoint = quantile(matrixData,[0.25 0.75]);
if size(matrixData,2)>1
    minPoint2 = minPoint(1,:)-(minPoint(2,:)-minPoint(1,:))*whiskerRatio;
    minPoint2 = min(minPoint2);
else
    minPoint2 = minPoint(2)-(minPoint(2)-minPoint(1))*whiskerRatio;
end
if plotIndivPoint && ~forceShowP
    maxPoint2 = quantile(matrixData(:),0.99);
else
    maxPoint2 = maxPoint2+q;
end
if maxPoint2>minPoint2-lineGap*2
    ylim([minPoint2-lineGap*2 maxPoint2])
else
    ylim auto
end

set(gca,'FontSize',7)
set(findobj(gca,'Type','Text'),'FontSize',6)
sucess=true;
hold off

