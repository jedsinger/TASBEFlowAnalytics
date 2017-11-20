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
    
    % Create a header for the first row of the output file (might not be
    % necessary).
    fileHeader = buildDefaultStatsFileHeader(channels);
    
    statsTable = table;
    for i=1:numConditions
        % Build a table and concatenate 
        perSampleTable = formatDataPerSample(sampleIds{i}, binCounts{i}, geoMeans{i}, geoStdDev{i});
        statsTable = [statsTable; perSampleTable];
    end
    
    % Write the table without headers for now. Included below is a second
    % function that will split the data into columns to allow for column
    % specific headers. Don't use it until we know we need the headers.
    writetable(statsTable, statisticsFile, 'WriteVariableNames', false);
end

function fileHeader = buildDefaultStatsFileHeader(channels)
    % Default file header to match the default file format.
    
    % Not elegant, but it gets the job done.
    for i=1:numel(channels)
        channelName = getName(channels{i});
        binHeaders{i} = ['BinCount_' channelName];
        meanHeaders{i} = ['GeoMean_' channelName];
        stdDevHeaders{i} = ['GeoStdDev_' channelName];
    end
    
    % Join the headers, again, not elegant
    binNames = strjoin(binHeaders, ',');
    meanNames = strjoin(meanHeaders, ',');
    stdDevNames = strjoin(stdDevHeaders, ',');
    
    allNames = {'ID', binNames, meanNames, stdDevNames};
    fileHeader = strjoin(allNames, ',');
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

function perSampleTable = formatDataPerSampleIndivdualColumns(sampleId, counts, means, stddevs)
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
    sampleIdPadded = [{sampleId}; sampleIdPadding];
    
    % TODO: How big will the data be?  Should we worry about trying to
    % preallocate the table or not put on column specific headers?
    
    % Hacky way to build the table, but need the individual columns if we
    % want individual column names.
    perSampleTable = table(sampleIdPadded);
    
    % Add the counts as columns
    for i=1:numChannels
        perSampleTable = [perSampleTable, counts(:,i)];
    end
    
    % Add the padded means as columns
    for i=1:numChannels
        perSampleTable = [perSampleTable, meansPadded{i}];
    end
    
    % Add the padded stddevs as columns
    for i=1:numChannels
        perSampleTable = [perSampleTable, stddevsPadded{i}];
    end
    
end