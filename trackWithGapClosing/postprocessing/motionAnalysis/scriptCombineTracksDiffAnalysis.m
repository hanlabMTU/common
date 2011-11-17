tracksDir = '/home/kj35/files/LCCB/receptors/Galbraiths/data/alphaVandCellEdge/110908_Cs2C1_CHO_AV/analysisAlphaV/tracks';
diffDir = '/home/kj35/files/LCCB/receptors/Galbraiths/data/alphaVandCellEdge/110908_Cs2C1_CHO_AV/analysisAlphaV/diffusion';

tracksFileName = {...
    'tracks1All_01.mat',...
    'tracks1All_02.mat',...
    'tracks1All_03.mat',...
    'tracks1All_04.mat',...
    'tracks1All_05.mat',...
    'tracks1All_06.mat',...
    'tracks1All_07.mat',...
    'tracks1All_08.mat',...
    'tracks1All_09.mat',...
    'tracks1All_10.mat',...
    'tracks1All_11.mat',...
    'tracks1All_12.mat',...
    'tracks1All_13.mat',...
    'tracks1All_14.mat',...
    'tracks1All_15.mat',...
    'tracks1All_16.mat',...
    'tracks1All_17.mat',...
    'tracks1All_18.mat',...
    'tracks1All_19.mat',...
    'tracks1All_20.mat',...
    'tracks1All_21.mat',...
    'tracks1All_22.mat',...
    'tracks1All_23.mat',...
    'tracks1All_24.mat',...
    'tracks1All_25.mat',...
    'tracks1All_26.mat',...
    };

diffFileName = {...
    'diffusion1All_01.mat',...
    'diffusion1All_02.mat',...
    'diffusion1All_03.mat',...
    'diffusion1All_04.mat',...
    'diffusion1All_05.mat',...
    'diffusion1All_06.mat',...
    'diffusion1All_07.mat',...
    'diffusion1All_08.mat',...
    'diffusion1All_09.mat',...
    'diffusion1All_10.mat',...
    'diffusion1All_11.mat',...
    'diffusion1All_12.mat',...
    'diffusion1All_13.mat',...
    'diffusion1All_14.mat',...
    'diffusion1All_15.mat',...
    'diffusion1All_16.mat',...
    'diffusion1All_17.mat',...
    'diffusion1All_18.mat',...
    'diffusion1All_19.mat',...
    'diffusion1All_20.mat',...
    'diffusion1All_21.mat',...
    'diffusion1All_22.mat',...
    'diffusion1All_23.mat',...
    'diffusion1All_24.mat',...
    'diffusion1All_25.mat',...
    'diffusion1All_26.mat',...
    };

numFiles = length(tracksFileName);

%initialize temporary structures
tmpD = repmat(struct('field',[]),numFiles,1);
tmpT = tmpD;

for j = 1 : numFiles
    
    disp(num2str(j));
    
    %get tracks for this time interval
    load(fullfile(tracksDir,tracksFileName{j}));
    
    %do diffusion analysis
    diffAnalysisRes = trackDiffusionAnalysis1(tracksFinal,1,2,1,[0.05 0.1],0,0);
    
    %save diffusion analysis of this time interval
    save(fullfile(diffDir,diffFileName{j}),'diffAnalysisRes');
    
    %store tracks and diffusion analysis in temporary structures
    tmpD(j).field = diffAnalysisRes;
    tmpT(j).field = tracksFinal;
    
end

%save combined diffusion analysis
diffAnalysisRes = vertcat(tmpD.field);
save(fullfile(diffDir,'diffAnalysis1AllFrames'),'diffAnalysisRes');

%save combined tracks
tracksFinal = vertcat(tmpT.field);
save(fullfile(tracksDir,'tracks1AllFrames'),'tracksFinal');
