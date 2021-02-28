% Script to process and examine activity rates output from TD learning

SamplingRate = 200;
BinWidth_sec = 0.1;

SamplesPerBin = SamplingRate*BinWidth_sec;

CountVec = ContractionRateBinner(Record(1).PrevEnvStruct.ActionsTable, ...
    [Record.ActionIndices], SamplesPerBin);

TimeInOffsetVec = TimeInOffsetMocker(Record(1).PrevEnvStruct.nStepsPerEpisode/SamplesPerBin, ...
    Record(1).PrevEnvStruct.TransitionStep/SamplesPerBin, length(Record));

Mock_spkrate = TimeInOffsetVec+CountVec;

cd ..
cd('StimOnVsStimOffCode')

SpkRatesPerPeriodStruct = CalculateSpkratesPerPeriod2(Mock_spkrate', 10);

cd ..
cd('Project')