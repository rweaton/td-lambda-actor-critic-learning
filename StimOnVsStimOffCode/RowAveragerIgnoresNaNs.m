function Average = RowAveragerIgnoresNaNs(Samples)

    NaNFilter = ~isnan(Samples);
    NumNonNaNsInEachColumn = sum(NaNFilter,1);
    
    Samples(~NaNFilter) = 0;
    
    Average = sum(Samples,1)./NumNonNaNsInEachColumn;

end