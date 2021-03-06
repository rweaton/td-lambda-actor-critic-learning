function [NextStateIndex, NextReward, TerminateEpisode, EnvStruct] = MazeEnvironment(StateIndex, ...
    ActionIndex, StepNumber, PrevEnvStruct)
%
%   This is a simple environment to be employed to test TDLearning.m.  It
%   is a sequential five state maze task.  Each trial ends when the agent
%   reaches either terminal state 1 (leftmost) or 5 (rightmost).  Only
%   state 5 is rewarded.  If the agent does indeed learn over repeated
%   trials, it should eventually adopt the optimal policy: move only right
%   to receive reward in fewest moves.
%
%   Written by: Ryan Eaton, 5/24/2009
%   Debugged:
    

    % Move right transition matrix
    RightwardTransitionMatrix = ...
        [0 0 0 0 0; ...
         1 0 0 0 0; ...
         0 1 0 0 0; ...
         0 0 1 0 0; ...
         0 0 0 1 1];

    % Move left transition matrix
    LeftwardTransitionMatrix = ...
        [1 1 0 0 0; ...
         0 0 1 0 0; ...
         0 0 0 1 0; ...
         0 0 0 0 1; ...
         0 0 0 0 0];
     
    % Retain state and action definitions
    EnvStruct.StatesTable = PrevEnvStruct.StatesTable;
    EnvStruct.ActionsTable = PrevEnvStruct.ActionsTable;
    
    % just a ballpark estimate for pre-allocation--number of steps per
    % episode varies since termination depends on stochastic progression to
    % one of two terminal states.
    EnvStruct.nStepsPerEpisode = PrevEnvStruct.nStepsPerEpisode;   
    
    % Pull current state vector
    StateVec = EnvStruct.StatesTable{1,StateIndex};
    
    % Pull current action choice
    Action = EnvStruct.ActionsTable{1,ActionIndex};
    
    if strcmp(Action,'right')
        
        NextStateVec = RightwardTransitionMatrix*StateVec;
        NextState = {NextStateVec};
        
    end
    
    if strcmp(Action, 'left')
       
        NextStateVec = LeftwardTransitionMatrix*StateVec;
        NextState = {NextStateVec};        
        
    end
    
    if isequal(EnvStruct.StatesTable(1,end),NextState)
        
        NextReward = 1;
        
    else
        
        NextReward = 0;
        
    end
    
    if isequal(EnvStruct.StatesTable(1,1),NextState) | ...
            isequal(EnvStruct.StatesTable(1,end),NextState)
        
        TerminateEpisode = true;
        
    else
        
        TerminateEpisode = false;
        
    end
    
    % Find the column of StatesTable cell array that matches NextState cell 
    % array.  Output the corresponding column index .
    [nStateEntries, nPossibleStates] = size(EnvStruct.StatesTable);
    ColumnIndices = 1:nPossibleStates;
    
    for i = 1:nPossibleStates
        
        if isequal(EnvStruct.StatesTable(1:nStateEntries,i:i),NextState)
            NextStateIndex = ColumnIndices(i);
        end
        
    end    
end