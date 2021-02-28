function OutputStruct = PeriTransitionAnalyzer(SpkratesPerPeriodStruct, SpkrateVectorBinWidth, PeriTransitionDomain_Seconds)

SecondsScaleFactor = SpkrateVectorBinWidth;
HzScaleFactor = 1/SpkrateVectorBinWidth;
ContourPlotCeiling = 150; %Hz

nTransitionsToEnabledState = length(SpkratesPerPeriodStruct.ToEnabledStatesIndices)
ToEnabledStateIndices_FirstThird = 1:floor(nTransitionsToEnabledState/3);
ToEnabledStateIndices_MiddleThird = ceil((1/3)*nTransitionsToEnabledState):floor((2/3)*nTransitionsToEnabledState);
ToEnabledStateIndices_LastThird = ceil((2/3)*nTransitionsToEnabledState):nTransitionsToEnabledState;


nTransitionsToDisabledState = length(SpkratesPerPeriodStruct.ToDisabledStatesIndices); 
ToDisabledStateIndices_FirstThird = 1:floor(nTransitionsToDisabledState/3);
ToDisabledStateIndices_MiddleThird = ceil((1/3)*nTransitionsToDisabledState):floor((2/3)*nTransitionsToDisabledState);
ToDisabledStateIndices_LastThird = ceil((2/3)*nTransitionsToDisabledState):nTransitionsToDisabledState;

PeriTransitionDomain_Indices = round(PeriTransitionDomain_Seconds/SpkrateVectorBinWidth)

PeriEventSamplesStruct_OffToOn = DataExtractor(SpkratesPerPeriodStruct.Adjusted_spkrate,...
    SpkratesPerPeriodStruct.ToEnabledStatesIndices,PeriTransitionDomain_Indices);

PeriEventSamplesStruct_OnToOff = DataExtractor(SpkratesPerPeriodStruct.Adjusted_spkrate,...
    SpkratesPerPeriodStruct.ToDisabledStatesIndices,PeriTransitionDomain_Indices);

% Compute StimOFF to StimON transition averages
PeriEventAverage_OffToOn_FirstThird = ...
    RowAveragerIgnoresNaNs(PeriEventSamplesStruct_OffToOn.InputSamples(ToEnabledStateIndices_FirstThird,:));

PeriEventAverage_OffToOn_MiddleThird = ...
    RowAveragerIgnoresNaNs(PeriEventSamplesStruct_OffToOn.InputSamples(ToEnabledStateIndices_MiddleThird,:));

PeriEventAverage_OffToOn_LastThird = ...
    RowAveragerIgnoresNaNs(PeriEventSamplesStruct_OffToOn.InputSamples(ToEnabledStateIndices_LastThird,:));

% Compute StimON to StimOFF transition averages
PeriEventAverage_OnToOff_FirstThird = ...
    RowAveragerIgnoresNaNs(PeriEventSamplesStruct_OnToOff.InputSamples(ToDisabledStateIndices_FirstThird,:));

PeriEventAverage_OnToOff_MiddleThird = ...
    RowAveragerIgnoresNaNs(PeriEventSamplesStruct_OnToOff.InputSamples(ToDisabledStateIndices_MiddleThird,:));

PeriEventAverage_OnToOff_LastThird = ...
    RowAveragerIgnoresNaNs(PeriEventSamplesStruct_OnToOff.InputSamples(ToDisabledStateIndices_LastThird,:));

% Plot StimOff to StimON transition averages
fhandle = figure; hold on;
plot(SecondsScaleFactor*PeriEventSamplesStruct_OffToOn.PeriEventIndices, HzScaleFactor*PeriEventAverage_OffToOn_FirstThird, 'b','LineWidth', 2);
plot(SecondsScaleFactor*PeriEventSamplesStruct_OffToOn.PeriEventIndices, HzScaleFactor*PeriEventAverage_OffToOn_MiddleThird, 'k','LineWidth', 2);
plot(SecondsScaleFactor*PeriEventSamplesStruct_OffToOn.PeriEventIndices, HzScaleFactor*PeriEventAverage_OffToOn_LastThird, 'r','LineWidth', 2);
AxesHandle = gca;
YLimits = get(AxesHandle, 'YLim')
plot([0,0], YLimits, 'k--')
set(AxesHandle,'FontSize', 20, 'FontWeight', 'bold')
xlabel(AxesHandle,'time relative to transition (sec)','FontSize', 24,'FontWeight','Bold')
ylabel(AxesHandle,'activity (events/sec)','FontSize', 24,'FontWeight','Bold')
set(fhandle, 'PaperOrientation', 'landscape')
set(fhandle, 'PaperUnits', 'inches')
set(fhandle, 'PaperPositionMode', 'manual')
set(fhandle, 'PaperPosition', [0.25, 0.25, 10.5, 8]);

