function Record = RunActivityContingentConditioningTask3(nEpisodes)
%
%   High-level function to iterate temporal difference (TD) learning of 
%   time-in/time-out conditioning task using the activity-contingent, 
%   behaviorally-reinforcing brain stimulation environment: Environment2.  
%   This function iterates TD learning over the user-specified number of 
%   episodes.  TDLearning.m output from each episode is stored to the 
%   struct array: Record.
%
%   Written by: Ryan Eaton, 5/28/2009
%   Debugged: 5/28/2009

    clear('InputStruct','StepParams','EnvironmentFunction','Record')
    EnvironmentFunction = 'Environment2';
    CodeDirectory = pwd;

%   Define UniqueStateValuesArray:
    UniqueStateValuesCellArray = cell(3,1);
    UniqueStateValuesCellArray(1,1) = {{false, true}}; % muscle contracted?
    UniqueStateValuesCellArray(2,1) = {{false, true}}; % reinforcing stim. pulse delivered?
    UniqueStateValuesCellArray(3,1) = {{0, 1, 2, 3}}; % discretized level of current muscle fatigue

%   Compile list of all possible state vectors (columns in StatesTable)
    StatesTable = StateTableCellMaker(UniqueStateValuesCellArray);

%   Define ActionsTable    
    ActionsTable = {false,true}; % contract muscle?
    
    SamplingFrequency = 200; % intra-episodic time resolution (Hz)
    MaxStimRate = 50; % Imposed rate ceiling on repeated stim pulse delivery (Hz)
    
%   Define activity-contingent stimulation availability (intra-episodic 
%   time-out to time-in transition event)
    TrialLength_sec = 10*60;
    nStepsPerEpisode = round(SamplingFrequency*TrialLength_sec);
    TransitionStep = round(SamplingFrequency*TrialLength_sec/2);

%   Specify parameters governing negative reinforcement effect of muscle fatigue.
%   Set linear rates of muscle fatigue acumulation and decay 
    SevereFatigueBoundary = 2.5;
%    FatigueSpecs = [15/SamplingFrequency, 15/SamplingFrequency];
    FatigueAlphaParams = [10, (2.5/9), 100];
    
%   Set temporal discounting and lambda-decay of stim. pulse contribution 
%   to continuous reward signal 
%    ReinforcingStimAccumulationParams = [1, 0.99];
    ReinforcingStimAlphaParams = [6, 1, 100];
    
    InputStruct = TDLearningStructInitializer2(...
        StatesTable, ActionsTable, nStepsPerEpisode, TransitionStep,...
        SamplingFrequency, MaxStimRate, SevereFatigueBoundary, FatigueAlphaParams, ...
        ReinforcingStimAlphaParams);

    %nEpisodes = 50;
    % StepParams = [alpha, beta, gamma, lambda];
    StepParams = [0.2, 0.05, 0.8, 0.95];
    
    nEpisodesPerSave = 1;
    nSaves = nEpisodes/nEpisodesPerSave;
    
    for i = 1:nSaves
        
        for j = 1:nEpisodesPerSave
        
            % Note final state of previous episode is the beginning state of
            % following episode--in this way, the task is continuous.  when 
            % concatenating episodes, remember to remove the state and reward
            % assigned to the final step of the episode... the state is
            % redundant, the reward is inaccurate.


            tic
                InputStruct = TDLearning(EnvironmentFunction, InputStruct, StepParams);
                Record(j) = InputStruct;
            toc

            disp('Program running overnight... Please, please let be.  [RE 6/07/2009]')
        
        end
        
        
        cd('/Users/pbguest/Desktop/OvernightRun')
        
        if (i <= 9)
            save(['MuscleConditioningSimRecord00',num2str(i)]);
        elseif (i >= 10) & (i <= 99)
            save(['MuscleConditioningSimRecord0',num2str(i)]);
        else
            save(['MuscleConditioningSimRecord',num2str(i)]);
        end
        
        cd(CodeDirectory);
        
        Record(:) = [];

%     for i = 1:nEpisodes
%         
%         % Note final state of previous episode is the beginning state of
%         % following episode--in this way, the task is continuous.  when 
%         % concatenating episodes, remember to remove the state and reward
%         % assigned to the final step of the episode... the state is
%         % redundant, the reward is inaccurate.
%         tic
%             InputStruct = TDLearning(EnvironmentFunction, InputStruct, StepParams);
%             Record(i) = InputStruct;
%         toc
%         
%         disp('Program running overnight... Please, please let be.  [RE 6/02/09]')
% 
%     end
    
end



