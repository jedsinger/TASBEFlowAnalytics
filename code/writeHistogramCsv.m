% Copyright (C) 2010-2017, Raytheon BBN Technologies and contributors listed
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.

function histogramFile = writeHistogramCsv(numConditions, channels, sampleIds, binCounts, binCenters, pathToOutputFiles)

    % First create the default output filename.
    histogramFile = [pathToOutputFiles '/histogramFile.csv'];
    
    % Create a header for the first row of the output file.
    fileHeader = buildDefaultStatsFileHeader(channels);
    
    histTable = table;
    for i=1:numConditions
        % Build a table and concatenate 
        perSampleTable = formatDataPerSample(sampleIds{i}, binCenters{i}, binCounts{i});
        histTable = [histTable; perSampleTable];
    end
    
    % Use the fileHeader for the column names on the table.
    histTable.Properties.VariableNames = fileHeader;
    writetable(histTable, histogramFile, 'WriteVariableNames', true);
end

function fileHeader = buildDefaultStatsFileHeader(channels)
    % Default file header to match the default file format.
    
    % Not elegant, but it gets the job done.
    for i=1:numel(channels)
        channelName = getName(channels{i});
        binHeaders{i} = ['BinCount_' channelName];
    end
    
    % Don't separate with commas. We want all the column names in a cell
    % array so we can pass them to a table.
    fileHeader = {'ID', 'BinCenters', binHeaders};
end


function perSampleTable = formatDataPerSample(sampleId, binCenters, counts)
    % The channels are actually the column labels for the data and the
    % binCenters are actually the row labels.  To make writing the data to
    % a CSV file easier, I'm going to include the binCenters in the table
    % like they are data, not just row names.
    
    % File formatted as follows:
    % SampleId, BinCenters, Channel_1_counts, Channel_2_counts, ...
    
    % Only the sampleId needs to be padded to create the table.
    [numCountsPerChannel, numChannels] = size(counts);
    
    % Number of rows to pad
    rowsOfPadding = numCountsPerChannel-1;
    
    % Need to pad the sampleId with a column vector
    sampleIdPadding = cell(rowsOfPadding, 1);
    
    % Pad the sampleId
    sampleIdPadded = [{sampleId}; sampleIdPadding];
    
    % Hacky way to build the table, but need the individual columns if we
    % want individual column names.
    perSampleTable = table(sampleIdPadded, binCenters);
    
    % TODO: How big will the data be?  Should we worry about trying to
    % preallocate the table or not put on column specific headers?
    
    % Add the counts as columns
    for i=1:numChannels
        perSampleTable = [perSampleTable, counts(:,i)];
    end
end
