function OutputStruct = ComputeEnabledAndDisabledMeans(spkrate, TimeVec, EnabledIndices, DisabledIndices)


% Compute mean spike rates for Enabled and Disabled periods


IPI_hours = 4.5/60;

EnabledTransitionIndices = find(diff(TimeVec(EnabledIndices) >= IPI_hours);
EnabledTransitionIndices = [1; EnabledTransitionIndices];

DisabledTransitionIndices = find(diff(TimeVec(DisabledIndices)) >= IPI_hours);

nEnabledTransitions = length(EnabledTransitionIndices);
nDisabledTransitions = length(DisabledTransitionIndices);

EnabledMeans(floor(nEnabledTransitions/2)) = 0;
EnabledStdErrs(floor(nEnabledTransitions/2)) = 0;
DisabledMeans(floor(nDisabledTransitions/2)) = 0;
DisabledStdErrs(floor(nDisabledTransitions/2)) = 0;

Count = 0;

for i = 2:2:nEnabledTransitions
    
    Count = Count + 1;
    
    Activity = spkrate((EnabledTransitionIndices(i-1)+1):EnabledTransitionIndices(i));
    
    nEntries = length(Activity);
    
    EnabledMeans(Count) = mean(Activity);
    
    EnabledStdErrs(Count) = std(Activity)/sqrt(nEntries);
    
end

Count = 0;

for i = 2:2:nDisabledTransitions
    
    Count = Count + 1;
    
    Activity = spkrate((DisabledTransitionIndices(i-1)+1):DisabledTransitionIndices(i));
    
    nEntries = length(Activity);
    
    DisabledMeans(Count) = mean(Activity);
    
    DisabledStdErrs(Count) = std(Activity)/sqrt(nEntries);
    
end

EnabledPeriodSequence = (1:2:2*nEnabledTransitions);
DisabledPeriodSequence = (2:2:2*nDisabledTransitions);

figure; hold on, errorbar(EnabledPeriodSequence,10*EnabledMeans,10*EnabledStdErrs,'r.')
errorbar(DisabledPeriodSequence,10*DisabledMeans,10*DisabledStdErrs,'k.')

OutputStruct.EnabledMeans = EnabledMeans;
OutputStruct.EnabledStdErrs = EnabledStdErrs;
OutputStruct.DisabledMeans = DisabledMeans;
OutputStruct.DisabledStdErrs = DisabledStdErrs;
OutputStruct.EnabledPeriodSequence = EnabledPeriodSequence;
OutputStruct.DisabledPeriodSequence = DisabledPeriodSequence;