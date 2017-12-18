% Copyright (C) 2010-2017, Raytheon BBN Technologies and contributors listed
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.

function histogramFile = writeHistogramCsv(channels, sampleIds, sampleresults, binCenters, baseName)

    % First create the default output filename.
    histogramFile = [baseName '_histogramFile.csv'];
    
    numConditions = numel(sampleIds);
    
    % Pull histogram data out of sample results.
    binCounts = cell(numConditions, 1);
    for i=1:numConditions
        numReplicates = numel(sampleresults{i});
        binCounts{i} = cell(1,numReplicates);
        for j=1:numReplicates
            binCounts{i}{j} = sampleresults{i}{j}.BinCounts;
        end
    end
    
    histTable = table;
    for i=1:numConditions
        % Build a table and concatenate vertically
        perSampleTable = formatDataPerSample(channels, sampleIds{i}, binCenters, binCounts{i});
        histTable = [histTable; perSampleTable];
    end
    
    % Needed to add column names when I created the tables due to conflicts
    % with the default names.  For a table, the column names must be valid
    % matlab variable names so I filtered out spaces and hypens and
    % replaced them with underscores.
    writetable(histTable, histogramFile, 'WriteVariableNames', true);
end

function perSampleTable = formatDataPerSample(channels, sampleId, binCenters, counts)
    % The channels are actually the column labels for the data and the
    % binCenters are actually the row labels.  To make writing the data to
    % a CSV file easier, I'm going to include the binCenters in the table
    % like they are data, not just row names.
    
    % File formatted as follows:
    % SampleId, BinCenters, Channel_1_counts, Channel_2_counts, ...
    
    % Only the sampleId needs to be padded to create the table.
    numChannels = numel(channels);
    numReplicates = numel(counts);
    numBinsPerChannel = numel(binCenters);
    
    % Number of rows to pad sample id
    rowsOfPadding = numBinsPerChannel * numReplicates - 1;
    
    % Need to pad the sampleId with a column vector
    sampleIdPadding = cell(rowsOfPadding, 1);
    
    % Pad the sampleId
    sampleIdPadded = [{sampleId}; sampleIdPadding];
    
    % Make sure all rows match up with a bin center
    binCentersForAllReplicates = repmat(binCenters', numReplicates, 1);
    
    % Split by the channels so the table will have the correct column labels.
    binCounts = cell(1, numChannels);
    for i=1:numChannels
        for j=1:numReplicates
            binCounts{i} = [binCounts{i}; counts{j}(:,i)];
        end
    end
    
    % Hacky way to build the table, but need the individual columns if we
    % want individual column names.
    perSampleTable = table(sampleIdPadded, binCentersForAllReplicates, 'VariableNames', {'ID', 'BinCenters'});
    
    % TODO: How big will the data be?  Should we worry about trying to
    % preallocate the table or not put on column specific headers?
    binCountTable = table;
    
    % Add the counts as columns
    for i=1:numChannels
        channelName = getName(channels{i});
        invalidChars = '-|\s';  % Matlab does not like hypens or whitespace in variable names.
        matlabValidVariableNameChannelName = regexprep(channelName,invalidChars,'_');
        binColName = ['BinCount_' matlabValidVariableNameChannelName];
        
        binCountTable = [binCountTable, table(binCounts{i},'VariableNames',{binColName})];
    end
    
    perSampleTable = [perSampleTable, binCountTable];
end

function fileHeader = buildDefaultStatsFileHeader(channels)
    % Default file header to match the default file format.
    
    % Not elegant, but it gets the job done.
    for i=1:numel(channels)
        channelName = getName(channels{i});
        invalidChars = '-|\s';  % Matlab does not like hypens or whitespace in variable names.
        matlabValidVariableNameChannelName = regexprep(channelName,invalidChars,'_');
        binHeaders{i} = ['BinCount_' matlabValidVariableNameChannelName];
    end
    
    % Don't separate with commas. We want all the column names in a cell
    % array so we can pass them to a table.
    fileHeader = {'ID', 'BinCenters', binHeaders};
end
