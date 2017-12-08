% Copyright (C) 2010-2017, Raytheon BBN Technologies and contributors listed
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.

function statisticsFile = writeStatisticsCsv(channels, sampleIds, sampleresults, baseName)

    % First create the default output filename.
    statisticsFile = [baseName '_statisticsFile.csv'];
    
    numConditions = numel(sampleIds);
    
    totalCounts = cell(numConditions, 1);
    geoMeans = cell(numConditions, 1);
    geoStdDev = cell(numConditions, 1);
    
    for i=1:numConditions
        numReplicates = numel(sampleresults{i});
        totalCounts{i} = cell(1,numReplicates);
        geoMeans{i} = cell(1,numReplicates);
        geoStdDev{i} = cell(1,numReplicates);
        for j=1:numReplicates
            totalCounts{i}{j} = sum(sampleresults{i}{j}.BinCounts);
            geoMeans{i}{j} = sampleresults{i}{j}.Means;
            geoStdDev{i}{j} = sampleresults{i}{j}.StandardDevs;
        end
    end
    
    % Column name creation moved due to naming conflict in matlab.
    statsTable = table;
    for i=1:numConditions
        % Build a table and concatenate 
        perSampleTable = formatDataPerSampleIndivdualColumns(channels, sampleIds{i}, totalCounts{i}, geoMeans{i}, geoStdDev{i});
        statsTable = [statsTable; perSampleTable];
    end
    
    % Needed to add column names when I created the tables due to conflicts
    % with the default names.  For a table, the column names must be valid
    % matlab variable names so I filtered out spaces and hypens and
    % replaced them with underscores.
    writetable(statsTable, statisticsFile, 'WriteVariableNames', true);
end

function perSampleTable = formatDataPerSampleIndivdualColumns(channels, sampleId, totalCounts, means, stddevs)
    % SampleId should just be a string. Means and stddevs should be a 1 by
    % number of channels matrix.  TotalCounts should be a 1 by number of
    % channels matrix.
    % Place replicates on separate lines. Padding will be necessary in
    % order to build a table.  Separate into individual columns..
    numChannels = numel(channels);
    numReplicates = numel(totalCounts);
    
    % Number of rows to pad
    rowsOfPadding = numReplicates-1;
    
    % Need to pad with a column vector
    sampleIdPadding = cell(rowsOfPadding, 1);
    
    % Split by the channels so the table will have the correct column labels.
    geoMeans = cell(1, numChannels);
    geoStdDevs = cell(1, numChannels);
    counts = cell(1, numChannels);
    
    for i=1:numChannels
        for j=1:numReplicates
            geoMeans{i} = [geoMeans{i}; means{j}(i)];
            geoStdDevs{i} = [geoStdDevs{i}; stddevs{j}(i)];
            counts{i} = [counts{i}; totalCounts{j}(i)];
        end
    end
    
    % Pad the sampleId
    ID = [{sampleId}; sampleIdPadding];
    
    % TODO: How big will the data be?  Should we worry about trying to
    % preallocate the table or not put on column specific headers?
    
    % Hacky way to build the table, but need the individual columns if we
    % want individual column names.
    perSampleTable = table(ID, 'VariableNames', {'ID'});
    countsTable = table;
    meanTable = table;
    stdTable = table;
    
    % Add the counts as columns
    for i=1:numChannels
        channelName = getName(channels{i});
        invalidChars = '-|\s';  % Matlab does not like hypens or whitespace in variable names.
        matlabValidVariableNameChannelName = regexprep(channelName,invalidChars,'_');
        
        binColName = ['TotalCount_' matlabValidVariableNameChannelName];
        meanColName = ['GeoMean_' matlabValidVariableNameChannelName];
        stdDevColName = ['GeoStdDev_' matlabValidVariableNameChannelName];
        
        countsTable = [countsTable, table(counts{i},'VariableNames',{binColName})];
        meanTable = [meanTable, table(geoMeans{i},'VariableNames',{meanColName})];
        stdTable = [stdTable, table(geoStdDevs{i},'VariableNames',{stdDevColName})];
    end
    
    perSampleTable = [perSampleTable, countsTable, meanTable, stdTable];
    
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

