function param = parameterSetting(param)
%==========================================================================
% Function: Input parameters initialization
% Input:
%       param struct
% Output:
%       Initialized param struct
%--------------------------------------------------------------------------
%% 3GPP Param
param.maxRBNum = getmaxRBNum(param);

if param.mSubCarrierSpacing == 15
    param.mu = 0;
elseif param.mSubCarrierSpacing == 30
    param.mu = 1;
else
    param.mu = 2;
end

param.slotNum_per_subFrame = 2^param.mu;
reNum = param.maxRBNum * 12;
if strcmp(param.mChannelType,'PUSCH')
   param.reNum = reNum; 
elseif strcmp(param.mChannelType,'PRACH_F0')
   param.reNum = 72 * 12;  % PRACH F0, RB number = 72
   param.prachScs = 1.25;  % Unit, Khz
elseif strcmp(param.mChannelType,'PRACH_B4')
   param.reNum = 12 * 12;  % PRACH B4, RB number = 12
   param.prachScs = param.mSubCarrierSpacing;  % Unit, Khz
else
   error('Only Support PUSCH and PRACH_F0/B4 analysis at this stage@!');
end

param.slotNum_per_Frame = 10*2^param.mu;
param.symbolNum = param.slotNum_per_Frame * 14;
param.iFFTPoints = power(2,ceil(log2(param.maxRBNum*12/0.85)));
param.iFFTPoints = max(128,param.iFFTPoints);

% LTE and NR UL TA unit calculation
param.Ts = 1/2048/15000 * 10^6;   % LTE sample unit,us (microseconds)
param.Tc = 1/4096/480000 * 10^6;  % NR sample unit,us (microseconds)
if strcmp(param.mRAT,'NR')
   param.UL_TA_unit = 16*64/2^param.mu*param.Tc;  % unit,us (microseconds)
else
   param.UL_TA_unit = 16*param.Ts;                % unit,us (microseconds)    
end

%% Local IQ data grid folder path Setting
addpath(genpath('LocalIQdataGrid'));
param.testPurpose = 'Sensitivity';                  % 'Sensitivity' or 'Performance' or 'in-channel-selectivity'; 'Sensitivity' and 'in-channel-selectivity' = QPSK, 'Performance' = 64QAM 
param.constellationSymbBySymb = 'True';             % Show constellation symbol by symbol, mainly for debug, 'True' or 'False'
param.timeDomainSignalDisplay = 'False';            % Display Received Time Domain Signal, mainly for debug, 'True' or 'False'

%% eAxC Id bit Allocation
if param.mTransmissionBandWidth > 60
    param.ruPortIdNum = 4;
    param.ccIdNum = 2;
    param.bandIdNum = 2;
else
    param.ruPortIdNum = 4;                              % The contained ruPortId number in the received data
    param.ccIdNum = 2^param.CCId_bitwidth;              % The contained CCId number in the received data
    param.bandIdNum = 2^param.BandSectorId_bitwidth;     % The contained BandSectorId number in the received data
end

if param.bandIdNum > 2^param.BandSectorId_bitwidth
   error('The BandSector Bit allocation is not matched with bandSectorId setting@!');
end
if param.ccIdNum > 2^param.CCId_bitwidth
   error('The CCID Bit allocation is not matched with Carrier Number Setting@!');
end

%% TDD Slot Setting
if strcmp(param.mDuplexMode,'NR_3GPP_TDD') && param.mSubCarrierSpacing == 30
    % Default TDD Configuration based on NR TDD Test Mode in 3GPP
    param.transmissionPeriod = 5;          % 2.5->2.5ms; 5->5ms; 10->10 ms
    param.nrofDownlinkSlots = 7;
    param.nrofDownlinkSymbols = 6; 
    param.nrofUplinkSymbols = 4;
    param.nrofUplinkSlots = 2;
