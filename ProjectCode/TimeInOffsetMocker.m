function TimeInOffsetVec = TimeInOffsetMocker(nStepsPerEpisode, ...
    TransitionStepIndex, nEpisodes)

    Offset = 50;
    Indices = 1:nStepsPerEpisode;
    
    OffsetVec = zeros([1,nStepsPerEpisode]);
    OffsetVec(Indices < TransitionStepIndex) = Offset;
    
    TimeInOffsetVec = repmat(OffsetVec, 1, nEpisodes);
    
end