function OutputStruct = TimeInFilterGenerator2(Filtered_spkrate)

% This function generates a binary Filter vectors of the same length as Filtered_spkrate 
% in which ones indicate times at which the stimulator was enabled
% (EnabledFilter) or disabled (DisabledFilter) as well as times of
% transition between the two states (ToEnabledStateIndices etc)

Filtered_spkrate = Filtered_spkrate(:);

TimeInFilter = NaN*ones(size(Filtered_spkrate));

Diff_spkrate = [0; diff(Filtered_spkrate)];

figure; plot(Diff_spkrate)

ToEnabledStateIndices = find(Diff_spkrate > 30);
ToDisabledStateIndices = find(Diff_spkrate < -30);
FromEnabledStateIndices = ToDisabledStateIndices - ones(size(ToDisabledStateIndices));
FromDisabledStateIndices = ToEnabledStateIndices - ones(size(ToEnabledStateIndices));

ToEnabledStateIndices = [1; ToEnabledStateIndices];

% Append termination Index to last period whether its Enabled or Disabled
if max(ToEnabledStateIndices) > max(ToDisabledStateIndices)
    FromEnabledStateIndices = [FromEnabledStateIndices; length(Filtered_spkrate)];
end

if max(ToDisabledStateIndices) > max(ToEnabledStateIndices)
    FromDisabledStateIndices = [FromDisabledStateIndices; length(Filtered_spkrate)];
end

nStates = max([length(FromEnabledStateIndices), length(FromDisabledStateIndices)]);

EnabledFilter = NaN*ones(size(Filtered_spkrate));
DisabledFilter = NaN*ones(size(Filtered_spkrate));
  

%Check = (ToEnabledStateIndices(1:146) < FromEnabledStateIndices(1:146));
%figure; plot(1:146, Check, '.')

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