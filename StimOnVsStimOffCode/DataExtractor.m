    function OutputStruct = DataExtractor(Input, ThresholdLocations, ...
                SamplingRange)
    
    % Written by Ryan Eaton
    % REVISED 5/12/2009
            
    % NOTES:        
    % New version of DataExtractor. Previous version extracted samples from 
    % ThresholdLocations(i) + StartOffset to ThresholdLocations(i) + EndOffset - 1.
    % This version extracts samples to ThresholdLocations(i) + EndOffset
    % (the full duration of the specified SamplingRange).  In previous version
    % correspondence of PeriEventIndices was shifted backward from proper
    % by one index
            
        Input = Input(:)';
        [junk, InputSize] = size(Input);

        nThresholds = length(ThresholdLocations);

        StartOffset = SamplingRange(1);
        EndOffset = SamplingRange(2);

        i = 1;
        Start = 1;
        
        while ThresholdLocations(i) <= -StartOffset
            
            i = i + 1;
            Start = i;
            
        end

        i = 0;
        End = nThresholds;
        
        while ThresholdLocations(nThresholds-i) + EndOffset > InputSize
            
            End = nThresholds - i;
            i = i + 1;
            
        end

        Samples = zeros([End-Start+1,(EndOffset-StartOffset)+1]);

        for i = Start:End

            if (ThresholdLocations(i) + EndOffset) <= InputSize
                
                Samples(i,:) = Input(1,(ThresholdLocations(i) + ...
                    StartOffset):(ThresholdLocations(i) + EndOffset));
                
            end

        end
        
        %OutputStruct.Input = Input;
        OutputStruct.ThresholdLocations = ThresholdLocations;
        OutputStruct.SamplingRange = SamplingRange;
        OutputStruct.InputSamples = Samples;
        OutputStruct.PeriEventIndices = (StartOffset:EndOffset);
        
    end