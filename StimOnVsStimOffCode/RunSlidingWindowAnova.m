function OutputStruct = RunSlidingWindowAnova(CalculateSpkratesOutputStruct, nPeriodsPerWindow)

%%% This routine is written under the assumption that all conditioning
%%% sessions begin in the stimulator on state (enabled).

TimeVec_hours = CalculateSpkratesOutputStruct.TimeVec_hours;
Adjusted_spkrate = CalculateSpkratesOutputStruct.Adjusted_spkrate;

ToEnabledStatesIndices = CalculateSpkratesOutputStruct.ToEnabledStatesIndices;
FromEnabledStatesIndices = CalculateSpkratesOutputStruct.FromEnabledStatesIndices;

ToDisabledStatesIndices = CalculateSpkratesOutputStruct.ToDisabledStatesIndices;
FromDisabledStatesIndices = CalculateSpkratesOutputStruct.FromDisabledStatesIndices;

nStates = length(ToEnabledStatesIndices) + length(ToDisabledStatesIndices);

% Initialize transition indices matrix
TransitionIndicesMatrix = NaN*ones([2, nStates]);
IsEnabled = ~isnan(NaN*ones([1, nStates]));

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

for i = StartIndex:EndIndex
    
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
    
    % Concatonate Activities into a single column vector
    Labels = [Set1Labels, Set2Labels];
    Rates = [Set1Rates; Set2Rates];
    
    pValues(i) = anova1(Rates,Labels,'off');
    
end

OutputStruct.SlidingWindowCenters = WindowCenters;
OutputStruct.CorrespondingPValues = pValues(~isnan(pValues));

