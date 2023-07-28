function param = nrFRCInitialization(param)
%==========================================================================
% Function: NR FRC parameters initialization
% Input:
%       param struct
% Output:
%       Initialized param struct
%--------------------------------------------------------------------------
if strcmp(param.testPurpose,'Sensitivity')
    param.cpOFDMSymbolNum = 12;
    param.dmrsSymbolIndex = [3,12];        
    param.dmrsFreqIndex = [1,3,5,7,9,11];
    param.mModType = 'QPSK';
    param.modOrder = 2;
    param.rate = 308/1024;       % Target code rate, 0<R<1
    param.rv = 0;                % Redundancy version, 0-3
    param.nlayers = 1;           % Number of layers, 1-4 for a transport block 
    param.eQualizationMethod = 'MMSE';        % 'LS' or 'MMSE'

    %% UL FRC Setting
    if param.mSubCarrierSpacing == 30
        if (param.mTransmissionBandWidth >=20) && (param.mTransmissionBandWidth <=100)
            param.referenceChannel = 'G-FR1-A1-5';  % the reference sensitivity level is -95.6dBm
            param.rbNum = 51;
            param.startRbNum = 1;
            param.mpayLoadSize = 4352; % Transport block length, positive integer
            param.totalBitPerSlot = 14688;
            param.localData_name = strcat('ZG_FR1_A1_5_NR_',num2str(param.mTransmissionBandWidth),'Mhz_',num2str(param.mSubCarrierSpacing),'Khz','.mat'); % Local Known IQ data RE Grid
            resourceGrid = load(param.localData_name);
        elseif param.mTransmissionBandWidth == 15 || param.mTransmissionBandWidth == 10 || param.mTransmissionBandWidth == 5
            param.referenceChannel = 'G-FR1-A1-2';  % the reference sensitivity level is -101.8dBm
            param.rbNum = 11;
            param.startRbNum = 1;
            param.mpayLoadSize = 984; % Transport block length, positive integer
            param.totalBitPerSlot = 3168;
            param.localData_name = strcat('ZG_FR1_A1_2_NR_',num2str(param.mTransmissionBandWidth),'Mhz_',num2str(param.mSubCarrierSpacing),'Khz','.mat'); % Local Known IQ data RE Grid  
            resourceGrid = load(param.localData_name);
        else
            error('Wrong mTransmissionBandWidth Setting@!');
        end  
    elseif param.mSubCarrierSpacing == 60 
        if (param.mTransmissionBandWidth >=20) && (param.mTransmissionBandWidth <=100)
            param.referenceChannel = 'G-FR1-A1-6';  % the reference sensitivity level is -101.8dBm
            param.rbNum = 24;
            param.startRbNum = 1;
            param.mpayLoadSize = 2088; % Transport block length, positive integer
            param.totalBitPerSlot = 6912;
            param.localData_name = strcat('ZG_FR1_A1_6_NR_',num2str(param.mTransmissionBandWidth),'Mhz_',num2str(param.mSubCarrierSpacing),'Khz','.mat'); % Local Known IQ data RE Grid  
            resourceGrid = load(param.localData_name);
        elseif param.mTransmissionBandWidth == 15 || param.mTransmissionBandWidth == 10       
            param.referenceChannel = 'G-FR1-A1-3';  % the reference sensitivity level is -101.8dBm
            param.rbNum = 11;
            param.startRbNum = 1;
            param.mpayLoadSize = 984; % Transport block length, positive integer
            param.totalBitPerSlot = 3168;
            param.localData_name = strcat('ZG_FR1_A1_3_NR_',num2str(param.mTransmissionBandWidth),'Mhz_',num2str(param.mSubCarrierSpacing),'Khz','.mat'); % Local Known IQ data RE Grid  
            resourceGrid = load(param.localData_name);   
        else
            error('Wrong mTransmissionBandWidth Setting@!');
        end
    elseif  param.mSubCarrierSpacing == 15   
        if param.mTransmissionBandWidth == 15 || param.mTransmissionBandWidth == 10 || param.mTransmissionBandWidth == 5
           param.referenceChannel = 'G-FR1-A1-1';  % the reference sensitivity level is -101.8dBm
           param.rbNum = 25;
           param.startRbNum = 1;
           param.mpayLoadSize = 2152; % Transport block length, positive integer
           param.totalBitPerSlot = 7200;
           param.localData_name = strcat('ZG_FR1_A1_1_NR_',num2str(param.mTransmissionBandWidth),'Mhz_',num2str(param.mSubCarrierSpacing),'Khz','.mat'); % Local Known IQ data RE Grid  
           resourceGrid = load(param.localData_name);  
        elseif param.mTransmissionBandWidth >= 20 && param.mTransmissionBandWidth <= 50
           param.referenceChannel = 'G-FR1-A1-4';  % the reference sensitivity level is -101.8dBm
           param.rbNum = 106;
           param.startRbNum = 1;
           param.mpayLoadSize = 9224; % Transport block length, positive integer
           param.totalBitPerSlot = 30528;
           param.localData_name = strcat('ZG_FR1_A1_4_NR_',num2str(param.mTransmissionBandWidth),'Mhz_',num2str(param.mSubCarrierSpacing),'Khz','.mat'); % Local Known IQ data RE Grid  
           resourceGrid = load(param.localData_name);     
        else
           error('Wrong mTransmissionBandWidth Setting@!'); 
        end   
    else
        error('Wrong mSubCarrierSpacing Setting@!');
    end

