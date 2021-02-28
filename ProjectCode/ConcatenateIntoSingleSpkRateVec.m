function ConcatenatedVec = ConcatenateIntoSingleSpkRateVec(BinWidth_sec)

    CodeDir = pwd;

    FileDir = uigetdir;
    
    cd(FileDir);
    Files = dir('MuscleConditioningSimRecord*.mat')
    
    nFiles = length(Files);
    
    ConcatenatedVec = [];
    
    for i = 1:nFiles
        
        cd(FileDir);
        
        load(Files(i).name);
       
        cd(CodeDir);
        
        Mock_spkrate = ProcessIntoSpkRateVec(Record, BinWidth_sec);
        
        ConcatenatedVec = [ConcatenatedVec, Mock_spkrate];
        
    end

    cd ..
    cd('StimOnVsStimOffCode')

    SpkRatesPerPeriodStruct = CalculateSpkratesPerPeriod2(ConcatenatedVec', 1/BinWidth_sec);

    cd ..
    cd('Project')
    
end