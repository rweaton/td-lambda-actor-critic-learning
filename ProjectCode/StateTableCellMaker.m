function StatesTableCell = StateTableCellMaker(UniqueStateValuesCellArray)


    % Generates table of unique states, each state a column vector in the
    % cell array StatesTableCell.  Each cell nested in each row cell in the
    % input argument UniqueStateValuesCellArray should be a unique value
    % that the corresponding element each state vector may take.
    
    % Written by Ryan Eaton, 5/23/2009
    % Debugged 5/23/2009
    
    nStateElements = length(UniqueStateValuesCellArray);

    nUniqueStates = 1;
    for i = 1:nStateElements

        nUniqueStates = nUniqueStates*length(UniqueStateValuesCellArray{i});

    end;
    
    StatesTableCell = cell([nStateElements, nUniqueStates]);

    ColumnCount = 1;
    
    function StatesCellMaker(CurrentRow, EntryList)
       
        if CurrentRow == nStateElements
            
            for i = 1:length(UniqueStateValuesCellArray{CurrentRow})
               
               EntryList(CurrentRow) = {UniqueStateValuesCellArray{CurrentRow}{i}}; 
                
%                StatesTableCell(1:nStateElements,ColumnCount:ColumnCount) = ...
%                    {EntryList; UniqueStateValuesCellArray{CurrentRow}{i}};

               StatesTableCell(1:nStateElements,ColumnCount:ColumnCount) = EntryList;
               
               ColumnCount = ColumnCount + 1;
               
            end
            
            %EntryList = [];
            
        else
            
            for j = 1:length(UniqueStateValuesCellArray{CurrentRow})
                
                EntryList(CurrentRow,1) = {UniqueStateValuesCellArray{CurrentRow}{j}};
                
                StatesCellMaker(CurrentRow + 1, EntryList);
                
            end
            
        end
        
        
            
    end

    StatesCellMaker(1,{});
    
end