elseif strcmp(param.testPurpose,'Performance')    
   error('NR does NOT support UL Performance test(64QAM) so far,if you want to do so,please contact author! ');

elseif strcmp(param.testPurpose,'in-channel-selectivity') 
    param.cpOFDMSymbolNum = 12;
    param.dmrsSymbolIndex = [3,12];        
    param.dmrsFreqIndex = [1,3,5,7,9,11];
    param.mModType = 'QPSK';
    param.modOrder = 2;
    param.rate = 308/1024;       % Target code rate, 0<R<1
    param.rv = 0;                % Redundancy version, 0-3
    param.nlayers = 1;           % Number of layers, 1-4 for a transport block 
    param.eQualizationMethod = 'MMSE';        % 'LS' or 'MMSE'

    %% UL FRC Setting
    if param.mTransmissionBandWidth == 5 && param.mSubCarrierSpacing == 15
        param.referenceChannel = 'G-FR1-A1-7';
        param.rbNum = 15;
        param.startRbNum = 1;
        param.mpayLoadSize = 1320; % Transport block length, positive integer
        param.totalBitPerSlot = 4320;
        param.localData_name = strcat('ZG_FR1_A1_7_NR_',num2str(param.mTransmissionBandWidth),'Mhz_',num2str(param.mSubCarrierSpacing),'Khz','.mat'); % Local Known IQ data RE Grid
        resourceGrid = load(param.localData_name);
    elseif param.mTransmissionBandWidth == 5 && param.mSubCarrierSpacing == 30
        param.referenceChannel = 'G-FR1-A1-8';
        param.rbNum = 6;
        param.startRbNum = 1;
        param.mpayLoadSize = 528; % Transport block length, positive integer
        param.totalBitPerSlot = 1728;
        param.localData_name = strcat('ZG_FR1_A1_8_NR_',num2str(param.mTransmissionBandWidth),'Mhz_',num2str(param.mSubCarrierSpacing),'Khz','.mat'); % Local Known IQ data RE Grid
        resourceGrid = load(param.localData_name);   
    else
        error('The mTransmissionBandWidth is not supported so far,if you want to test more in-channel-selectivity case,please contact author!');
    end

else
   error('param.testPurpose in A_main function setting is Wrong@! '); 
end    
param.reGrid = resourceGrid.ResourceGridBWP;