function OutputStruct = AccumulationVisualizer2(ReinforcingStimAlphaParams, ...
    FatigueAlphaParams, nIterations)
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
    
    SamplingFrequency = 150;
    MaxStimRate = 50;
    nStepsPerEpisode = 10*60*150;
    TransitionStep = round(nStepsPerEpisode/2);
    
    SevereFatigueBoundary = 1;

    InitialTDStruct = TDLearningStructInitializer2(...
        StatesTable, ActionsTable, nStepsPerEpisode, TransitionStep,...
        SamplingFrequency, MaxStimRate, SevereFatigueBoundary, FatigueAlphaParams, ...
        ReinforcingStimAlphaParams);
    
    EnvStruct = InitialTDStruct.PrevEnvStruct
    NextStateIndex = InitialTDStruct.StateIndices(end);
    
    OutputStruct.ReinforcingStimLevel = NaN*ones([1,nIterations]);
    OutputStruct.FatigueLevel = NaN*ones([1,nIterations]);
    
    for i = 1:nIterations
        
        if (mod(i,3) == 0)
            ActionIndex = 2;
        else
            ActionIndex = 1;
        end
        
        [NextStateIndex, NextReward, TerminateEpisode, EnvStruct] = Environment2(NextStateIndex,...
            ActionIndex, 45e3 + i, EnvStruct);
        
        OutputStruct.ReinforcingStimLevel(i) = EnvStruct.ReinforcingStimLevel;
        OutputStruct.FatigueLevel(i) = EnvStruct.FatigueLevel;
        
    end
    
    figure; hold on;
    plot(OutputStruct.ReinforcingStimLevel,'k');
    plot(OutputStruct.FatigueLevel,'r')

end