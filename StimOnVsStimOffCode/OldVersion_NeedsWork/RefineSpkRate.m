function OutputStruct = RefineSpkRate(spkrate)

BinSize_sec = 0.1;
RecordingTimeLimit_hours = 20;

Inc_hours = BinSize_sec/3600;
TimeVec_hours = 0:Inc_hours:Inc_hours*(length(spkrate)-1);

EnabledIndices = find(spkrate >= 50);
DisabledIndices = find(spkrate < 50);

% Adjust spkrate for 50 unit offset during enabled periods
adjusted_spkrate = spkrate;
adjusted_spkrate(EnabledIndices) = spkrate(EnabledIndices) - 50;

% Calculate time limit index for truncation
RecordingTimeLimitIndex = find(TimeVec_hours == RecordingTimeLimit_hours);
IndicesToTruncate = (RecordingTimeLimitIndex+1):(length(TimeVec_hours));

% Truncate the adjusted spike rate vector
Truncated_spkrate = adjusted_spkrate(1:RecordingTimeLimitIndex);

% Truncate the corresponding time vector
Truncated_TimeVec_hours = TimeVec_hours(1:RecordingTimeLimitIndex)';

% Truncate the lists of enabled and disabled indices
Truncated_EnabledIndices = EnabledIndices;
Truncated_EnabledIndices(ismember(EnabledIndices, IndicesToTruncate)) = [];

Truncated_DisabledIndices = DisabledIndices;
Truncated_DisabledIndices(ismember(DisabledIndices, IndicesToTruncate)) = [];

% Remove artifacts from signals
LowArtifactIndices = find(Truncated_spkrate < 0);
HighArtifactIndices = find(Truncated_spkrate > 20);

AllIndices = 1:length(Truncated_spkrate);
IndicesToDisclude = [LowArtifactIndices; HighArtifactIndices];
IndicesToInclude = AllIndices;
IndicesToInclude(IndicesToDisclude) = [];

Refined_WholeSessionActivity = Truncated_spkrate(IndicesToInclude);
Refined_TimeVec_hours = Truncated_TimeVec_hours(IndicesToInclude);

Refined_EnabledIndices = Truncated_EnabledIndices;
Refined_EnabledIndices(ismember(Truncated_EnabledIndices, IndicesToDisclude)) = [];


Refined_DisabledIndices = Truncated_DisabledIndices;
Refined_DisabledIndices(ismember(Truncated_DisabledIndices, IndicesToDisclude)) = [];



% *********** Assemble OutputStruct **************** %

OutputStruct.Truncated_spkrate = Truncated_spkrate;
OutputStruct.Truncated_TimeVec_hours = Truncated_TimeVec_hours;

OutputStruct.DiscludedIndices = IndicesToDisclude;

OutputStruct.Refined_WholeSessionActivity = Refined_WholeSessionActivity;
OutputStruct.Refined_TimeVec_hours = Refined_TimeVec_hours;

OutputStruct.Refined_EnabledIndices = Refined_EnabledIndices;
OutputStruct.Refined_DisabledIndices = Refined_DisabledIndices;

OutputStruct.WholeSessionMeanSpkRate = mean(Refined_WholeSessionActivity);

OutputStruct.WholeSessionStdErrSpkRate = ...
    std(Refined_WholeSessionActivity)/sqrt(length(Refined_WholeSessionActivity));

OutputStruct.EnabledMeanSpkRate = mean(Truncated_spkrate(Refined_EnabledIndices));

OutputStruct.EnabledStdErrSpkRate = ...
    std(Truncated_spkrate(Refined_EnabledIndices))/sqrt(length(Truncated_spkrate(Refined_EnabledIndices)));

OutputStruct.DisabledMeanSpkRate = mean(Truncated_spkrate(Refined_DisabledIndices));

OutputStruct.DisabledStdErrSpkRate = ...
    std(Truncated_spkrate(Truncated_DisabledIndices))/sqrt(length(Truncated_spkrate(Refined_DisabledIndices)));


end

