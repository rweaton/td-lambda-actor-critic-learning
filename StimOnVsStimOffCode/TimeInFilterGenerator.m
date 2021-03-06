function OutputStruct = TimeInFilterGenerator(Filtered_spkrate)

% This function generates a binary Filter vectors of the same length as Filtered_spkrate 
% in which ones indicate times at which the stimulator was enabled
% (EnabledFilter) or disabled (DisabledFilter) as well as times of
% transition between the two states (ToEnabledStateIndices etc)

Filtered_spkrate = Filtered_spkrate(:);

TimeInFilter = NaN*ones(size(Filtered_spkrate));

Diff_spkrate = [0; diff(Filtered_spkrate)];

ToEnabledStateIndices = find(Diff_spkrate > 40);
ToDisabledStateIndices = find(Diff_spkrate < -40);
FromEnabledStateIndices = ToDisabledStateIndices - ones(size(ToDisabledStateIndices));
FromDisabledStateIndices = ToEnabledStateIndices - ones(size(ToEnabledStateIndices));

ToEnabledStateIndices = [1; ToEnabledStateIndices];

length(ToEnabledStateIndices)
length(FromEnabledStateIndices)

EnabledFilter = NaN*ones(size(Filtered_spkrate));
DisabledFilter = NaN*ones(size(Filtered_spkrate));

nStates = length(FromEnabledStateIndices);

for i = 1:nStates
    EnabledFilter(ToEnabledStateIndices(i):FromEnabledStateIndices(i)) = 1;
end

DisabledFilter = double(isnan(EnabledFilter));
DisabledFilter(find(DisabledFilter==0)) = NaN;

DisabledFilter(max(FromDisabledStateIndices):length(Filtered_spkrate)) = NaN;

OutputStruct.EnabledFilter = EnabledFilter;
OutputStruct.DisabledFilter = DisabledFilter;
OutputStruct.ToEnabledStateIndices = ToEnabledStateIndices;
OutputStruct.FromEnabledStateIndices = FromEnabledStateIndices;
OutputStruct.ToDisabledStateIndices = ToDisabledStateIndices;
OutputStruct.FromDisabledStateIndices = FromDisabledStateIndices;

end