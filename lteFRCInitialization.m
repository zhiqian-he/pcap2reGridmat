function param = lteFRCInitialization(param)
%==========================================================================
% Function: LTE FRC parameters initialization
% Input:
%       param struct
% Output:
%       Initialized param struct
%--------------------------------------------------------------------------
if strcmp(param.testPurpose,'Sensitivity')
    param.DFT_S_OFDMSymbolNum = 12;
    param.dmrsSymbolIndex = [4,11];        
    param.dmrsFreqIndex = [1,2,3,4,5,6,7,8,9,10,11,12];
    param.mModType = 'QPSK';
    param.modOrder = 2;
    param.startRbNum = 1;
    param.eQualizationMethod = 'MMSE';        % 'LS' or 'MMSE'

    %% UL FRC Setting for UL Sensitivity (QPSK)
    if param.mTransmissionBandWidth == 20 || param.mTransmissionBandWidth == 15 || param.mTransmissionBandWidth == 10 || param.mTransmissionBandWidth == 5
       param.referenceChannel = 'A1-3';    % the reference sensitivity level is -101.5dBm
       param.rbNum = 25;
       param.mpayLoadSize = 2216; % Transport block length, positive integer
       param.totalBitPerSlot = 7200/2;
       param.localData_name = strcat('ZG_FRC_A1_3_LTE_',num2str(param.mTransmissionBandWidth),'Mhz_',num2str(param.mSubCarrierSpacing),'Khz','.mat'); % Local Known IQ data RE Grid
       resourceGrid = load(param.localData_name);
    elseif param.mTransmissionBandWidth == 3
       param.referenceChannel = 'A1-2';    % the reference sensitivity level is -103dBm
       param.rbNum = 15;
       param.mpayLoadSize = 1544; % Transport block length, positive integer
       param.totalBitPerSlot = 4320/2;
       param.localData_name = strcat('ZG_FRC_A1_2_LTE_',num2str(param.mTransmissionBandWidth),'Mhz_',num2str(param.mSubCarrierSpacing),'Khz','.mat'); % Local Known IQ data RE Grid
       resourceGrid = load(param.localData_name);       
    else
       error('The mTransmissionBandWidth is not supported so far!');
    end

elseif strcmp(param.testPurpose,'Performance')
    param.DFT_S_OFDMSymbolNum = 12;
    param.dmrsSymbolIndex = [4,11];        
    param.dmrsFreqIndex = [1,2,3,4,5,6,7,8,9,10,11,12];
    param.mModType = '64QAM';
    param.modOrder = 6;
    param.rbNum = param.maxRBNum;
    param.startRbNum = 1;
    param.eQualizationMethod = 'MMSE';        % 'LS' or 'MMSE' 

    %% UL FRC Setting for UL Performance (64QAM)
    if param.mTransmissionBandWidth == 20
       param.localData_name = strcat('ZG_FRC_A5_7_LTE_',num2str(param.mTransmissionBandWidth),'Mhz_',num2str(param.mSubCarrierSpacing),'Khz','.mat'); % Local Known IQ data RE Grid
       param.referenceChannel = 'A5-7';
       param.mpayLoadSize = 75376;
    elseif param.mTransmissionBandWidth == 15
       param.localData_name = strcat('ZG_FRC_A5_6_LTE_',num2str(param.mTransmissionBandWidth),'Mhz_',num2str(param.mSubCarrierSpacing),'Khz','.mat');
       param.referenceChannel = 'A5-6';
       param.mpayLoadSize = 55056;
    elseif param.mTransmissionBandWidth == 10
       param.localData_name = strcat('ZG_FRC_A5_5_LTE_',num2str(param.mTransmissionBandWidth),'Mhz_',num2str(param.mSubCarrierSpacing),'Khz','.mat');
       param.referenceChannel = 'A5-5';
       param.mpayLoadSize = 36696;
    elseif param.mTransmissionBandWidth == 5
       param.localData_name = strcat('ZG_FRC_A5_4_LTE_',num2str(param.mTransmissionBandWidth),'Mhz_',num2str(param.mSubCarrierSpacing),'Khz','.mat');
       param.referenceChannel = 'A5-4';
       param.mpayLoadSize = 18336;
    elseif param.mTransmissionBandWidth == 3
       param.localData_name = strcat('ZG_FRC_A5_3_LTE_',num2str(param.mTransmissionBandWidth),'Mhz_',num2str(param.mSubCarrierSpacing),'Khz','.mat');
       param.referenceChannel = 'A5-3';
       param.mpayLoadSize = 11064;
    elseif param.mTransmissionBandWidth == 1.4
       param.localData_name = strcat('ZG_FRC_A5_2_LTE_1Dot4Mhz_',num2str(param.mSubCarrierSpacing),'Khz','.mat');
       param.referenceChannel = 'A5-2';
       param.mpayLoadSize = 4392;
    else
       error('The mTransmissionBandWidth is not supported so far,if you want to test more in-channel-selectivity case,please contact author!');
    end
    resourceGrid = load(param.localData_name);

elseif strcmp(param.testPurpose,'in-channel-selectivity')
    param.DFT_S_OFDMSymbolNum = 12;
    param.dmrsSymbolIndex = [4,11];        
    param.dmrsFreqIndex = [1,2,3,4,5,6,7,8,9,10,11,12];
    param.mModType = 'QPSK';
    param.modOrder = 2;
    param.startRbNum = 1;
    param.eQualizationMethod = 'MMSE';        % 'LS' or 'MMSE' 
    
    if param.mTransmissionBandWidth == 3
       param.localData_name = strcat('ZG_FRC_A1_5_LTE_',num2str(param.mTransmissionBandWidth),'Mhz_',num2str(param.mSubCarrierSpacing),'Khz','.mat');
       param.referenceChannel = 'A1-5';
       param.rbNum = 9;
       param.mpayLoadSize = 936;
    elseif param.mTransmissionBandWidth == 5
       param.localData_name = strcat('ZG_FRC_A1_2_LTE_',num2str(param.mTransmissionBandWidth),'Mhz_',num2str(param.mSubCarrierSpacing),'Khz','.mat');
       param.referenceChannel = 'A1-2';
       param.rbNum = 15;
       param.mpayLoadSize = 1544; % Transport block length, positive integer
       param.totalBitPerSlot = 4320/2;
    else
       error('The mTransmissionBandWidth is not supported so far,if you want to test more in-channel-selectivity case,please contact author!');
    end
    resourceGrid = load(param.localData_name); 

else
   error('param.testPurpose in A_main function setting is Wrong@! '); 
end
param.reGrid = resourceGrid.ResourceGridBWP;
