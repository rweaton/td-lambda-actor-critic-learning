function [NewBinLocations, NewSpkrate] = ReBin(spkrate, nBinsToAbsorb)

numOldBins = length(spkrate);
%OldBinLocations = 1:numOldBins;

numNewBins = floor(length(spkrate)/nBinsToAbsorb);

NewBinsIndexVec = 1:numNewBins;
NewBinLocations = nBinsToAbsorb*(NewBinsIndexVec) - (nBinsToAbsorb/2)*ones(size(NewBinsIndexVec));
NewBinLocations = NewBinLocations(:);

NewSpkrate = NaN*ones([numNewBins, 1]);

    for i = 1:numNewBins

        NewSpkrate(i) = sum(spkrate(((i-1)*nBinsToAbsorb + 1):i*nBinsToAbsorb));

    end

NewSpkrate = NewSpkrate/nBinsToAbsorb;

end