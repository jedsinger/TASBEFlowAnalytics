% Copyright (C) 2010-2017, Raytheon BBN Technologies and contributors listed 
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.

function data = readfcs_compensated_ERF(CM,filename,with_AF,floor)
    if(CM.initialized<1), error('Cannot read ERF: ColorModel not yet resolved'); end; % ensure initted
    
    % Read to arbitrary units
    audata = readfcs_compensated_au(CM,filename,with_AF,floor);
    % Translate each channel to ERF
    ERF_channel_data = zeros(size(audata));
    for i=1:numel(CM.Channels)
        ERF_channel_data(:,i) = translate(CM.color_translation_model,audata(:,i),CM.Channels{i},CM.ERF_channel);
    end
    % Translate ERF AU to ERFs
    k_ERF= getK_ERF(CM.unit_translation);
    data = ERF_channel_data*k_ERF;
    
