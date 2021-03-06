function Filtered_spkrate = DifferentialFilter(spkrate, ThresholdCriterion)

% This function removes spike artifacts from the spkrate vector.  
% Be certain to set ThresholdCriterion > 50 to avoid removing the
% step transitions between Enabled and Disabled stimulation states.

Filtered_spkrate = spkrate;
DiffValues = [0; diff(spkrate)];
HighValueIndices = find(DiffValues >= ThresholdCriterion);
LowValueIndices = find(DiffValues <= -ThresholdCriterion);
IndicesToChange = [HighValueIndices(1:2:(length(HighValueIndices)-1)), LowValueIndices(1:2:(length(LowValueIndices)-1))];

Filtered_spkrate(IndicesToChange) = NaN;

end