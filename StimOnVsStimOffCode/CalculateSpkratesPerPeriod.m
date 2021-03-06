function OutputStruct = CalculateSpkratesPerPeriod(spkrate, SamplingFreq)

% This function comprehensively processes the time-in/time-out rate data by
% first filtering out large spike artifacts, removing the imposed offsets
% signifying "time-in" periods in the filtered spkrate vector and recording
% the transitions between time-in and time-out states.  It then calculates
% the mean spike rate during each time-in and time-out period and plots
% them accordingly.

SampleInc = 1/SamplingFreq;

TimeVec_hours = (1/3600)*(0:SampleInc:SampleInc*(length(spkrate)-1));

Filtered_spkrate = DifferentialFilter(spkrate, 60);

EnabledAndDisabledPeriods = TimeInFilterGenerator(Filtered_spkrate);

Adjusted_spkrate = Filtered_spkrate;
Adjusted_spkrate(~isnan(EnabledAndDisabledPeriods.EnabledFilter)) = ...
    Adjusted_spkrate(~isnan(EnabledAndDisabledPeriods.EnabledFilter)) - ...
    50*ones(size(Adjusted_spkrate(~isnan(EnabledAndDisabledPeriods.EnabledFilter))));

nEnabledPeriods = length(EnabledAndDisabledPeriods.FromEnabledStateIndices);
nDisabledPeriods = length(EnabledAndDisabledPeriods.FromDisabledStateIndices);

EnabledActivityMeans = NaN*ones([1, nEnabledPeriods]);
EnabledActivityStdErrs = NaN*ones([1, nEnabledPeriods]);
    
for i = 1:nEnabledPeriods
    
    EnabledActivityPeriodIndices = ...
        EnabledAndDisabledPeriods.ToEnabledStateIndices(i):...
        EnabledAndDisabledPeriods.FromEnabledStateIndices(i); 
    EnabledActivity = Adjusted_spkrate(EnabledActivityPeriodIndices);
    EnabledActivity = EnabledActivity(~isnan(EnabledActivity));
    nSamples = length(EnabledActivity);
    
    EnabledActivityMeans(i) = mean(EnabledActivity);
    EnabledActivityStdErrs(i) = std(EnabledActivity)/sqrt(nSamples);
    
    EnabledActivity = [];
    
end;

DisabledActivityMeans = NaN*ones([1, nDisabledPeriods]);
DisabledActivityStdErrs = NaN*ones([1, nDisabledPeriods]);

for i = 1:nDisabledPeriods
    
    DisabledActivityPeriodIndices = ...
        EnabledAndDisabledPeriods.ToDisabledStateIndices(i):...
        EnabledAndDisabledPeriods.FromDisabledStateIndices(i);   
    DisabledActivity = Adjusted_spkrate(DisabledActivityPeriodIndices);
    DisabledActivity = DisabledActivity(~isnan(DisabledActivity));
    nSamples = length(DisabledActivity);
    
    DisabledActivityMeans(i) = mean(DisabledActivity);
    DisabledActivityStdErrs(i) = std(DisabledActivity)/sqrt(nSamples);
    
    DisabledActivity = [];
    
end;

[SortedIndices, PermutationVector] = sort(...
    [EnabledAndDisabledPeriods.FromEnabledStateIndices; ...
    EnabledAndDisabledPeriods.FromDisabledStateIndices]);

CompositeMeans = [EnabledActivityMeans, DisabledActivityMeans];
CompositeStdErrs = [EnabledActivityStdErrs, DisabledActivityStdErrs];

SortedMeans = CompositeMeans(PermutationVector);
SortedStdErrs = CompositeStdErrs(PermutationVector);

%figure;
subplot(2,1,2); hold on; plot(TimeVec_hours(SortedIndices), SortedMeans, 'b--');
errorbar(TimeVec_hours(EnabledAndDisabledPeriods.FromEnabledStateIndices), EnabledActivityMeans, EnabledActivityStdErrs, 'r.');
errorbar(TimeVec_hours(EnabledAndDisabledPeriods.FromDisabledStateIndices), DisabledActivityMeans, DisabledActivityStdErrs, 'k.');
axis([0 22 0 1]);
ylabel('Mean EMG rate (events/sec)')


% subplot(2,1,2); hold on;
% plot(TimeVec_hours, EnabledAndDisabledPeriods.EnabledFilter.*Adjusted_spkrate, 'r')
% plot(TimeVec_hours, EnabledAndDisabledPeriods.DisabledFilter.*Adjusted_spkrate, 'k')
% axis([0 22 0 20]);
% xlabel('time (hours)');
% ylabel('EMG rate (events/sec)');

OutputStruct.TimeVec_hours = TimeVec_hours;
OutputStruct.Filtered_spkrate = Filtered_spkrate;
OutputStruct.Adjusted_spkrate = Adjusted_spkrate;
OutputStruct.EnabledActivityMeans = EnabledActivityMeans;
OutputStruct.EnabledActivityStdErrs = EnabledActivityStdErrs;
OutputStruct.DisabledActivityMeans = DisabledActivityMeans;
OutputStruct.DisabledActivityStdErrs = DisabledActivityStdErrs;
OutputStruct.SortedMeans = SortedMeans;
OutputStruct.SortedStdErrs = SortedStdErrs;