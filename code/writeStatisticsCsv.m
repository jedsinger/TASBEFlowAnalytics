% Copyright (C) 2010-2017, Raytheon BBN Technologies and contributors listed
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.

function statisticsFile = writeStatisticsCsv(numConditions, channels, sampleIds, binCounts, geoMeans, geoStdDev, pathToOutputFiles)

    % First create the default output filename.
    statisticsFile = [pathToOutputFiles '/statisticsFile.csv'];
    
    % Column name creation moved due to naming conflict in matlab.
    % Create a header for the first row of the output file.
%     fileHeader = buildDefaultStatsFileHeader(channels);
    
    statsTable = table;
    for i=1:numConditions
        % Build a table and concatenate 
        perSampleTable = formatDataPerSampleIndivdualColumns(channels, sampleIds{i}, binCounts{i}, geoMeans{i}, geoStdDev{i});
        statsTable = [statsTable; perSampleTable];
    end
    
    % Use the fileHeader for the column names on the table.
    %statsTable.Properties.VariableNames = fileHeader;
    
    % Needed to add column names when I created the tables due to conflicts
    % with the default names.  For a table, the column names must be valid
    % matlab variable names so I filtered out spaces and hypens and
    % replaced them with underscores.
    writetable(statsTable, statisticsFile, 'WriteVariableNames', true);
end

function perSampleTable = formatDataPerSampleIndivdualColumns(channels, sampleId, counts, means, stddevs)
    % SampleId should just be a string. Means and stddevs should be a 1 by
    % number of channels matrix.  Counts should be a M by number of
    % channels matrix.  Padding will be necessary in order to build a
    % table.  Separate into individual columns for labeling the columns
    % with headers.
    [numCountsPerChannel, numChannels] = size(counts);
    
    % Number of rows to pad
    rowsOfPadding = numCountsPerChannel-1;
    
    % Need to pad with a column vector
    columnVecPadding = cell(rowsOfPadding, 1);
    
    % Split the means and stddevs into columns and pad.
    for i=1:numChannels
        meansPadded{i} = [{means(1,i)}; columnVecPadding];
        stddevsPadded{i} = [{stddevs(1,i)}; columnVecPadding];
    end
    
    % Pad the sampleId
    ID = [{sampleId}; columnVecPadding];
    
    % TODO: How big will the data be?  Should we worry about trying to
    % preallocate the table or not put on column specific headers?
    
    % Hacky way to build the table, but need the individual columns if we
    % want individual column names.
    perSampleTable = table(ID, 'VariableNames', {'ID'});
    binCountTable = table;
    meanTable = table;
    stdTable = table;
    
    % Add the counts as columns
    for i=1:numChannels
        channelName = getName(channels{i});
        invalidChars = '-|\s';  % Matlab does not like hypens or whitespace in variable names.
        matlabValidVariableNameChannelName = regexprep(channelName,invalidChars,'_');
        
        binColName = ['BinCount_' matlabValidVariableNameChannelName];
        meanColName = ['GeoMean_' matlabValidVariableNameChannelName];
        stdDevColName = ['GeoStdDev_' matlabValidVariableNameChannelName];
        
        binCountTable = [binCountTable, table(counts(:,i),'VariableNames',{binColName})];
        meanTable = [meanTable, table(meansPadded{i},'VariableNames',{meanColName})];
        stdTable = [stdTable, table(stddevsPadded{i},'VariableNames',{stdDevColName})];
    end
    
    perSampleTable = [perSampleTable, binCountTable, meanTable, stdTable];
    
end

function fileHeader = buildDefaultStatsFileHeader(channels)
    % Default file header to match the default file format.
    
    % Not elegant, but it gets the job done.
    for i=1:numel(channels)
        channelName = getName(channels{i});
        binNames{i} = ['BinCount_' channelName];
        meanNames{i} = ['GeoMean_' channelName];
        stdDevNames{i} = ['GeoStdDev_' channelName];
    end
    
    % Don't separate with commas. We want all the column names in a cell
    % array so we can pass them to a table.
    fileHeader = {'ID', binNames, meanNames, stdDevNames};
end

function perSampleTable = formatDataPerSample(sampleId, counts, means, stddevs)
    % SampleId should just be a string. Means and stddevs should be a 1 by
    % number of channels matrix.  Counts should be a M by number of
    % channels matrix.  Padding will be necessary in order to build a
    % table.
    [numCountsPerChannel, numChannels] = size(counts);
    
    % Number of rows to pad
    rowsOfPadding = numCountsPerChannel-1;
    
    % Need to pad the sampleId with a column vector
    sampleIdPadding = cell(rowsOfPadding, 1);
    
    % Need to pad the means and stddevs with 2D matrix
    statsPadding = cell(rowsOfPadding, numChannels);
    
    % Everything except the counts needs to be padded, so convert them to cells.
    rowVec = ones(1, numChannels);
    meansCell = mat2cell(means, 1, rowVec);
    stddevsCell = mat2cell(stddevs, 1, rowVec);
    sampleIdCell = {sampleId};
    
    % Pad everything except counts
    meansPadded = [meansCell; statsPadding];
    stddevsPadded = [stddevsCell; statsPadding];
    sampleIdPadded = [sampleIdCell; sampleIdPadding];
    
    % Build the table
    perSampleTable = table(sampleIdPadded,counts,meansPadded,stddevsPadded);
end
