% This is a temporary function created to make adding new fields to
% ColorModel and updating .mat files easier.

% Add new fields to the end of ColorModel and execute 'clear classes' in
% the command window. When calling matfile on a .mat file without the new
% field in the command window, the data is loaded into a struct instead of
% a class.

% In the command window, add the new field to the struct with the
% appropriate default information, then execute the following commands:
%   CM = ColorModel
%   CM = createCMFromStruct(CM, name_of_struct)

% You will need to update a datafile in the Tutorial repo. Assuming the
% complete path to the file is stored in a variable named 'filename',
% execute the following in the command window:
%   save(filename, 'CM)

% If we decide to keep this function around, add a check to make sure the
% second parameter is actually a structure.
function CM = createCMFromStruct( CM, myStruct )
    for fn = fieldnames(myStruct)'
        try
            CM.(fn{1}) = myStruct.(fn{1});
        catch
            warning('Could not copy field %s', fn{1});
        end
    end

end
