function CountVec = ContractionRateBinner(ActionsTable, ActionIndices, BinWidth_steps)

    nBins = round(length(ActionIndices)/BinWidth_steps);
    CountVec = NaN*ones([1,nBins]);
    
    for i = 1:nBins
        Indices = ((i - 1)*BinWidth_steps + 1):(i*BinWidth_steps);
        CountVec(i) = sum([ActionsTable{ActionIndices(Indices)}]);
    end
    
end