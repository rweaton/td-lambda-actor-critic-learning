function OutputStruct = RunSlidingWindowKStest(CalculateSpkratesOutputStruct, nPeriodsPerWindow)

%%% This routine is written under the assumption that all conditioning
%%% sessions begin in the stimulator on state (enabled).

    function BooleanOutput = iseven(NumericalInput)

       % Modulus values will be 1 if odd and zero if even, 1's indicate odd
       % values
       BooleanOutput = mod(NumericalInput, 2*ones(size(NumericalInput)));

       % BooleanOutput is currently an "isodd" logical array
       BooleanOutput = logical(BooleanOutput);

       % BooleanOutput is now an "iseven" logical array
       BooleanOutput = ~BooleanOutput;

    end;

    function BooleanOutput = isodd(NumericalInput)
       
       % Modulus values will be 1 if odd and zero if even, 1's indicate odd
       % values        
       BooleanOutput = mod(NumericalInput, 2*ones(size(NumericalInput)));
       
       % Convert to logical array
       BooleanOutput = logical(BooleanOutput);
       
    end;
        

TimeVec_hours = CalculateSpkratesOutputStruct.TimeVec_hours;
Adjusted_spkrate = CalculateSpkratesOutputStruct.Adjusted_spkrate;

ToEnabledStatesIndices = CalculateSpkratesOutputStruct.ToEnabledStatesIndices;
FromEnabledStatesIndices = CalculateSpkratesOutputStruct.FromEnabledStatesIndices;

ToDisabledStatesIndices = CalculateSpkratesOutputStruct.ToDisabledStatesIndices;
FromDisabledStatesIndices = CalculateSpkratesOutputStruct.FromDisabledStatesIndices;

nStates = length(ToEnabledStatesIndices) + length(ToDisabledStatesIndices);

% Initialize transition indices matrix
TransitionIndicesMatrix = NaN*ones([2, nStates]);

% Build transition indices matrix
for i = 1:nStates
    
    if (mod(i,2) == 1)
        
        TransitionIndicesMatrix(:,i) = ...
            [ToEnabledStatesIndices(ceil(i/2)); FromEnabledStatesIndices(ceil(i/2))];
        
        IsEnabled(i) = logical(1);
        
    end
    
    if (mod(i,2) == 0)
        
        TransitionIndicesMatrix(:,i) = ...
            [ToDisabledStatesIndices(i/2); FromDisabledStatesIndices(i/2)];
        
    end
    
end

%nPeriods = 2*nPeriodsPerWindow;

% Calculate window starting and ending indices
StartIndex = 1 + nPeriodsPerWindow;
EndIndex = nStates - nPeriodsPerWindow;

WindowCenters = StartIndex:EndIndex;
pValues = NaN*ones(size(1:nStates));

% Initialize EnabledGreater array
EnabledGreater = NaN*ones(size(1:nStates));

for i = StartIndex:EndIndex
    
    % Determine whether Set1 is enabled or disabled
    if isodd(i)
        
       if isodd(nPeriodsPerWindow)
           Set1Classification = 'disabled';
       end
       
       if iseven(nPeriodsPerWindow)
           Set1Classification = 'enabled';
       end
       
    elseif iseven(i)
        
       if isodd(nPeriodsPerWindow)
           Set1Classification = 'enabled';
       end
       
       if iseven(nPeriodsPerWindow)
           Set1Classification = 'disabled';
       end
       
    end
    
    Set1Indices = [];
    Set2Indices = [];
    
    %IndicesToExtract = (i-nPeriodsPerWindow):(i + nPeriodsPerWindow - 1);
    Set1BoundaryIndices = (i - nPeriodsPerWindow):2:(i + nPeriodsPerWindow - 2);
    Set2BoundaryIndices = Set1BoundaryIndices + ones(size(Set1BoundaryIndices)); 
    
    Set1Boundaries = TransitionIndicesMatrix(:,Set1BoundaryIndices);
    Set2Boundaries = TransitionIndicesMatrix(:,Set2BoundaryIndices);
    
        
    for j = 1:nPeriodsPerWindow
       
            Set1Indices = [Set1Indices, Set1Boundaries(1,j):Set1Boundaries(2,j)];
            
            Set2Indices = [Set2Indices, Set2Boundaries(1,j):Set2Boundaries(2,j)];
        
    end
    
    Set1Rates = Adjusted_spkrate(Set1Indices);
    Set2Rates = Adjusted_spkrate(Set2Indices);
    
    Set1Rates = Set1Rates(~isnan(Set1Rates));
    Set2Rates = Set2Rates(~isnan(Set2Rates));
    
    Set1Labels(1:length(Set1Rates)) = {'set1'}; 
    Set2Labels(1:length(Set2Rates)) = {'set2'};
    
    Set1RatesMean = mean(Set1Rates);
    Set2RatesMean = mean(Set2Rates);
    
    if strcmp(Set1Classification,'enabled')&(Set1RatesMean > Set2RatesMean)
        EnabledGreater(i) = 1;
    end
    
    if strcmp(Set1Classification,'disabled')&(Set1RatesMean < Set2RatesMean)
        EnabledGreater(i) = 1;
    end
    
    if strcmp(Set1Classification,'enabled')&(Set1RatesMean <= Set2RatesMean)
        EnabledGreater(i) = 0;
    end
    
    if strcmp(Set1Classification,'disabled')&(Set1RatesMean >= Set2RatesMean)
        EnabledGreater(i) = 0;
    end
    
    % Concatonate Activities into a single column vector
    Labels = [Set1Labels, Set2Labels];
    Rates = [Set1Rates; Set2Rates];
    
    if (~isempty(Set1Rates))&(~isempty(Set2Rates))
        [H, pValues(i), KSstat] = kstest2(Set1Rates, Set2Rates, 0.001, 'unequal');
    end
    
    
    
end

% Truncate EnabledGreater NaNs and convert to logical array
%EnabledGreater(1:20)
EnabledGreater = EnabledGreater(~isnan(EnabledGreater));
EnabledGreater = logical(EnabledGreater);

OutputStruct.SlidingWindowCenters = WindowCenters;
OutputStruct.CorrespondingPValues = pValues(~isnan(pValues));
OutputStruct.EnabledGreater = EnabledGreater;

end

