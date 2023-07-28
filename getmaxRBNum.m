function maxRBNum = getmaxRBNum(param)
%==========================================================================
% Function: Get the maximum RB number
% Input:
%       param struct
% Output:
%       maxRBNum,the maximum RB number in the configured numerology
%--------------------------------------------------------------------------
%% Input
mRAT = param.mRAT;
mTransmissionBandWidth = param.mTransmissionBandWidth;
mSubCarrierSpacing = param.mSubCarrierSpacing;

% Get Maximum RB number based on 3GPP
if strcmp(mRAT,'NR')
    if (mTransmissionBandWidth == 5 && mSubCarrierSpacing == 60) || (mTransmissionBandWidth == 60 && mSubCarrierSpacing == 15) || (mTransmissionBandWidth == 70 && mSubCarrierSpacing == 15)...
        || (mTransmissionBandWidth == 80 && mSubCarrierSpacing == 15) || (mTransmissionBandWidth == 90 && mSubCarrierSpacing == 15) ||(mTransmissionBandWidth == 100 && mSubCarrierSpacing == 15)
        error('Input Param invalid,No Such Configuration in 3GPP TS38.104!');
    end

    nrBandWidth = [5,10,15,20,25,30,40,50,60,70,80,90,100];   % Mhz
    nrbtable = [25  52 79 106 133 160 216 270 NaN NaN NaN NaN NaN;     % 15 kHz
                11  24 38 51  65  78  106 133 162 189 217 245 273;     % 30 kHz
                NaN 11 18 24  31  38  51  65  79  93 107 121 135];     % 60 kHz

    if mSubCarrierSpacing == 15
        maxRBNum = nrbtable(1,find(mTransmissionBandWidth == nrBandWidth));
    elseif mSubCarrierSpacing == 30
        maxRBNum = nrbtable(2,find(mTransmissionBandWidth == nrBandWidth));  
    else
        maxRBNum = nrbtable(3,find(mTransmissionBandWidth == nrBandWidth)); 
    end
elseif strcmp(mRAT,'LTE')
    if mSubCarrierSpacing ~= 15 || mTransmissionBandWidth > 20
        error('Input Param invalid,No Such Configuration in 3GPP TS36.104!');
    end
    
    lteBandWidth = [1.4,3,5,10,15,20];   % Mhz
    lterbtable = [6,15,25,50,75,100];    % 15 kHz
    maxRBNum = lterbtable(1,find(mTransmissionBandWidth == lteBandWidth));
else
    error('Incorrect RAT configuration!');
end
