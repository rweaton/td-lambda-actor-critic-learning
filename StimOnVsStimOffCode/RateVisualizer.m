function OutputStruct = RateVisualizer(spkrate, OldBinWidth, NewBinWidth, Floor, Ceiling)

% EXAMPLE:
% RateVisualizer(spkrate, 0.1, 10, 1.5, 5.6)

% This command would absorb bins of 0.1 second width into 10 second bins,
% calculate the average event rate over each 10 second bin and plot these
% rates in the window spanning 1.5 to 5.6 hours of the recording.

% NewBinWidth must be an integer multiple of OldBinWidth
% OldBinWidth and NewBinWidth have units of seconds.
% Floor and Ceiling have units of hours.

    function NewSpkrate = ReBin(spkrate, nBinsToAbsorb)

    numOldBins = length(spkrate);
    numNewBins = floor(length(spkrate)/nBinsToAbsorb);

    NewSpkrate = NaN*ones([numNewBins,1]);

        for i = 2:numNewBins

            NewSpkrate(i) = sum(spkrate((i-1)*nBinsToAbsorb:i*nBinsToAbsorb));

        end

    end

nOldBins = length(spkrate);

if (mod(NewBinWidth, OldBinWidth) == 0)
    
    nBinsToAbsorb = NewBinWidth/OldBinWidth;
    nNewBins = nOldBins/nBinsToAbsorb;
    
    HourlyBinWidth = NewBinWidth/3600;
    LowerBinBoundariesVec = (0:(nNewBins-1))*HourlyBinWidth;
    UpperBinBoundariesVec = (1:nNewBins)*HourlyBinWidth;
    
    BinLocations = LowerBinBoundariesVec + (1/2)*UpperBinBoundariesVec;
    
    LowIndex = find((BinLocations >= Floor - (1/2)*HourlyBinWidth)&...
        (BinLocations <= Floor + (1/2)*HourlyBinWidth));
    
    HighIndex = find((BinLocations >= (Ceiling-HourlyBinWidth) - (1/2)*HourlyBinWidth)&...
        (BinLocations <= (Ceiling-HourlyBinWidth) + (1/2)*HourlyBinWidth));    
    
    NewSpkrateVec = ReBin(spkrate, nBinsToAbsorb);
    NewSpkrateVec = NewSpkrateVec'/NewBinWidth;
    
    figure; hold on
    bar(BinLocations, NewSpkrateVec,'k')
    axis([Floor, Ceiling, 0, max(NewSpkrateVec(LowIndex:HighIndex))]);
    title('Spkrate');
    xlabel('time (hours)');
    ylabel('spike rate (Hz)');
    
    OutputStruct.NewSpkrateVec = NewSpkrateVec;
    OutputStruct.BinLocations = BinLocations;
    
elseif (mod(NewBinWidth, OldBinWidth) ~= 0) 
    
    disp('ERROR: NewBinWidth must be an integer multiple of OldBinWidth')
    OutputStruct.NewSpkrateVec = [];
    OutputStruct.BinLocations = [];
    
end;

end
