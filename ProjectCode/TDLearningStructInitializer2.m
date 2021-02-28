function OutputStruct = TDLearningStructInitializer2(...
    StatesTable, ActionsTable, nStepsPerEpisode, TransitionStep,...
    SamplingFrequency, MaxStimRate, SevereFatigueBoundary, FatigueAlphaParams, ...
    ReinforcingStimAlphaParams)
%    
%     Initializes all variables required for TDLearning and Environment2
%     routines.
%     
%     Written by Ryan Eaton, 5/20/2009
%     Revised: 5/24/2009, 5/27/2009, 6/1/2009 
%     Debugged: 6/1/2009

    [nElementsPerState, nStates] = size(StatesTable);
    [nElementsPerAction, nActions] = size(ActionsTable);
    
    OutputStruct.StateIndices = round(nStates*rand([1,nStepsPerEpisode]));
    OutputStruct.StateIndices(1,end) = 1;
    
    OutputStruct.ActionIndices = round(nActions*rand([1,nStepsPerEpisode]));
    OutputStruct.ActionIndices(1,end) = 1;
    
    OutputStruct.Reward = rand([1,nStepsPerEpisode]);
    OutputStruct.Reward(1,end) = 0;
    
    OutputStruct.V_s = rand([nStates,nStepsPerEpisode]);
    %OutputStruct.V_s(:,end) = 0;
    
    OutputStruct.Pref_sa = rand([nStates,nStepsPerEpisode,nActions]);
    %OutputStruct.Pref_sa(:,end,:) = 0; 
    
    OutputStruct.e_C = zeros([1,nStates]);
    OutputStruct.e_A = zeros([nStates,nActions]);
    
    OutputStruct.PrevEnvStruct.FatigueLevel = 0;
    OutputStruct.PrevEnvStruct.ReinforcingStimLevel = 0;
    OutputStruct.PrevEnvStruct.RewardLevel = 0;
    
    OutputStruct.PrevEnvStruct.StepsSincePreviousStimPulse = ceil(SamplingFrequency/MaxStimRate);
    
    OutputStruct.PrevEnvStruct.SamplingFrequency = SamplingFrequency;
    OutputStruct.PrevEnvStruct.MaxStimRate = MaxStimRate;
    OutputStruct.PrevEnvStruct.SevereFatigueBoundary = SevereFatigueBoundary;
    
    OutputStruct.PrevEnvStruct.FatigueAlphaParams = FatigueAlphaParams; 
    OutputStruct.PrevEnvStruct.ReinforcingStimAlphaParams = ...
        ReinforcingStimAlphaParams;
    
    OutputStruct.PrevEnvStruct.ContractionHistory = [];
    OutputStruct.PrevEnvStruct.StimHistory = [];
    
    OutputStruct.PrevEnvStruct.nStepsPerEpisode = nStepsPerEpisode;
    OutputStruct.PrevEnvStruct.TransitionStep = TransitionStep;
    
    OutputStruct.PrevEnvStruct.StatesTable = StatesTable;
    OutputStruct.PrevEnvStruct.ActionsTable = ActionsTable;
    
end