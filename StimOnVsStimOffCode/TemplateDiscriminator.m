function OutputStruct = TemplateDiscriminator(RawActivity, ...
    ExampleActivityThresholdCrossingsStruct, ExampleActivityPrinCompStruct...
    ExampleActivityPrincipalComponents, SelectedAreaParametersStruct)

    % Unpack Example Activity threshold-crossing parameters
    Threshold = ExampleActivityThresholdCrossingsStruct.ThresholdLevel;
    
    SlopeSign = ExampleActivityThresholdCrossingsStruct.ThresholdSlope;
    
    RefractoryPeriod = ExampleActivityThresholdCrossingsStruct.PostCrossingRefractoryPeriod;
    
    % Unpack Example Activity sample mean and principal components
    PrincipalComponentsArray = ExampleActivityPrinCompStruct.EigenVectors;
    
    NormalizedMeanProfile = ExampleActivityPrinCompStruct.NormalizedMeanProfile;
   
    SampleProjectionsOntoMean = ExampleActivityPrinCompStruct.ProjectionOntoMean;
    
    % Unpack template definition parameters
    IndicesOfSelectedTemplateExamples = SelectedAreaParametersStruct.SelectedProjectionsList;
    
    TemplateAreaCM = SelectedAreaParametersStruct.CenterOfMass;

    TemplateAreaTheta = SelectedAreaParametersStruct.EllipseRotationAngle;

    TemplateAreaPrincipalMomentsOfInertia = ...
        SelectedAreaParametersStruct.PrincipalMomentsOfInertia;

    TemplateAreaPrincipalAxes = SelectedAreaParametersStruct.PrincipalAxes;
    
    % Generate distribution of SELECTED projections onto mean profile;
    SelectedSampleProjectionsOntoMean = ...
        SampleProjectionsOntoMean(IndicesOfSelectedTemplateExamples);
    
    MeanOfSelProjectionsOntoMean = mean(SelectedSampleProjectionsOntoMean);
    StdevOfSelProjectionsOntoMean = stdev(SelectedSampleProjectionsOntoMean);
    
    
    
    