% Copyright (C) 2010-2017, Raytheon BBN Technologies and contributors listed 
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.

% Call readfsc_compensated_MEFL to convert the data. Write the data to a
% CSV file and return the data.  This will overwrite any existing data.

function data = fcsToCsvFlowConverterFileWriter(CM, filename, with_AF, floor)
    if(CM.initialized<1), error('Cannot read MEFL: ColorModel not yet resolved'); end; % ensure initted
    
    data = readfcs_compensated_ERF(CM, filename, with_AF, floor);
    [filepath,name,ext] = fileparts(filename);
    csvName = [filepath name '.csv'];
    
    % Create a table so we can write the column names and data with one
    % command.
    dataTable = table(data);
    
    % The column headers are just the channel names.
    dataTable.Properties.VariableNames = CM.Channels;
    writetable(dataTable, csvName, 'WriteVariableNames', true);
end

