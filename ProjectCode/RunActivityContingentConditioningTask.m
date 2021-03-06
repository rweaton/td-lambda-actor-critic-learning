function Record = RunActivityContingentConditioningTask(nEpisodes)
%
%   High-level function to iterate temporal difference (TD) learning of 
%   time-in/time-out conditioning task using the activity-contingent, 
%   behaviorally-reinforcing brain stimulation environment: Environment.  
%   This function iterates TD learning over the user-specified number of 
%   episodes.  TDLearning.m output from each episode is stored to the 
%   struct array: Record.
%
%   Written by: Ryan Eaton, 5/28/2009
%   Debugged: 5/28/2009

    clear('InputStruct','StepParams','EnvironmentFunction','Record')
    EnvironmentFunction = 'Environment';

%   Define UniqueStateValuesArray:
    UniqueStateValuesCellArray = cell(3,1);
    UniqueStateValuesCellArray(1,1) = {{false, true}}; % muscle contracted?
    UniqueStateValuesCellArray(2,1) = {{false, true}}; % reinforcing stim. pulse delivered?
    UniqueStateValuesCellArray(3,1) = {{0, 1, 2, 3}}; % discretized level of current muscle fatigue

%   Compile list of all possible state vectors (columns in StatesTable)
    StatesTable = StateTableCellMaker(UniqueStateValuesCellArray);

%   Define ActionsTable    
    ActionsTable = {false,true}; % contract muscle?
    
    SamplingFrequency = 150; % intra-episodic time resolution (Hz)
    MaxStimRate = 50; % Imposed rate ceiling on repeated stim pulse delivery (Hz)
    
%   Define activity-contingent stimulation availability (intra-episodic 
%   time-out to time-in transition event)
    TrialLength_sec = 60;
    nStepsPerEpisode = SamplingFrequency*TrialLength_sec;
    TransitionStep = round(SamplingFrequency*TrialLength_sec/2);

%   Specify parameters governing negative reinforcement effect of muscle fatigue.
%   Set linear rates of muscle fatigue acumulation and decay 
    SevereFatigueBoundary = 25;
    FatigueSpecs = [15/SamplingFrequency, 15/SamplingFrequency];
    
%   Set temporal discounting and lambda-decay of stim. pulse contribution 
%   to continuous reward signal 
    ReinforcingStimAccumulationParams = [1, 0.99];
    
    InputStruct = TDLearningStructInitializer(...
            StatesTable, ActionsTable, nStepsPerEpisode, TransitionStep,...
            SamplingFrequency, MaxStimRate, SevereFatigueBoundary, FatigueSpecs, ...
            ReinforcingStimAccumulationParams);

    %nEpisodes = 50;
    % StepParams = [alpha, beta, gamma, lambda];
    StepParams = [0.02, 0.02, 0.8, 0.9];
    
    

    for i = 1:nEpisodes
        
        % Note final state of previous episode is the beginning state of
        % following episode--in this way, the task is continuous.  when 
        % concatenating episodes, remember to remove the state and reward
        % assigned to the final step of the episode... the state is
        % redundant, the reward is inaccurate.
        tic
            InputStruct = TDLearning(EnvironmentFunction, InputStruct, StepParams);
            Record(i) = InputStruct;
        toc
        t = toc

    end
    
end



