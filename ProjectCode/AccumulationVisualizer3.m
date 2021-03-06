function OutputStruct = AccumulationVisualizer3(ReinforcingStimAlphaParams, ...
    FatigueAlphaParams, DeltaVec)
%
% Function plots the reward progression reinforcing stimulation
% and fatigue over repeated muscle contractions. Progressions calculated
% using user-specified accumulation parameters.
%     
% Written by: Ryan Eaton,  5/24/2009
% Revised: 6/1/2009
% Debugged: 5/24/2009

    UniqueStateValuesCellArray = {{false,true};{false,true};{0, 1, 2, 3}};
    
    StatesTable = StateTableCellMaker(UniqueStateValuesCellArray);
    
    ActionsTable = {false, true};
    
    SamplingFrequency = 200;
    MaxStimRate = 50;
    nStepsPerEpisode = 10*60*SamplingFrequency;
    TransitionStep = round(nStepsPerEpisode/2);
    
    SevereFatigueBoundary = 1;

    InitialTDStruct = TDLearningStructInitializer2(...
        StatesTable, ActionsTable, nStepsPerEpisode, TransitionStep,...
        SamplingFrequency, MaxStimRate, SevereFatigueBoundary, FatigueAlphaParams, ...
        ReinforcingStimAlphaParams);
    
    EnvStruct = InitialTDStruct.PrevEnvStruct
    NextStateIndex = InitialTDStruct.StateIndices(end);
    
    nIterations = length(DeltaVec);
    OutputStruct.ReinforcingStimLevel = NaN*ones([1,nIterations]);
    OutputStruct.FatigueLevel = NaN*ones([1,nIterations]);
    
    for i = 1:nIterations
        
        if (DeltaVec(i) == 1)
            ActionIndex = 2;
        else
            ActionIndex = 1;
        end
        
        [NextStateIndex, NextReward, TerminateEpisode, EnvStruct] = Environment2(NextStateIndex,...
            ActionIndex, TransitionStep - i, EnvStruct);
        
        OutputStruct.ReinforcingStimLevel(i) = EnvStruct.ReinforcingStimLevel;
        OutputStruct.FatigueLevel(i) = EnvStruct.FatigueLevel;
        
    end
    
    figure; hold on;
    plot(OutputStruct.ReinforcingStimLevel,'k');
    plot(OutputStruct.FatigueLevel,'r')

end