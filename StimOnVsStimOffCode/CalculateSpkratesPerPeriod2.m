function OutputStruct = CalculateSpkratesPerPeriod2(spkrate, SamplingFreq)

% This function comprehensively processes the time-in/time-out rate data by
% first filtering out large spike artifacts, removing the imposed offsets
% signifying "time-in" periods in the filtered spkrate vector and recording
% the transitions between time-in and time-out states.  It then calculates
% the mean spike rate during each time-in and time-out period and plots
% them accordingly.

SampleInc = 1/SamplingFreq;

TimeVec_hours = (1/3600)*(0:SampleInc:SampleInc*(length(spkrate)-1));

Filtered_spkrate = DifferentialFilter(spkrate, 70);

EnabledAndDisabledPeriods = TimeInFilterGenerator2(Filtered_spkrate);

Adjusted_spkrate = Filtered_spkrate;
Adjusted_spkrate(~isnan(EnabledAndDisabledPeriods.EnabledFilter)) = ...
    Adjusted_spkrate(~isnan(EnabledAndDisabledPeriods.EnabledFilter)) - ...
    50*ones(size(Adjusted_spkrate(~isnan(EnabledAndDisabledPeriods.EnabledFilter))));

Adjusted_spkrate(Adjusted_spkrate < 0) = NaN;

% Scale Adjusted_spkrate to hertz range  THIS MAY BE
% STATISTICALLY/MATHEMATICALLY INVALID
%Adjusted_spkrate = SamplingFreq*Adjusted_spkrate;

figure; plot(Adjusted_spkrate);

LevelAnswer = inputdlg('Input artifact threshold crossing level','Input threshold crossing to eliminate high-rate artifacts');
UnitThresholdLevel = eval(LevelAnswer{1});
Adjusted_spkrate = LargeValueFilter(Adjusted_spkrate, UnitThresholdLevel);

% nEnabledPeriods = length(EnabledAndDisabledPeriods.FromEnabledStateIndices);
% nDisabledPeriods = length(EnabledAndDisabledPeriods.FromDisabledStateIndices);

nEnabledPeriods = length(EnabledAndDisabledPeriods.FromEnabledStateIndices)
nDisabledPeriods = length(EnabledAndDisabledPeriods.FromDisabledStateIndices)

EnabledActivityMeans = NaN*ones([1, nEnabledPeriods]);
EnabledActivityStdErrs = NaN*ones([1, nEnabledPeriods]);

for i = 1:nEnabledPeriods
    
    EnabledActivityPeriodIndices = ...
        EnabledAndDisabledPeriods.ToEnabledStateIndices(i):...
        EnabledAndDisabledPeriods.FromEnabledStateIndices(i); 
    EnabledActivity = Adjusted_spkrate(EnabledActivityPeriodIndices);
    EnabledActivity = EnabledActivity(~isnan(EnabledActivity));
    nSamples = length(EnabledActivity);
    
    
    
    if nSamples ~= 0
        EnabledActivityMeans(i) = mean(EnabledActivity);
        EnabledActivityStdErrs(i) = std(EnabledActivity)/sqrt(nSamples);
    end
    
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
    
    
    if nSamples ~= 0
        DisabledActivityMeans(i) = mean(DisabledActivity);
        DisabledActivityStdErrs(i) = std(DisabledActivity)/sqrt(nSamples);
    end
    DisabledActivity = [];
    
end;

[SortedIndices, PermutationVector] = sort(...
    [EnabledAndDisabledPeriods.FromEnabledStateIndices(1:nEnabledPeriods); ...
    EnabledAndDisabledPeriods.FromDisabledStateIndices(1:nDisabledPeriods)]);

CompositeMeans = [EnabledActivityMeans, DisabledActivityMeans];
CompositeStdErrs = [EnabledActivityStdErrs, DisabledActivityStdErrs];