% Plot StimON to StimOFF transition average
fhandle = figure; hold on;
plot(SecondsScaleFactor*PeriEventSamplesStruct_OnToOff.PeriEventIndices, HzScaleFactor*PeriEventAverage_OnToOff_FirstThird, 'b','LineWidth', 2);
plot(SecondsScaleFactor*PeriEventSamplesStruct_OnToOff.PeriEventIndices, HzScaleFactor*PeriEventAverage_OnToOff_MiddleThird, 'k','LineWidth', 2);
plot(SecondsScaleFactor*PeriEventSamplesStruct_OnToOff.PeriEventIndices, HzScaleFactor*PeriEventAverage_OnToOff_LastThird, 'r','LineWidth', 2);
AxesHandle = gca;
YLimits = get(AxesHandle, 'YLim')
plot([0,0], YLimits, 'k--')
set(AxesHandle,'FontSize', 20, 'FontWeight', 'bold')
xlabel(AxesHandle,'time relative to transition (sec)','FontSize', 24,'FontWeight','Bold')
ylabel(AxesHandle,'activity (events/sec)','FontSize', 24,'FontWeight','Bold')
set(fhandle, 'PaperOrientation', 'landscape')
set(fhandle, 'PaperUnits', 'inches')
set(fhandle, 'PaperPositionMode', 'manual')
set(fhandle, 'PaperPosition', [0.25, 0.25, 10.5, 8]);


                            %%%%%% PREPARE AND PLOT SPKRATE COLORMAPS %%%%%%

% Place upper limit on plotted contraction data
TruncatedPeriEventSampleSpace_OnToOff = HzScaleFactor*PeriEventSamplesStruct_OnToOff.InputSamples;
TruncatedPeriEventSampleSpace_OnToOff(TruncatedPeriEventSampleSpace_OnToOff >= ...
    ContourPlotCeiling*ones(size(TruncatedPeriEventSampleSpace_OnToOff))) = ContourPlotCeiling;

TruncatedPeriEventSampleSpace_OffToOn = HzScaleFactor*PeriEventSamplesStruct_OffToOn.InputSamples;
TruncatedPeriEventSampleSpace_OffToOn(TruncatedPeriEventSampleSpace_OffToOn >= ...
    ContourPlotCeiling*ones(size(TruncatedPeriEventSampleSpace_OffToOn))) = ContourPlotCeiling;

% Generate underlying meshgrids for contour plotting
[PeriSampleAxisArray_OffToOn, TransitionCountAxisArray_OffToOn] = meshgrid(SecondsScaleFactor*PeriEventSamplesStruct_OffToOn.PeriEventIndices, ...
    1:length(PeriEventSamplesStruct_OffToOn.InputSamples(:,1)));

[PeriSampleAxisArray_OnToOff, TransitionCountAxisArray_OnToOff] = meshgrid(SecondsScaleFactor*PeriEventSamplesStruct_OnToOff.PeriEventIndices, ...
    1:length(PeriEventSamplesStruct_OnToOff.InputSamples(:,1)));

% Generate contour plot of peri-OffToOn-transition spkrate activity
% fhandle = figure; caxis([0, ContourPlotCeiling]);
% [junk, ContourHandle1] = contourf(PeriSampleAxisArray_OffToOn,TransitionCountAxisArray_OffToOn,TruncatedPeriEventSampleSpace_OffToOn);
% set(ContourHandle1,'LineColor','none');
% AxesHandle = gca;
% YLimits = get(AxesHandle, 'YLim')
% plot([0,0], YLimits, 'k--')
% set(AxesHandle,'FontSize', 20, 'FontWeight', 'bold')
% xlabel(AxesHandle,'time relative to transition (sec)','FontSize', 24,'FontWeight','Bold')
% ylabel(AxesHandle,'activity (events/sec)','FontSize', 24,'FontWeight','Bold')
% set(fhandle, 'PaperOrientation', 'landscape')
% set(fhandle, 'PaperUnits', 'inches')
% set(fhandle, 'PaperPositionMode', 'manual')
% set(fhanlde, 'PaperPosition', [0.25, 0.25, 10.5, 8]);
% 
% % Generate contour plot of peri-OnToOff-transition spkrate activity
% fhandle = figure; caxis([0, ContourPlotCeiling]);
% [junk, ContourHandle2] = contourf(PeriSampleAxisArray_OnToOff,TransitionCountAxisArray_OnToOff,TruncatedPeriEventSampleSpace_OnToOff);
% set(ContourHandle2,'LineColor','none');
% AxesHandle = gca;
% YLimits = get(AxesHandle, 'YLim')
% plot([0,0], YLimits, 'k--')
% set(AxesHandle,'FontSize', 20, 'FontWeight', 'bold')
% xlabel(AxesHandle,'time relative to transition (sec)','FontSize', 24,'FontWeight','Bold')
% ylabel(AxesHandle,'activity (events/sec)','FontSize', 24,'FontWeight','Bold')
% set(fhandle, 'PaperOrientation', 'landscape')
% set(fhandle, 'PaperUnits', 'inches')
% set(fhandle, 'PaperPositionMode', 'manual')
% set(fhanlde, 'PaperPosition', [0.25, 0.25, 10.5, 8]);

OutputStruct.PeriEventAverage_OffToOn_FirstThird = PeriEventAverage_OffToOn_FirstThird;
OutputStruct.PeriEventAverage_OffToOn_MiddleThird = PeriEventAverage_OffToOn_MiddleThird;
OutputStruct.PeriEventAverage_OffToOn_LastThird = PeriEventAverage_OffToOn_LastThird;

OutputStruct.PeriEventAverage_OnToOff_FirstThird = PeriEventAverage_OnToOff_FirstThird;
OutputStruct.PeriEventAverage_OnToOff_MiddleThird = PeriEventAverage_OnToOff_MiddleThird;
OutputStruct.PeriEventAverage_OnToOff_LastThird = PeriEventAverage_OnToOff_LastThird;

OutputStruct.TruncatedPeriEventSampleSpace_OffToOn = TruncatedPeriEventSampleSpace_OffToOn;
OutputStruct.TruncatedPeriEventSampleSpace_OnToOff = TruncatedPeriEventSampleSpace_OnToOff;

end