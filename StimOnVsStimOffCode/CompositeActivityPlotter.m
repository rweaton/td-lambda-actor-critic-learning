function CompositeActivityPlotter(SpkratesPerPeriodOutputStruct, StatsStruct)
    
    spkrateBinSize = 0.1; % seconds/bin
    HzScaleFactor = 1/spkrateBinSize;

    pValueFloor = 1e-3;
    pValueCeiling = 5e-2;
    
    TimeVec_hours = SpkratesPerPeriodOutputStruct.TimeVec_hours;
    Adjusted_spkrate = SpkratesPerPeriodOutputStruct.Adjusted_spkrate;
    EnabledFilter = SpkratesPerPeriodOutputStruct.EnabledFilter;
    DisabledFilter = SpkratesPerPeriodOutputStruct.DisabledFilter;
    EnabledActivityMeans = SpkratesPerPeriodOutputStruct.EnabledActivityMeans;
    EnabledActivityStdErrs = SpkratesPerPeriodOutputStruct.EnabledActivityStdErrs;
    DisabledActivityMeans = SpkratesPerPeriodOutputStruct.DisabledActivityMeans;
    DisabledActivityStdErrs = SpkratesPerPeriodOutputStruct.DisabledActivityStdErrs;
    SortedMeans = SpkratesPerPeriodOutputStruct.SortedMeans;
    SortedStdErrs = SpkratesPerPeriodOutputStruct.SortedStdErrs;
    SortedIndices = SpkratesPerPeriodOutputStruct.SortedIndices;
    ToEnabledStateIndices = SpkratesPerPeriodOutputStruct.ToEnabledStatesIndices;
    FromEnabledStateIndices = SpkratesPerPeriodOutputStruct.FromEnabledStatesIndices;
    ToDisabledStateIndices = SpkratesPerPeriodOutputStruct.ToDisabledStatesIndices;
    FromDisabledStateIndices = SpkratesPerPeriodOutputStruct.FromDisabledStatesIndices;
    
    nEnabledPeriods = length(FromEnabledStateIndices);
    nDisabledPeriods = length(FromDisabledStateIndices);

    XVec = StatsStruct.SlidingWindowCenters;
    YVec = max(HzScaleFactor*SortedMeans)*ones(size(XVec));
    pVec = StatsStruct.CorrespondingPValues;
    EnabledGreater = StatsStruct.EnabledGreater;
    
    BarLocations = TimeVec_hours(SortedIndices(XVec));

    nEntries = length(pVec);
    ColorVec = NaN*ones(size(pVec));

    figure; hold on; subplot(2,1,1);
    axis([0 max(TimeVec_hours) 0 max(HzScaleFactor*SortedMeans)]);
    ylabel('Mean activity rate (events/sec)')

    for i = 1:nEntries

            if (pVec(i) > pValueCeiling)

                ColorVec = [1.0 1.0 1.0];

            end

            if (pVec(i) <= pValueFloor)&(EnabledGreater(i) == 0)

                ColorVec = [0.5 0.5 0.5];

            end

            if (pVec(i) < pValueCeiling)&(pVec(i) > pValueFloor)&(EnabledGreater(i) == 0)

                ColorVec = [0.7 0.7 0.7];

            end
            
            if (pVec(i) <= pValueFloor)&(EnabledGreater(i) == 1)
               
                ColorVec = [0.8 0.0 0.0];
                
            end
            
            if (pVec(i) < pValueCeiling)&(pVec(i) > pValueFloor)&(EnabledGreater(i) == 1)
                
                ColorVec = [0.5 0.0 0.0];
                
            end
            
            
            

        subplot(2,1,1); hold on; bar(BarLocations(i), YVec(i), 'FaceColor', ...
            eval('ColorVec'), 'EdgeColor', 'none', 'BarWidth', 1);

    end
    
    
    
    hold on; plot(TimeVec_hours(SortedIndices), HzScaleFactor*SortedMeans, 'b--');
    errorbar(TimeVec_hours(FromEnabledStateIndices(1:nEnabledPeriods)), ...
        HzScaleFactor*EnabledActivityMeans, HzScaleFactor*EnabledActivityStdErrs, 'r.');
    errorbar(TimeVec_hours(FromDisabledStateIndices(1:nDisabledPeriods)), ...
        HzScaleFactor*DisabledActivityMeans, HzScaleFactor*DisabledActivityStdErrs, 'k.');


    % Incorporate ReBin function to plot less compressed rates
    [EnabledBinLocations, EnabledRates] = ReBin(EnabledFilter.*Adjusted_spkrate(1:length(EnabledFilter)),100);
    [DisabledBinLocations, DisabledRates] = ReBin(DisabledFilter.*Adjusted_spkrate(1:length(DisabledFilter)),100);

    subplot(2,1,2); hold on;
    bar(TimeVec_hours(floor(EnabledBinLocations)), HzScaleFactor*EnabledRates, 'r', 'EdgeColor', 'none');
    bar(TimeVec_hours(floor(DisabledBinLocations)), HzScaleFactor*DisabledRates, 'k', 'EdgeColor', 'none');
    axis([0 max(TimeVec_hours) 0 max([HzScaleFactor*EnabledRates; HzScaleFactor*DisabledRates])]);
    xlabel('time (hours)');
    ylabel('activity rate (events/sec)');
    
end