SortedMeans = CompositeMeans(PermutationVector);
SortedStdErrs = CompositeStdErrs(PermutationVector);

figure;
subplot(2,1,1); hold on; plot(TimeVec_hours(SortedIndices), SamplingFreq*SortedMeans, 'b--');
errorbar(TimeVec_hours(EnabledAndDisabledPeriods.FromEnabledStateIndices(1:nEnabledPeriods)), SamplingFreq*EnabledActivityMeans, EnabledActivityStdErrs, 'r.');
errorbar(TimeVec_hours(EnabledAndDisabledPeriods.FromDisabledStateIndices(1:nDisabledPeriods)), SamplingFreq*DisabledActivityMeans, DisabledActivityStdErrs, 'k.');
axis([0 max(TimeVec_hours) 0 max(SamplingFreq*SortedMeans)]);
ylabel('Mean activity rate (events/sec)')


% Incorporate ReBin function to plot less compressed rates
[EnabledBinLocations, EnabledRates] = ReBin2(EnabledAndDisabledPeriods.EnabledFilter.*Adjusted_spkrate(1:length(EnabledAndDisabledPeriods.EnabledFilter)),SamplingFreq,50);
[DisabledBinLocations, DisabledRates] = ReBin2(EnabledAndDisabledPeriods.DisabledFilter.*Adjusted_spkrate(1:length(EnabledAndDisabledPeriods.DisabledFilter)),SamplingFreq,50);

subplot(2,1,2); hold on;
%bar(TimeVec_hours(floor(EnabledBinLocations)), EnabledRates, 'r', 'EdgeColor', 'none','BarWidth',1);
%bar(TimeVec_hours(floor(DisabledBinLocations)), DisabledRates, 'k', 'EdgeColor', 'none','BarWidth',1);
bar(TimeVec_hours, SamplingFreq*EnabledAndDisabledPeriods.EnabledFilter.*Adjusted_spkrate(1:length(EnabledAndDisabledPeriods.EnabledFilter)), 'r','EdgeColor','none','BarWidth',1)
bar(TimeVec_hours, SamplingFreq*EnabledAndDisabledPeriods.DisabledFilter.*Adjusted_spkrate(1:length(EnabledAndDisabledPeriods.DisabledFilter)), 'k', 'EdgeColor','none','BarWidth',1)
axis([0 max(TimeVec_hours) 0 max([SamplingFreq*EnabledRates; SamplingFreq*DisabledRates])]);
xlabel('time (hours)');
ylabel('activity rate (events/sec)');

OutputStruct.TimeVec_hours = TimeVec_hours;
OutputStruct.Filtered_spkrate = Filtered_spkrate;
OutputStruct.Adjusted_spkrate = Adjusted_spkrate;
OutputStruct.EnabledFilter = EnabledAndDisabledPeriods.EnabledFilter;
OutputStruct.DisabledFilter = EnabledAndDisabledPeriods.DisabledFilter;
OutputStruct.EnabledActivityMeans = EnabledActivityMeans;
OutputStruct.EnabledActivityStdErrs = EnabledActivityStdErrs;
OutputStruct.DisabledActivityMeans = DisabledActivityMeans;
OutputStruct.DisabledActivityStdErrs = DisabledActivityStdErrs;
OutputStruct.SortedMeans = SortedMeans;
OutputStruct.SortedStdErrs = SortedStdErrs;
OutputStruct.SortedIndices = SortedIndices;
OutputStruct.ToEnabledStatesIndices = EnabledAndDisabledPeriods.ToEnabledStateIndices;
OutputStruct.FromEnabledStatesIndices = EnabledAndDisabledPeriods.FromEnabledStateIndices;
OutputStruct.ToDisabledStatesIndices = EnabledAndDisabledPeriods.ToDisabledStateIndices;
OutputStruct.FromDisabledStatesIndices = EnabledAndDisabledPeriods.FromDisabledStateIndices;
