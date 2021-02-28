function OutputStruct = ExtractPeriEventDataAcrossEpisodes(EventIndex, PeriEventWindow_steps)

    % This program assumes just one episode per file.
    WindowStart = EventIndex + PeriEventWindow_steps(1);
    WindowEnd = EventIndex + PeriEventWindow_steps(2);
        
    CodeDir = pwd;

    FileDir = uigetdir('/Volumes/EXCHANGE/OvernightRun');
    
    cd(FileDir);
    Files = dir('MuscleConditioningSimRecord*.mat')
    
    nFiles = length(Files);
    
    load(Files(1).name);
    [nStates, nSteps, nActions] = size(Record(1).Pref_sa);
    
    PeriEventStepWidth = (PeriEventWindow_steps(2) - PeriEventWindow_steps(1)) + 1;
    
    % Initialize variables
    OutputStruct.DeltaArray = NaN*ones([nStates, ...
        PeriEventStepWidth, nFiles]);
    
    OutputStruct.ContractionOffPolicyArray = NaN*ones([nStates, ...
        PeriEventStepWidth, nFiles]);
    
    OutputStruct.ContractionOnPolicyArray = NaN*ones([nStates, ...
        PeriEventStepWidth, nFiles]);
    
    DeltaVec = NaN*ones([nStates,(nSteps-1),1]);
    
    disp('Extracting peri-event data.  This will take time.')
    for i = 1:nFiles
        
        cd(FileDir);
        
        load(Files(i).name);
       
        cd(CodeDir);
        
        DeltaVec = diff(Record.V_s,1,2);
        
        OutputStruct.DeltaArray(:,:,i) = ...
            DeltaVec(:,WindowStart:WindowEnd,1);
        
        OutputStruct.ContractionOffPolicyArray(:,:,i) = ...
            Record.Pref_sa(:,WindowStart:WindowEnd,1);        
        
        OutputStruct.ContractionOnPolicyArray(:,:,i) = ...
            Record.Pref_sa(:,WindowStart:WindowEnd,2);
        
        disp('.')
        
    end
    
    cd(CodeDir);
    
    OutputStruct.MeanDeltaSurface = ...
        squeeze(mean(OutputStruct.DeltaArray,3));
    
    OutputStruct.MeanContractionOffPolicySurface = ...
        squeeze(mean(OutputStruct.ContractionOffPolicyArray,3));
    
    OutputStruct.MeanContractionOnPolicySurface = ...
        squeeze(mean(OutputStruct.ContractionOnPolicyArray,3));
    
    [X,Y] = meshgrid(1:nStates, PeriEventWindow_steps(1):PeriEventWindow_steps(2));
    
    fhandle = figure; hold on;
    subplot(3,1,1), plot3(X,Y,OutputStruct.MeanDeltaSurface','EdgeColor','none');
    subplot(3,1,2), plot3(X,Y,OutputStruct.MeanContractionOffPolicySurface','EdgeColor','none')
    subplot(3,1,3), plot3(X,Y,OutputStruct.MeanContractionOnPolicySurface','EdgeColor','none')

end