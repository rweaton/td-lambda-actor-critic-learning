function Mock_spkrate = ProcessIntoSpkRateVec(Record, BinWidth_sec)

%     SamplingRate = 200;
%     BinWidth_sec = 0.1;

    SamplesPerBin = Record(1).PrevEnvStruct.SamplingFrequency*BinWidth_sec;

    CountVec = ContractionRateBinner(Record(1).PrevEnvStruct.ActionsTable, ...
        [Record.ActionIndices], SamplesPerBin);

    TimeInOffsetVec = TimeInOffsetMocker(...
        Record(1).PrevEnvStruct.nStepsPerEpisode/SamplesPerBin, ...
        Record(1).PrevEnvStruct.TransitionStep/SamplesPerBin, length(Record));

    Mock_spkrate = TimeInOffsetVec+CountVec;
    
end