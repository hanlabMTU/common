function compTracksOut = aggregStateFromCompTracks(compTracks,intensityInfo)
%AGGREGSTATEFROMCOMPTRACKS recovers particle aggregation states from compound tracks
%
%SYNOPSIS compTracks = aggregStateFromCompTracks(compTracks,intensityInfo)
%
%INPUT  compTracks   : Compound tracks, in the format of tracksFinal as
%                      output by trackCloseGapsKalman.
%       intensityInfo: Row vector with unit intensity mean and standard
%                      deviation (e.g. the intensity of a single
%                      fluorophore labeling a single receptor).
%
%OUTPUT compTracks   : -Structure with the 2 fields "defaultFormatTracks" and
%                       "alternativeFormatTracks". 
%                      -Both contain the fields "tracksFeatIndxCG",
%                       "tracksCoordAmpCG", "seqOfEvents" and "aggregState".
%                      -"alternativeFormatTracks" also contains the field
%                       "alt2defSegmentCorrespond".
%                      -"defaultFormatTracks" is the format of the output of
%                       "trackCloseGapsKalman". 
%                      -"alternativeFormatTracks" is the format generated by
%                       the function "convFormatDefault2Alt", where tracks
%                       do not continue through merges and splits, but a
%                       merge consists of 2 track segments mergng to form a
%                       3rd segment, and a split consists of 1 track segment
%                       splitting into 2 different segments. 
%                      -The field "aggregState" has the same dimensions as
%                       "tracksFeatIndxCG", and indicates the estimated
%                       number of units (e.g. receptors) within each
%                       detected particle/feature.
%
%REMARKS Code does not handle properly the case of multiple merges with or
%        multiple splits from the same track segment at the same time. Bug
%        must be fixed. This situation arises with simulated data.
%
%Khuloud Jaqaman, February 2009

%% Input

%assign default intensityInfo if not input
if nargin < 2 || isempty(intensityInfo)
    intensityInfo = [];
else
    %if unit intensity is input, construct vector of integer multiples of
    %mean unit intensity
    multUnitAmp = intensityInfo(1)*(1:100)';
end

%get number of compound tracks
numTracks = length(compTracks);

%convert tracks from default format (output of trackCloseGapsKalman) to
%alternative format where there is no track continuation through a merge or
%a split
compTracksDef = compTracks;
compTracks = convTrackFormatDefault2Alt(compTracksDef);

%% Calculation

