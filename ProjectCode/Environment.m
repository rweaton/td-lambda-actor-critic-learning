function [NextStateIndex, NextReward, TerminateEpisode, EnvStruct] = ...
    Environment(StateIndex, ActionIndex, StepNumber, PrevEnvStruct)
%     
%     
%     Simulated environment to facilitate muscle contraction using
%     EMG-contingent, behaviorally-reiniforcing, brain stimulation.
%     
%     Written by: Ryan Eaton, 5/23/2009
%     Revised: 5/24/2009
%     Debugged: 5/24/2009,5/29/2009

    % Unpack relevant variables describing previous state of environment
    StepsSincePreviousStimPulse = PrevEnvStruct.StepsSincePreviousStimPulse;
    
    % Retain intra-episodic time resolution, stim rate ceiling and fatigue boundary definitions
    EnvStruct.SamplingFrequency = PrevEnvStruct.SamplingFrequency;
    EnvStruct.MaxStimRate = PrevEnvStruct.MaxStimRate;
    EnvStruct.SevereFatigueBoundary = PrevEnvStruct.SevereFatigueBoundary;
    
    % Unpack stimulation and muscle fatigue accumulation-rate parameters
    FatigueIncrementSize = PrevEnvStruct.FatigueSpecs(1); 
    FatigueDecrementSize = PrevEnvStruct.FatigueSpecs(2);
    
    gamma = PrevEnvStruct.ReinforcingStimAccumulationParams(1);
    lambda = PrevEnvStruct.ReinforcingStimAccumulationParams(2);
    
    EnvStruct.nStepsPerEpisode = PrevEnvStruct.nStepsPerEpisode;
    % Unpack intra-episodic time take for time-out to time-in transition
    TransitionStep = PrevEnvStruct.TransitionStep;
    
    % Retain state and action definitions
    EnvStruct.StatesTable = PrevEnvStruct.StatesTable;
    EnvStruct.ActionsTable = PrevEnvStruct.ActionsTable;
    
    % Process muscle-contingent stim pulse availability schedule
    if (StepNumber >= TransitionStep)
        StimulatorEnabled = true;
    else
        StimulatorEnabled = false;
    end
    
    % Process imposed maximum stim pulse frequency ceiling
    n = ceil(EnvStruct.SamplingFrequency/EnvStruct.MaxStimRate);
    if (StepsSincePreviousStimPulse >= n)
        UnderStimRateCeiling = true;
    else
        UnderStimRateCeiling = false;
    end
    
    % To contract or not to contract: that is the question.
    MuscleContraction = EnvStruct.ActionsTable{ActionIndex};
    NextState(1,1) = {EnvStruct.ActionsTable{ActionIndex}};
   
    
    % Multifactor-contingent stim pulse delivery
    if (MuscleContraction)&(UnderStimRateCeiling)&(StimulatorEnabled)
        NextState(2,1) = {true};
        EnvStruct.StepsSincePreviousStimPulse = 0;
    else
        NextState(2,1) = {false};
        EnvStruct.StepsSincePreviousStimPulse = ...
            StepsSincePreviousStimPulse + 1;
    end
    
    % Process stim pulse reward profile
    EnvStruct.ReinforcingStimLevel = gamma*lambda*PrevEnvStruct.ReinforcingStimLevel + ...
        KroneckerDelta(NextState{2,1},1); % (stim pulse reward always positive)
    
    % Process fatigue level profile
    if MuscleContraction
        EnvStruct.FatigueLevel = PrevEnvStruct.FatigueLevel + ...
            FatigueIncrementSize;
    else
        if (PrevEnvStruct.FatigueLevel > FatigueDecrementSize)
            EnvStruct.FatigueLevel = PrevEnvStruct.FatigueLevel -...
                FatigueDecrementSize;
        else
            EnvStruct.FatigueLevel = 0; %(fatigue always positive)
        end
    end
    
    % Process combined reward profile (stim pulse - fatigue profiles)
    EnvStruct.RewardLevel = EnvStruct.ReinforcingStimLevel - EnvStruct.FatigueLevel;
    NextReward = EnvStruct.RewardLevel;
    
    % Assign the appropriate discrete "fatigue state" for updated fatigue
    % level -- a continuous variable.
    FatigueStates = sort(unique([EnvStruct.StatesTable{3:3,1:end}]),'ascend');
    nFatigueStates = length(FatigueStates);
    
    DiscreteFatigueRange = EnvStruct.SevereFatigueBoundary/(nFatigueStates - 2);
    
    FatigueStateBoundaries = DiscreteFatigueRange*[0, 1:(nFatigueStates - 2)];
    
    for i = 2:(nFatigueStates - 1)
        
       if (EnvStruct.FatigueLevel <= FatigueStateBoundaries(1))
          
           NextState(3,1) = {FatigueStates(1)};
       
       elseif (EnvStruct.FatigueLevel > FatigueStateBoundaries(end))
          
           NextState(3,1) = {FatigueStates(nFatigueStates)};
          
       elseif (EnvStruct.FatigueLevel > FatigueStateBoundaries(i-1))& ...
               (EnvStruct.FatigueLevel <= FatigueStateBoundaries(i))
           
           NextState(3,1) = {FatigueStates(i)};
           
       end      
       
    end
    
    % Find the column of StatesTable cell array that matches NextState cell 
    % array.  Output the corresponding column index .
    [nStateEntries, nPossibleStates] = size(EnvStruct.StatesTable);
    ColumnIndices = 1:nPossibleStates;
    
    for j = 1:nPossibleStates
        
        if isequal(EnvStruct.StatesTable(1:nStateEntries,j:j),NextState)
            NextStateIndex = ColumnIndices(j);
        end
        
    end
    
    % Episode ends when the external iteration count reaches the
    % number of time steps in each episode -- preset by user.
    if (StepNumber >= EnvStruct.nStepsPerEpisode)
        TerminateEpisode = true;
    else
        TerminateEpisode = false;
    end
    
    % Bundle remaining environment information into EnvStruct.  To be
    % used in future calls of this routine.
    
    EnvStruct.FatigueSpecs = [FatigueIncrementSize, FatigueDecrementSize]; 
    EnvStruct.ReinforcingStimAccumulationParams = [gamma, lambda];
    EnvStruct.TransitionStep = TransitionStep;

    
end