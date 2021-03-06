function spkrate = LargeValueFilter(spkrate, ThresholdCriterion)

% This function removes undesirable artifacts that still occupy the
% filtered and corrected spkrates vector.  It simply replaces activity greater 
% than some user-specified absolute threshold with NaNs

%Filtered_spkrate = spkrate;
%DiffValues = [0; diff(spkrate)];
HighValueIndices = find(spkrate >= ThresholdCriterion);
%LowValueIndices = find(DiffValues <= -ThresholdCriterion);

spkrate(HighValueIndices) = NaN;

end