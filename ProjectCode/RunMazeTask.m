function Record = RunMazeTask(nEpisodes)
%
%   High-level function to iterate TD learning of 5-state maze task over
%   specified number of episodes.  The TDLearning output from each episode
%   is stored to the struct array: Record.
%
%   Written by: Ryan Eaton, 5/27/2009
%   Debugged: 5/27/2009

    clear('InputStruct','StepParams','EnvironmentFunction','Record')
    EnvironmentFunction = 'MazeEnvironment';

    InputStruct = MazeEnvironmentInitializer;

    %nEpisodes = 50;
    % StepParams = [alpha, beta, gamma, lambda];
    StepParams = [0.2, 0.2, 0.8, 0.9];

    %Record = struct
    for i = 1:nEpisodes
        InputStruct.StateIndices(end) = 3;
        InputStruct.Reward(end) = 0;
        InputStruct = TDLearning(EnvironmentFunction, InputStruct, StepParams);
        Record(i) = InputStruct;

    end


end