function GenerateSeriesOfPlots(fhandle)

figure(fhandle); subplot(2,1,1); TopPlotHandle = gca;
figure(fhandle); subplot(2,1,2); BottomPlotHandle = gca;

AxesBoundaries = [0:2:24; 2:2:26]';

[nPlots, junk] = size(AxesBoundaries);

cd('/Volumes/USBDISKPRO/OvernightConditioningData/UnitConditioningSeriesPlots')


for i = 1:nPlots
    
    set(TopPlotHandle,'XLim', AxesBoundaries(i,:));
    set(BottomPlotHandle,'XLim', AxesBoundaries(i,:));
    
    DelimiterStr = ['[',num2str(AxesBoundaries(i,:)),']'];
    
    saveas(fhandle, ['PlotSegment',DelimiterStr,'.jpg'], 'jpg');
    
end

cd('/Users/thug/Documents/Fetzlab/ICSS/StimOnVsStimOffCode');

    
    
    