function OutputStruct = ExtractPeriAcceptanceActivity(RawActivity, SamplingFrequency, WindowFloorTime, WindowCeilingTime)

% This function is used to take snippits of the raw activity vector in the
% vicinity of acceptance bits.  Typical values for the input arguments are: 
% RawActivity = spkraw, SamplingFrequency = 11720, WindowFloorTime 
% (in seconds) = -0.01, WindowCeilingTime = 0.03

AcceptanceBitValue = 127;
TopWindowUpperLimit = 60;
MinSpikeDerivMagnitude = AcceptanceBitValue - TopWindowUpperLimit;
MinInterAcceptanceTime = 0.005;
MinInterAcceptanceIndexNumber = SamplingFrequency*MinInterAcceptanceTime;


RawActivity = RawActivity(:);

ValueThresholdIndices = find(RawActivity == AcceptanceBitValue);

% filter ValueThresholdIndices
FilteredEventIndices = [];

nValues = length(ValueThresholdIndices)

for i = 2:nValues

	if ((RawActivity(ValueThresholdIndices(i)+1) - RawActivity(ValueThresholdIndices(i)) < -MinSpikeDerivMagnitude)&...
            (RawActivity(ValueThresholdIndices(i)) - RawActivity(ValueThresholdIndices(i)-1) > MinSpikeDerivMagnitude))
        if((ValueThresholdIndices(i) - ValueThresholdIndices(i-1)) >= MinInterAcceptanceIndexNumber)
            FilteredEventIndices = [FilteredEventIndices, ValueThresholdIndices(i)];
        end
	end
end

nEvents = length(FilteredEventIndices)

% Extract activity about the filtered event indices

SampleInc = 1/SamplingFrequency;

WindowFloorIndex = round(WindowFloorTime/SampleInc);
WindowCeilingIndex = round(WindowCeilingTime/SampleInc);

SnippitLength = length(WindowFloorIndex:WindowCeilingIndex);

AcceptanceTraces = NaN*ones([nEvents, SnippitLength]);

for i = 1:(nEvents-2)
	
	LowerLimitIndex = FilteredEventIndices(i) + WindowFloorIndex;
	UpperLimitIndex = FilteredEventIndices(i) + WindowCeilingIndex;

	if (LowerLimitIndex <= 0)
		
        StartIndex = SnippitLength - (length(1:UpperLimitIndex)-1);
        length(StartIndex:SnippitLength)
        AcceptanceTraces(i,StartIndex:SnippitLength) =...
            RawActivity(1:UpperLimitIndex);
    else   
        AcceptanceTraces(i,:) = RawActivity(LowerLimitIndex:UpperLimitIndex);
	end

	
	
end
SnippitTimeVec = SampleInc*(WindowFloorIndex:WindowCeilingIndex);
RemovalIndex = find(SnippitTimeVec == 0);
AcceptanceTracesBitRemoved = AcceptanceTraces;
AcceptanceTracesBitRemoved(:, RemovalIndex) = NaN;

OutputStruct.AcceptanceTracesWithBit = AcceptanceTraces;
OutputStruct.AcceptanceTracesBitRemoved =  AcceptanceTracesBitRemoved;
OutputStruct.SnippitTimeVec = SnippitTimeVec;
OutputStruct.EventIndices = FilteredEventIndices;
OutputStruct.EventTimes = SampleInc*FilteredEventIndices;

end

	