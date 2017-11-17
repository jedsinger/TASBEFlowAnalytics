% Copyright (C) 2010-2017, Raytheon BBN Technologies and contributors listed
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.
%
% translates arbitrary units of a particular channel to ERF

function data = au_to_ERF(CM,channel,audata)
    FITCdata = zeros(size(audata));
    for i=1:numel(CM.Channels)
        FITCdata = translate(CM.color_translation_model,audata,channel,CM.FITC_channel);
    end
    % Translate FITC AU to ERFs
    k_ERF= getK_ERF(CM.unit_translation);
    data = FITCdata*k_ERF;
