function OutputStruct = ComputeEnabledAndDisabledPeriodMeansFunc(spkrate, TimeVec, EnabledIndices, DisabledIndices)


% Compute mean spike rates for Enabled and Disabled periods


IPI_hours = 3/60;

EnabledTransitionIndices = find(diff(TimeVec(EnabledIndices)) >= IPI_hours);
EnabledTransitionIndices = EnabledTransitionIndices + ones(size(EnabledTransitionIndices));
EnabledTransitionIndices = [1; EnabledTransitionIndices];

DisabledTransitionIndices = find(diff([0; TimeVec(DisabledIndices)]) >= IPI_hours);
DisabledTransitionIndices = DisabledTransitionIndices + ones(size(DisabledTransitionIndices));

nEnabledTransitions = length(EnabledTransitionIndices);
nDisabledTransitions = length(DisabledTransitionIndices);

%nEnabledTransitions
%EnabledTransitionIndices(nEnabledTransitions)
TimeVec(EnabledIndices(EnabledTransitionIndices(nEnabledTransitions)))
%TimeVec(DisabledTransitionIndices(nDisabledTransitions))

%TimeVec(length(TimeVec))

%TimeVec(EnabledIndices(length(EnabledIndices)))

EnabledMeans(floor(nEnabledTransitions/2)) = 0;
EnabledStdErrs(floor(nEnabledTransitions/2)) = 0;
DisabledMeans(floor(nDisabledTransitions/2)) = 0;
DisabledStdErrs(floor(nDisabledTransitions/2)) = 0;

Count = 0;

for i = 2:2:nEnabledTransitions
    
    Count = Count + 1;
    
    Activity = spkrate((EnabledIndices(EnabledTransitionIndices(i-1)+1)):...
        EnabledIndices(EnabledTransitionIndices(i)));
    
    nEntries = length(Activity);
    
    EnabledMeans(Count) = mean(Activity);
    
    if EnabledMeans(Count) < 0
        FaultyActivity = Activity;
        FaultyIndices = EnabledIndices(EnabledTransitionIndices(i-1)+1):...
        EnabledIndices(EnabledTransitionIndices(i));
    end
    
    EnabledStdErrs(Count) = std(Activity)/sqrt(nEntries);
    
end

Activity = [];
Count = 0;

for i = 2:2:nDisabledTransitions
    
    Count = Count + 1;
    
    Activity = spkrate(DisabledIndices(DisabledTransitionIndices(i-1)+1):...
        DisabledIndices(DisabledTransitionIndices(i)));
    
    nEntries = length(Activity);
    
    DisabledMeans(Count) = mean(Activity);
    
    if DisabledMeans(Count) < 0
        FaultyActivity = Activity;
        FaultyIndices = DisabledIndices(DisabledTransitionIndices(i-1)+1):...
        DisabledIndices(DisabledTransitionIndices(i));
    end
    
    DisabledStdErrs(Count) = std(Activity)/sqrt(nEntries);
    
end

EnabledPeriodTimes = TimeVec(EnabledIndices(EnabledTransitionIndices(2:2:nEnabledTransitions)))';
DisabledPeriodTimes = TimeVec(DisabledIndices(DisabledTransitionIndices(2:2:nDisabledTransitions)))';

[SortedTimes, PermutationVector] = sort([EnabledPeriodTimes, DisabledPeriodTimes]);

ConcatonatedMeans = [EnabledMeans, DisabledMeans];
SortedMeans = ConcatonatedMeans(PermutationVector);

figure; hold on, 
plot(SortedTimes, 10*SortedMeans, 'b--')
errorbar(EnabledPeriodTimes,10*EnabledMeans,10*EnabledStdErrs,'r.')
errorbar(DisabledPeriodTimes,10*DisabledMeans,10*DisabledStdErrs,'k.')

xlabel('time (hours)');
ylabel('mean acceptance rate (acceptances/sec)');
title('Mean Acceptance Rates during Stimulation and Non-Stimulation Periods');

OutputStruct.EnabledMeans = EnabledMeans;
OutputStruct.EnabledStdErrs = EnabledStdErrs;
OutputStruct.DisabledMeans = DisabledMeans;
OutputStruct.DisabledStdErrs = DisabledStdErrs;
OutputStruct.EnabledPeriodTimes = EnabledPeriodTimes;
OutputStruct.DisabledPeriodTimes = DisabledPeriodTimes;
OutputStruct.OrderedMeans = SortedMeans;
OutputStruct.OrderedTimes = SortedTimes;
OutputStruct.TransitionTimesToEnabledStates = TimeVec(EnabledIndices(EnabledTransitionIndices));
OutputStruct.TransitionTimesToDisabledStates = TimeVec(DisabledIndices(DisabledTransitionIndices));

%OutputStruct.FaultyActivity = FaultyActivity;
%OutputStruct.FaultyIndices = FaultyIndices;
end