%go over all compound tracks
for iTrack = 1 : numTracks
    
    %get this compound track's information
    seqOfEvents = compTracks(iTrack).seqOfEvents;
    tracksFeatIndx = compTracks(iTrack).tracksFeatIndxCG;
    tracksAmp = compTracks(iTrack).tracksCoordAmpCG(:,4:8:end);

    %     %if requested, remove splits and merges that are most likely artifacts
    %     removePotArtifacts = 0;
    %     if removePotArtifacts
    %         seqOfEvents = removeSplitMergeArtifacts(seqOfEvents,0);
    %     end

    %determine whether track is sampled regularly or with doubled frequency
    doubleFreq = mod(seqOfEvents(1,1)*2,2)==1;

    %shift time in seqOfEvents to make the track start at frame 1 or 0.5
    %if sampling frequency is doubled
    seqOfEvents(:,1) = seqOfEvents(:,1) - seqOfEvents(1,1) + 1/(1+doubleFreq);

    %find all merging and splitting events
    msEvents = find(~isnan(seqOfEvents(:,4)));
    numMSEvents = length(msEvents);

    %initialize matrix storing aggregation state
    %     if isempty(intensityInfo) %if no information is given on the unit intensity
    aggregStateMat = tracksFeatIndx; %initialize every branch with 1 unit
    aggregStateMat = double((aggregStateMat ~= 0));
    aggregStateMat(aggregStateMat==0) = NaN;
    %     else %if there is unit intensity information
    %
    %     end

    %if this track does not exhibit any merges or splits, and there is unit
    %intensity information ...
    if numMSEvents == 0 && ~isempty(intensityInfo)
        
        %get this track's average intensity
        meanAmp = nanmean(tracksAmp);
        
        %subtract the integer multiples of the unit intensity from the
        %track's mean intensity
        meanAmpMinusMultUnitAmp = abs(meanAmp - multUnitAmp);
        
        %determine integer multiple yielding smallest difference
        intMult = find(meanAmpMinusMultUnitAmp==min(meanAmpMinusMultUnitAmp));
        
        %assign this value to the aggregation state of this track
        aggregStateMat = aggregStateMat * intMult;
        
    end %(if numMSEvents == 0)
    
    
    %go over merging and splitting events and modify aggregation state
    %accordingly
    for iEventTmp = 1 : 2 : numMSEvents
        
        %get event index
        iEvent = msEvents(iEventTmp);
        iEventPlus1 = msEvents(iEventTmp+1);
        
        %get nature and time of event
        eventTime = seqOfEvents(iEvent,1);
        eventType = seqOfEvents(iEvent,2);
        
        %update aggregation state based on event type
        switch eventType
            
            case 1 %split
                
                %find the two splitting segments and the segment they split
                %from
                segmentOriginal = seqOfEvents(iEvent,4);
                segmentSplitting1 = seqOfEvents(iEvent,3);
                segmentSplitting2 = seqOfEvents(iEventPlus1,3);
                
                %get number of molecules in original segment
                numMolecules = aggregStateMat(segmentOriginal,eventTime*(1+doubleFreq)-1);
                
                %if the original segment has only 1 molecule ...
                if numMolecules == 1

                    %add 1 molecule to its aggregation state before the
                    %split
                    aggregStateMat(segmentOriginal,1:eventTime*(1+doubleFreq)-1) = ...
                        aggregStateMat(segmentOriginal,1:eventTime*(1+doubleFreq)-1) + 1;

                    %determine how the original segment started
                    origSegmentStartEvent = find(seqOfEvents(:,2)==1 & ...
                        seqOfEvents(:,3)==segmentOriginal);
                    if ~isempty(origSegmentStartEvent) %if segment started by a birth or a split
                        fromSplit = ~isnan(seqOfEvents(origSegmentStartEvent,4)); %check whether it's from a split
                        fromMerge = 0; %in this case it's not from a merge
                    else
                        origSegmentStartEvent = find(seqOfEvents(:,4)==segmentOriginal);
                        fromMerge = 1;
                        fromSplit = 0;
                    end

                    %as long as an "original" segment started from a split
                    %or a merge, loop and update aggregation state
                    %stop when a segment finally starts from a birth
                    while fromSplit || fromMerge

                        if fromSplit %if segment started from a split

                            %find split time and segment it split from
                            splitTime = seqOfEvents(origSegmentStartEvent,1);
                            segmentOrigOrig = seqOfEvents(origSegmentStartEvent,4);

                            %update the aggregation state of the segment it split
                            %from, before the split
                            aggregStateMat(segmentOrigOrig,1:splitTime*(1+doubleFreq)-1) = ...
                                aggregStateMat(segmentOrigOrig,1:splitTime*(1+doubleFreq)-1) + 1;

                            %determine how this "original original" segment
                            %started
                            origSegmentStartEvent = find(seqOfEvents(:,2)==1 & ...
                                seqOfEvents(:,3)==segmentOrigOrig);
                            if ~isempty(origSegmentStartEvent) %if segment started by a birth or a split
                                fromSplit = ~isnan(seqOfEvents(origSegmentStartEvent,4)); %check whether it's from a split
                                fromMerge = 0; %in this case it's not from a merge
                            else
                                origSegmentStartEvent = find(seqOfEvents(:,2)==2 & ...
                                    seqOfEvents(:,4)==segmentOrigOrig);
                                fromMerge = 1;
                                fromSplit = 0;
                            end

                        else %if segment started from a merge
                            
                            %find merge time and segments merging to form
                            %it
                            mergeTime = seqOfEvents(origSegmentStartEvent(1),1);
                            segmentMerge1 = seqOfEvents(origSegmentStartEvent(1),3);
                            segmentMerge2 = seqOfEvents(origSegmentStartEvent(2),3);

                            %calculate the average intensity of the two segments
                            %before merging
                            segmentAmp1 = nanmean(tracksAmp(segmentMerge1,:));
                            segmentAmp2 = nanmean(tracksAmp(segmentMerge2,:));
                            segmentMerge12 = [segmentMerge1 segmentMerge2];
                            segmentAmp12 = [segmentAmp1 segmentAmp2];

                            %identify which segment has higher amplitude,
                            %and make that the "original original" segment
                            segmentBrighter = find(segmentAmp12==max(segmentAmp12));
                            segmentBrighter = segmentBrighter(1);
                            segmentOrigOrig = segmentMerge12(segmentBrighter);

                            %update the aggregation state of the brighter
                            %merging segment
                            aggregStateMat(segmentOrigOrig,1:mergeTime*(1+doubleFreq)-1) = ...
                                aggregStateMat(segmentOrigOrig,1:mergeTime*(1+doubleFreq)-1) + 1;

                            %determine how this "original original" segment
                            %started
                            origSegmentStartEvent = find(seqOfEvents(:,2)==1 & ...
                                seqOfEvents(:,3)==segmentOrigOrig);
                            if ~isempty(origSegmentStartEvent) %if segment started by a birth or a split
                                fromSplit = ~isnan(seqOfEvents(origSegmentStartEvent,4)); %check whether it's from a split
                                fromMerge = 0; %in this case it's not from a merge
                            else
                                origSegmentStartEvent = find(seqOfEvents(:,4)==segmentOrigOrig);
                                fromMerge = 1;
                                fromSplit = 0;
                            end

                        end

                    end

                else %if the original segment has more than 1 molecule ...

                    %calculate the average intensity of the two segments
                    %after splitting
                    segmentAmp1 = nanmean(tracksAmp(segmentSplitting1,:));
                    segmentAmp2 = nanmean(tracksAmp(segmentSplitting2,:));
                    segmentSplitting12 = [segmentSplitting1 segmentSplitting2];
                    segmentAmp12 = [segmentAmp1 segmentAmp2];

                    %identify which segment has lower amplitude and which
                    %has higher amplitude
                    segmentDimmer = find(segmentAmp12==min(segmentAmp12));
                    segmentDimmer = segmentDimmer(1);
                    segmentBrighter = setdiff([1 2],segmentDimmer);

                    %calculate the number of molecules inherited by the
                    %dimmer and brighter segments
                    ampFracDimmer = segmentAmp12(segmentDimmer)/sum(segmentAmp12);
                    numMolDimmer = max(round(ampFracDimmer*numMolecules),1);
                    numMolBrighter = numMolecules - numMolDimmer;

                    %store the number of molecules in the aggregation
                    %matrix
                    aggregStateMat(segmentSplitting12(segmentDimmer),...
                        eventTime*(1+doubleFreq):end) = numMolDimmer + aggregStateMat(...
                        segmentSplitting12(segmentDimmer),eventTime*(1+doubleFreq):end) - ...
                        aggregStateMat(segmentSplitting12(segmentDimmer),...
                        eventTime*(1+doubleFreq):end);
                    aggregStateMat(segmentSplitting12(segmentBrighter),...
                        eventTime*(1+doubleFreq):end) = numMolBrighter + aggregStateMat(...
                        segmentSplitting12(segmentBrighter),eventTime*(1+doubleFreq):end) - ...
                        aggregStateMat(segmentSplitting12(segmentBrighter),...
                        eventTime*(1+doubleFreq):end);

                end %(if numMolecules == 1 ... else ...)

            case 2 %merge

                %find the two merging segments and the segment they merge
                %into
                segmentAfterMerge = seqOfEvents(iEvent,4);
                segmentMerging1 = seqOfEvents(iEvent,3);
                segmentMerging2 = seqOfEvents(iEventPlus1,3);

                %update the aggregation state after merging as the sum of
                %the aggregation states before merging
                aggregStateMat(segmentAfterMerge,eventTime*(1+doubleFreq):end) = ...
                    aggregStateMat(segmentMerging1,eventTime*(1+doubleFreq)-1) + ...
                    aggregStateMat(segmentMerging2,eventTime*(1+doubleFreq)-1) + ...
                    aggregStateMat(segmentAfterMerge,eventTime*(1+doubleFreq):end) - ...
                    aggregStateMat(segmentAfterMerge,eventTime*(1+doubleFreq):end);

        end %(switch eventType)

    end %(for iEvent = msEvents')

    %store aggregation state matrix in compound tracks structure with
    %"alternative format"
    compTracks(iTrack).aggregState = aggregStateMat;

    %store aggregation state matrix in compound tracks structure with
    %"default format" ...

    %get number of segments in default format
    numSegmentsDef = size(compTracksDef(iTrack).tracksFeatIndxCG,1);

    %copy aggregation state matrix
    aggregStateDef = aggregStateMat(1:numSegmentsDef,:);

    %copy out segment correspondence array
    segmentCorrespond = compTracks(iTrack).alt2defSegmentCorrespond;

    %go over additional segments in alternative format and store their
    %aggregation state in the original segment location
    for iSegment = 1 : size(segmentCorrespond,1)
        segmentNew = segmentCorrespond(iSegment,1);
        segmentOld = segmentCorrespond(iSegment,2);
        aggregStateDef(segmentOld,:) = max([aggregStateDef(segmentOld,:);...
            aggregStateMat(segmentNew,:)]);
    end
    compTracksDef(iTrack).aggregState = aggregStateDef(:,1+doubleFreq:(1+doubleFreq):end);

end %(for iTrack = 1 : numTracks)

%store results in output structure
compTracksOut = struct('defaultFormatTracks',compTracksDef,'alternativeFormatTracks',...
    compTracks);

%% ~~~ the end ~~~