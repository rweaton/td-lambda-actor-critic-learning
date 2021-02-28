function StatesTable = StateTableMaker(UniqueStateValuesArray)
%
%   Function takes a cell arrayed list of unique state values -- each row of
%   UniqueStateValuesArray contains all of the possible values each element
%   in the state vector may take -- and then compiles these values into a table of
%   all possible states.
%
%   Written by Ryan Eaton, 5/20/2009
%   Debugged: 5/21/2009.
%   
%   UniqueStateValuesArray example:
%       UniqueStateValuesArray(1) = {{false}, {true}} % muscle contracted?
%       UniqueStateValuesArray(2) = {{false}, {true}} % reinforcing stim. pulse delivered?
%       UniqueStateValuesArray(3) = {{0},{1},{2},{3}} % level of current muscle fatique 

    nStateElements = length(UniqueStateValuesArray);

    nUniqueStates = 1;
    for i = 1:nStateElements

        nUniqueStates = nUniqueStates*length(UniqueStateValuesArray{i});

    end;
    
    StatesTable = NaN*ones([nStateElements, nUniqueStates]);

    ColumnCount = 1;
    
    function StatesMaker(CurrentRow, EntryList)
       
        if CurrentRow == nStateElements
            
            for i = 1:length(UniqueStateValuesArray{CurrentRow})
                
               StatesTable(:,ColumnCount) = ...
                   [EntryList'; UniqueStateValuesArray{CurrentRow}(i)];
               
               ColumnCount = ColumnCount + 1;
               
            end
            
            %EntryList = [];
            
        else
            
            for j = 1:length(UniqueStateValuesArray{CurrentRow})
                
                EntryList(CurrentRow) = UniqueStateValuesArray{CurrentRow}(j);
                
                StatesMaker(CurrentRow + 1, EntryList);
                
            end
            
        end
        
        
            
    end

    StatesMaker(1,[]);
    
end