elseif strcmp(param.mDuplexMode,'NR_3GPP_TDD') && param.mSubCarrierSpacing == 60
    % Default TDD Configuration based on NR TDD Test Mode in 3GPP
    % Note: The standared TDD Configuration for 60Khz is {14,12,8,4},To simplify process,we set {15,0,8,4} here. 
    param.transmissionPeriod = 5;          % 5->5ms; 
    param.nrofDownlinkSlots = 15;
    param.nrofDownlinkSymbols = 0; 
    param.nrofUplinkSymbols = 8;
    param.nrofUplinkSlots = 4;
elseif strcmp(param.mDuplexMode,'NR_3GPP_TDD') && param.mSubCarrierSpacing == 15
    % Default TDD Configuration based on NR TDD Test Mode in 3GPP
    param.transmissionPeriod = 5;          % 5->5ms; 
    param.nrofDownlinkSlots = 3;
    param.nrofDownlinkSymbols = 10; 
    param.nrofUplinkSymbols = 2;
    param.nrofUplinkSlots = 1; 
elseif strcmp(param.mDuplexMode,'LTE_3GPP_TDD')
    % Default TDD Configuration based on LTE TDD Test Mode in 3GPP, DSUUUDDDDD
    param.transmissionPeriod = 10;         %  10->10 ms
    param.nrofDownlinkSlots = 1;
    param.nrofDownlinkSymbols = 11; 
    param.nrofUplinkSymbols = 2;
    param.nrofUplinkSlots = 3;
else
    param.transmissionPeriod = 10;         
    param.nrofDownlinkSlots = 10*2^param.mu;
    param.nrofDownlinkSymbols = 14; 
    param.nrofUplinkSymbols = 0;
    param.nrofUplinkSlots = 0;
end

param = tddSlotAndSubframeConfig(param);

%% NR Wide Area BS Reference Measurement Channel
if strcmp(param.mRAT,'NR')
   param = nrFRCInitialization(param);
elseif strcmp(param.mRAT,'LTE')
   param = lteFRCInitialization(param); 
else
   error('mRAT setting is wrong@!'); 
end

%% Uplink Data Compression
udCompMeth = param.udCompMeth;               % 'NoCompression' or 'BFP'
if strcmp(udCompMeth,'NoCompression')
   param.iqDataBitWidth = 16;
   param.compParam = 0;
   param.udCompHdLen = 0;
else
   param.iqDataBitWidth = 9;                 % support BFP9 and BFP8 compression(I_9/8bit + Q_9/8bit + exponent_4 bit) at so far.
   param.compParam = 8;                      % including 4 bit reserved bit
   param.udCompHdLen = 4;                    % two bytes udCompHeader
end

%% Uplink Performance Analysis Parameters
param = ruULGainInit(param);
param.pwrStatisticalSamples = 12*param.maxRBNum;      % Power Meter Statistic Samples
param.lowPassFilter = 'False';                        % received data filter or not
param.CRC_results = [];                               % CRC results initialization

if strcmp(param.fragFlag,'True') &&  param.maxRBNum > 137
    param.rbNumInEvenFrame = 137;                     % 137 RB is Hardcoded                 
    param.rbNumInOddFrame = param.maxRBNum - 137;
    param.sectionNum = 2;
elseif strcmp(param.fragFlag,'False') &&  param.maxRBNum > 255 
    param.rbNumInEvenFrame = 0;
    param.rbNumInOddFrame = 0;
    param.sectionNum = 1;
else
    param.rbNumInEvenFrame = param.maxRBNum;
    param.rbNumInOddFrame = 0;
    param.sectionNum = 1;
end

param.reGridFlag(10,10*2^param.mu,14,param.sectionNum,param.bandIdNum,param.ruPortIdNum,param.ccIdNum) = 0;          % subframeId/slotId/symbolId/sectionId/bandId/ruPortId/CCID
param.resultsValidFlag = 1;                        
