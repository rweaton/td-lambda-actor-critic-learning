function OutputStruct = TDLearning(EnvironmentFunction, InputStruct, StepParams)
%    
%     Actor-Critic TD(lambda) Learning (intra-episodic)
%
%     Written by: Ryan Eaton, 5/18/2009
%     Revised: 5/24/2009, 5/26/2009, 5/27/2009
%     Debugged: 5/27/2009 [using 5-state maze task]
%     
%     Notation and algorithms observe convention in Reinforcement Learning: 
%     An Introduction (1998) by Sutton and Barto

    clear('OutputStruct')
    % Step params
    alpha = StepParams(1);  % Step-size parameter (critic)
    beta = StepParams(2);   % Step-size parameter (actor)
    gamma = StepParams(3);  % Discount-rate parameter
    lambda = StepParams(4); % Decay-rate parameter for eligibility traces
    
    % Initialize OutputStruct using InputStruct
    OutputStruct = InputStruct;

    % Call variables from previous episode to initialize routine
    OutputStruct.StateIndices(1) = InputStruct.StateIndices(end); % Record of states
    OutputStruct.Reward(1) = InputStruct.Reward(end); % Record of actual rewards
    OutputStruct.V_s(:,1) = InputStruct.V_s(:,1); % Record of predicted rewards
    OutputStruct.Pref_sa(:,1,:) = InputStruct.Pref_sa(:,end,:); % Record of state-action preferences
    OutputStruct.e_C = InputStruct.e_C; % Critic state eligibility trace (vector)
    OutputStruct.e_A = InputStruct.e_A; % Actor state-action pair eligibility trace (array)
    
    %OuputStruct.PrevEnvStruct = InputStruct.PrevEnvStruct;
    
    % Determine number of loop iterations
    [nStates, nSteps, nActions] = size(OutputStruct.Pref_sa);
    StateIndicesList = 1:nStates;
    ActionIndicesList = 1:nActions;
    
    % Iterate over each time increment comprising the episode
    TerminateEpisode = false;
    i = 1;
    while  ~TerminateEpisode
        
        % Select action given current state under current policy 
        % State-action preference array Pref_sa guides policy
        NextActionIndex = Chooser(SoftMax(OutputStruct.Pref_sa(...
            OutputStruct.StateIndices(i),i,:)));
        try,
        OutputStruct.ActionIndices(i) = NextActionIndex;

        catch,
        OutputStruct.ActionIndices = [OutputStruct.ActionIndices, NextActionIndex];
        
        end

        % Given current state and selected action, output the resulting "environmental
        % response" i.e. reward received for arriving at next state.
        fhandle = str2func(EnvironmentFunction);
        PrevEnvStruct = OutputStruct.PrevEnvStruct;
        StateIndex = OutputStruct.StateIndices(i);
        ActionIndex = OutputStruct.ActionIndices(i);
        [NextStateIndex, NextReward, TerminateEpisode, EnvStruct] = ...
            feval(fhandle,OutputStruct.StateIndices(i), ...
            OutputStruct.ActionIndices(i), i, OutputStruct.PrevEnvStruct);
        
        try,
        OutputStruct.StateIndices(i+1) =  NextStateIndex;
        OutputStruct.Reward(i+1) = NextReward;

        catch,
        OutputStruct.StateIndices = [OutputStruct.StateIndices, NextStateIndex];       
        OutputStruct.Reward = [OutputStruct.Reward, NextReward];   
        
        end
        
        % TD-Error (scalar)
        delta = OutputStruct.Reward(i+1) + ...
            gamma*OutputStruct.V_s(OutputStruct.StateIndices(i+1),i) - ...
            OutputStruct.V_s(OutputStruct.StateIndices(i),i);
        
        % Bump eligibility trace that corresponds to current state
        OutputStruct.e_C(OutputStruct.StateIndices(i)) = ...
            OutputStruct.e_C(OutputStruct.StateIndices(i)) + 1;
        
        % Bump eligiblity trace that corresponds to current state-action
        % pair
        OutputStruct.e_A(OutputStruct.StateIndices(i),OutputStruct.ActionIndices(i)) = ...
            OutputStruct.e_A(OutputStruct.StateIndices(i),OutputStruct.ActionIndices(i)) + 1;
        
        % Update reward predictions
        for j = 1:nStates
            
            NextV_s = ...
                OutputStruct.V_s(StateIndicesList(j),i) + ...
                alpha*delta*OutputStruct.e_C(StateIndicesList(j));
            
            try,
            OutputStruct.V_s(StateIndicesList(j),i+1) = NextV_s;
            
            catch,
            ArrayToAppend = zeros([nStates,1]);
            ArrayToAppend(j,1) = NextV_s;
            OutputStruct.V_s = cat(2, OutputStruct.V_s, ArrayToAppend);
            
            end
            
            OutputStruct.e_C(StateIndicesList(j)) = ...
                gamma*lambda*OutputStruct.e_C(StateIndicesList(j));
            
            % Update state-action pair preferences (policy)
            for k = 1:nActions
                
                NextPref_sa = ...
                    OutputStruct.Pref_sa(StateIndicesList(j), i,...
                    ActionIndicesList(k)) + ...
                    beta*delta*OutputStruct.e_A(StateIndicesList(j), ...
                    ActionIndicesList(k));
                
                try,
                OutputStruct.Pref_sa(StateIndicesList(j), i+1,...
                    ActionIndicesList(k)) = NextPref_sa;

                
                catch,
                ArrayToAppend = zeros([nStates,1,nActions]);
                ArrayToAppend(j,1,k) = NextPref_sa;
                OutputStruct.Pref_sa = cat(2, OutputStruct.Pref_sa, ArrayToAppend);            
                
                end
                
                OutputStruct.e_A(StateIndicesList(j), ActionIndicesList(k)) = ...
                    gamma*lambda*OutputStruct.e_A(StateIndicesList(j), ...
                    ActionIndicesList(k));
                
            end
            
        end
            
         
        
        % Update environment for next time step of episode
        OutputStruct.PrevEnvStruct = EnvStruct; 
        
        i = i + 1;
        
    end
    
    % Free extra pre-allocated memory if episode iteration count i is less
    % than nSteps.
    if i < nSteps
        
        OutputStruct.ActionIndices(i:end) = [];
        OutputStruct.StateIndices((i+1):end) = [];
        OutputStruct.Reward((i+1):end) = [];
        
        OutputStruct.V_s(:,(i+1):end) = [];
        OutputStruct.Pref_sa(:,(i+1):end,:) = [];
        
    end

end