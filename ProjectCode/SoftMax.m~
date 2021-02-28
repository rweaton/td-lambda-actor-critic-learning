function PolicyVec = SoftMax(PrefVec)
%
%   Function to convert a list of unbounded "Preference" values into a list
%   of corresponding probabilities that sum to one.
%
%   Written by: Ryan Eaton, 5/18/2009
%   Revised: 5/29/2009
%
    % Need to bound values in PrefVec to prevent exponential blow-up
    PrefVec(PrefVec < -100) = -100;
    PrefVec(PrefVec > 100) = 100;
    
    % Compute probabilities to be used in chooser.
    PolicyVec = exp(PrefVec)./sum(exp(PrefVec));

end