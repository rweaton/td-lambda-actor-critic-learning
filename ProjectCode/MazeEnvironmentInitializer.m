function OutputStruct = MazeEnvironmentInitializer()
%
%   Routine to initialize required variables for maze task
%
%   Written by: Ryan Eaton 5/27/2009
%   Debugged: 5/27/09

    clear('OutputStruct')
    nStates = 5;
    OutputStruct.PrevEnvStruct.ActionsTable = {'left','right'};
    nActions = length(OutputStruct.PrevEnvStruct.ActionsTable);
    
    StatesMatrix = eye(nStates);
    
    for i = 1:nStates
        OutputStruct.PrevEnvStruct.StatesTable(1,i) = {StatesMatrix(:,i)};
    end
    
    nStepsPerEpisode = nStates;
    OutputStruct.PrevEnvStruct.nStepsPerEpisode = nStepsPerEpisode;
    
    % Preallocate memory for TD learning variables;
    OutputStruct.V_s = rand([nStates, nStepsPerEpisode]);
    OutputStruct.Pref_sa = rand([nStates, nStepsPerEpisode, nActions]);
    OutputStruct.StateIndices = NaN*ones([1,nStepsPerEpisode]);
    OutputStruct.ActionIndices = NaN*ones([1,nStepsPerEpisode]);;
    OutputStruct.Reward = NaN*ones([1,nStepsPerEpisode]);
    
    OutputStruct.e_C = zeros([1,nStates]);
    OutputStruct.e_A = zeros([nStates,nActions]);
    
    % Set initial values
    %OutputStruct.V_s(:,end) = zeros([nStates,1]);
    %OutputStruct.Pref_sa(:,end,:) = zeros([nStates,nActions]);
    OutputStruct.StateIndices(end) = 3;
    OutputStruct.Reward(end) = 0;
    
    
end