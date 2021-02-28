function NewTimeVec = ReSample(TimeVec, nSamplesToAbsorb)

numOldSamples = length(TimeVec);
numNewSamples = floor(length(TimeVec)/nSamplesToAbsorb);

NewTimeVec = NaN*ones([numNewSamples,1]);

for i = 1:numNewSamples
    
    NewTimeVec(i) = TimeVec(i*nSamplesToAbsorb);
    
end
    