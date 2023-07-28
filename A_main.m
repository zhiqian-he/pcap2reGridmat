clear;
clc;
close all;

%===============================================================================================================%
% Notes:                                                                                                        %
%      This funciton can extract the IQ data in pcap file and then convert to RE Grid .mat file                 %
%                                                                                                               %
% Author: Zhiqian He (zhiqian.he@zillnk.com). Feb.2021.                                                         %
% Revision History:                                                                                             %
%    2021/09/19: Creast 1st version                                                                             %
%===============================================================================================================%
%% Input Parameters for pcap2bin
param.pcapfile_name = 'N7N30(B622904230501000010)_1CC for time offset_10ms.pcap';      % The captured pcap file name
param.binfile_name = 'lte_20Mhz.bin';                  % The output bin file name
param.mDestinationMacAddr = '1C:A0:EF:87:62:22';       % Des Mac in pcap file
param.mSourcenMacAddr = '9E:DD:85:CE:03:0D';           % Src Mac in pcap file
param.mVLANTag = 'False';                              % 'True' or 'False'
param.udCompMeth = 'BFP';                              % NoCompression or BFP
param.eAxCID = '4000';                                 % eAxC ID, 16bit, used for filter wanted ethernet frame
param.dataDierection = '1';                            % 1bit, 0 indicate UL, 1 indicate DL
param.ethernetSpeed = '10G';                           % 10G or 25G

%% Input Parameters for test master bin to reGrid .mat file
param.mRAT = 'LTE';                                 % 'NR' or 'LTE'
param.mDuplexMode = 'FDD';                          % 'FDD' or 'NR_3GPP_TDD' or 'LTE_3GPP_TDD'
param.mChannelType = 'PUSCH';                       % 'PUSCH' or 'PRACH_F0' or 'PRACH_B4'
param.mTransmissionBandWidth = 20;                  % unit, Mhz
param.mSubCarrierSpacing = 15;                      % unit, kHz
param.fragFlag = 'False';                           % Application Fragmentation Indication, 'True' or 'False'
param.DU_PortId_bitwidth = 2;                       % DU port ID bitwidth in eAxC ID allocation
param.BandSectorId_bitwidth = 3;                    % BandSector ID bitwidth in eAxC ID allocation
param.CCId_bitwidth = 3;                            % CCID ID bitwidth in eAxC ID allocation
param.RU_PortId_bitwidth = 8;                       % The RU_Port_ID is fixed to 8 bits
param.duPortId = [1];                               % Select the coresponding DU Port Id to do uplink performance analysis,[0,1]
param.bandSectorId = [0];                           % Select the coresponding Band Id to do uplink performance analysis,[0,1,2] 
param.ruPortId = [0];                               % Select the coresponding ruPortId to do uplink performance analysis，[0,1,2,3] or [8,9,10,11]
param.carrierComponentId = [0];                     % Select the coresponding CCId to do uplink performance analysis，[0,1,2,3,4,5]
param = parameterSetting(param);                    % The other parameters are initialized in this function

%% pcap file convert to .mat file
ResourceGridBWP = matFileGeneration(param);

%% Save .mat file
save ResourceGridBWP;
disp(['The output .mat file is ResourceGridBWP.mat in WorkSpace']);
disp(['*********************************************************************************']);

%% Scatterplot
scatterplot(reshape(ResourceGridBWP, [1,length(ResourceGridBWP(:,1))*length(ResourceGridBWP(1,:))]));
