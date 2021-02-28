function [NewBinLocations, NewSpkrate] = ReBin2(spkrate, SamplingFreq, nBinsToAbsorb)

% INPUT DEFINITIONS:
% spkrate: vector of rate values (typically spkrate or emgrate)
% SamplingFreq: Sampling frequency of the rate signal (i.e. the number of
% bins per second).  For bin-size 1172 at 11720 Hz this translates to 10
% Hz.
% nBinsToAbsorb:  The number of rate vector elements to
% include in each plotted bar. "absorb" means summing together each set of rate values 
% and then dividing that sum by the number of bins.

% EXAMPLE
% ReBin2(spkrate, 10, 100) will plot average rate of activity during 10
% second intervals.  The time axis of the plot is in units of hours.

numOldBins = length(spkrate);
%OldBinLocations = 1:numOldBins;

numNewBins = floor(length(spkrate)/nBinsToAbsorb);

NewBinsIndexVec = 1:numNewBins;
NewBinLocations = round(nBinsToAbsorb*(NewBinsIndexVec) - (nBinsToAbsorb/2)*ones(size(NewBinsIndexVec)));
NewBinLocations = NewBinLocations(:);

NewSpkrate = NaN*ones([numNewBins, 1]);

    for i = 1:numNewBins

        NewSpkrate(i) = sum(spkrate(((i-1)*nBinsToAbsorb + 1):i*nBinsToAbsorb));

    end

NewSpkrate = NewSpkrate/nBinsToAbsorb;

SampleInc = 1/SamplingFreq;
TimeVec_hours = (1/3600)*(0:SampleInc:SampleInc*(numOldBins - 1));

% figure;
% bar(TimeVec_hours(NewBinLocations), NewSpkrate, 'k', 'EdgeColor', 'none', 'BarWidth', 1);
% axis([0 max(TimeVec_hours(NewBinLocations)) 0 max(NewSpkrate)]);
% xlabel('time (hours)');
% ylabel('activity rate (events/sec)');

end