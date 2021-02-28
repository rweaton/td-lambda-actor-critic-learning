function OutputStruct = TimeInFilterGenerator3(Filtered_spkrate)

% This function generates a binary Filter vectors of the same length as Filtered_spkrate 
% in which ones indicate times at which the stimulator was enabled
% (EnabledFilter) or disabled (DisabledFilter) as well as times of
% transition between the two states (ToEnabledStateIndices etc)

Filtered_spkrate = Filtered_spkrate(:);

MinWidth = 2600;

nSamples = length(Filtered_spkrate);

TimeInFilter = NaN*ones(size(Filtered_spkrate));

Diff_spkrate = [0; diff(Filtered_spkrate)];

ToEnabledStateIndices = [];
ToDisabledStateIndices = [];

j = 0;

for(i = 1:nSamples)
    
    if(Filtered_spkrate(i) >= 50)
      
      j = j + 1;
        
      if(j == 1)
          temp = i;
      end
      
    end
      
    if((Filtered_spkrate(i) < 50) && (Filtered_spkrate(i) - Filtered_spkrate(i-1) < -20))
        
      if(j >= MinWidth)
        ToDisabledStateIndices = [ToDisabledStateIndices, i];
        ToEnabledStateIndices = [ToEnabledStateIndices, temp];
      end
      
      j = 0;
      
    end
    
end
      
FromEnabledStateIndices = ToDisabledStateIndices - ones(size(ToDisabledStateIndices));
FromDisabledStateIndices = ToEnabledStateIndices(2:length(ToEnabledStateIndices)) - ones(size(2:length(ToEnabledStateIndices)));

%figure; plot(Diff_spkrate)

% ToEnabledStateIndices = find(Diff_spkrate > 25);
% ToDisabledStateIndices = find(Diff_spkrate < -25);
% FromEnabledStateIndices = ToDisabledStateIndices - ones(size(ToDisabledStateIndices));
% FromDisabledStateIndices = ToEnabledStateIndices - ones(size(ToEnabledStateIndices));

max(ToEnabledStateIndices)
max(FromEnabledStateIndices)

%ToEnabledStateIndices = [1, ToEnabledStateIndices];


EnabledFilter = NaN*ones(size(Filtered_spkrate));
DisabledFilter = NaN*ones(size(Filtered_spkrate));
  
nStates = length(FromDisabledStateIndices)
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
OutputStruct.ToEnabledStateIndices = ToEnabledStateIndices';
OutputStruct.FromEnabledStateIndices = FromEnabledStateIndices';
OutputStruct.ToDisabledStateIndices = ToDisabledStateIndices';
OutputStruct.FromDisabledStateIndices = FromDisabledStateIndices';



end