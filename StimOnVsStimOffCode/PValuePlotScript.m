% Plot pValues script

pValueFloor = 1e-3;
pValueCeiling = 5e-2;

Range = log(pValueCeiling/pValueFloor);

XVec = KStestStruct.SlidingWindowCenters;
YVec = ones(size(XVec));
pVec = KStestStruct.CorrespondingPValues;

SortedIndices = SpkratesPerPeriodOutputStruct.SortedIndices;
TimeVec_hours = SpkratesPerPeriodOutputStruct.TimeVec_hours;

BarLocations = TimeVec_hours(SortedIndices(XVec));

nEntries = length(pVec);
ColorVec = NaN*ones(size(pVec));

figure; hold on;

for i = 1:nEntries
    
        if (pVec(i) > pValueCeiling)

            ColorVec(i) = 1;
            
        end

        if (pVec(i) <= pValueFloor)

            ColorVec(i) = 0.5;
            
        end
        
        if (pVec(i) < pValueCeiling)&(pVec(i) > pValueFloor)
            
            ColorVec(i) = 0.7;
            
        end
            
    bar(BarLocations(i), YVec(i), 'FaceColor', [ColorVec(i), ColorVec(i), ColorVec(i)],...
        'EdgeColor', 'none', 'BarWidth', 1);
    
end