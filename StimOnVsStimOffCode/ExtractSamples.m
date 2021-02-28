function OutputStruct = ExtractSamples(RawActivity, EventIndicesList, SamplingFrequency, WindowFloorTime, WindowCeilingTime)

nEvents = length(EventIndicesList);

MaxActivityIndex = length(RawActivity);

RelativeEventIndices = floor(SamplingFrequency*WindowFloorTime):...
    ceil(SamplingFrequency*WindowCeilingTime);

SampleSize = length(RelativeEventIndices);
OnesVec = ones([1,SampleSize]);
ZerosVec = zeros([1,SampleSize]);
PeriEventSamples = NaN*ones([nEvents, SampleSize]);
ExtractionIndicesList = NaN*ones([nEvents, SampleSize]);

for i = 1:nEvents
    
    ExtractionIndices = EventIndicesList(i)*OnesVec + RelativeEventIndices;
    
    ExtractionIndices(ExtractionIndices <= ZerosVec) = NaN;
    ExtractionIndices(ExtractionIndices > MaxActivityIndex*OnesVec) = NaN;
    
    for j = 1:SampleSize
    
        if ~isnan(ExtractionIndices(j))
            PeriEventSamples(i,j) = RawActivity(ExtractionIndices(j));
        end
    
    end
    
    ExtractionIndicesList(i,:) = ExtractionIndices;
    ExtractionIndices = [];
    
end;

OutputStruct.PeriEventSamples = PeriEventSamples;
OutputStruct.ExtractionIndicesList = ExtractionIndicesList;