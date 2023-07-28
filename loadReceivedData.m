function [param,receivedData] = loadReceivedData(param)
%==========================================================================
% Function: load the received data and convert to the wanted data format
% Input:
%       param struct
% Output:
%       receivedData with wanted format
%--------------------------------------------------------------------------
%% Input
reNum = param.reNum;
slotNum_per_subFrame = param.slotNum_per_subFrame;
DU_PortId_bitwidth = param.DU_PortId_bitwidth;
BandSectorId_bitwidth = param.BandSectorId_bitwidth;
CCId_bitwidth = param.CCId_bitwidth;
RU_PortId_bitwidth = param.RU_PortId_bitwidth;

%% Load bin file and restore to char type
file_name = param.binfile_name;
fileID = fopen(file_name,'r');

while ~feof(fileID)
      data_Dec = fread(fileID);
end
fclose(fileID);
data_Hex = dec2hex(data_Dec);
data_Hex = data_Hex';          
originalData = data_Hex(:)';

%% Find 10ms Frame Start index in the received data
[param,packetStartIndex,posInpacketStartIndex] = findFrameStartIndex(param,originalData);

%% Loop and Write IQdata to ReGrid
reGrid = zeros(reNum,14*2^param.mu*10,param.bandIdNum,param.ruPortIdNum,param.ccIdNum);  % ReGrid format: total RENum * total symbol Num in 10ms * total Band num * total ruPort num * CC Num

for byteIndIndex = posInpacketStartIndex : length(packetStartIndex)  % The last subframe data may be imcomplete, so the data in last subframe will not be parsed.
    
    % Calculate the total bytes in this packet
    bytes_Hex = originalData(packetStartIndex(byteIndIndex) + 12 : packetStartIndex(byteIndIndex) + 15);
    bytes_Dec = hex2dec(bytes_Hex); 
    
    % Find all the Ethernet Frame header and payload
    ethData = originalData(packetStartIndex(byteIndIndex) + 16 : packetStartIndex(byteIndIndex) + 16 + bytes_Dec * 2 - 1);
    
    % Find eCPRI Message type/ rtcId / subframeId/ slotId/ symbolId/ startPrb/ numPrb
    if strcmp(param.mVLANTag,'True')
       mVLANTagLen = 8;     
    else
        mVLANTagLen = 0;  
    end
    
    % Find eCPRI Message type
    messageType = ethData(31+mVLANTagLen : 32+mVLANTagLen);
    if ~strcmp(messageType,'00')  % 0x00 indicate the U-Plane message
        disp('The packet content are wrong,they are not U-Plane data!');
        param.uplinkSubframeIndex = [];
        param.resultsValidFlag = 0;
    end
    % Find eAxCId bit, totally 16 bit
    eAxCId_dec = hex2dec(ethData(37+mVLANTagLen : 40+mVLANTagLen));
    eAxCId = dec2bin(eAxCId_dec,16);
    
    % DU Port Id
    du_PortId = bin2dec(eAxCId(1:DU_PortId_bitwidth));
    
    % BandSector Id
    bandSectorId = bin2dec(eAxCId(DU_PortId_bitwidth+1 : DU_PortId_bitwidth+BandSectorId_bitwidth));
    
    % CCId
    ccId = bin2dec(eAxCId(DU_PortId_bitwidth+BandSectorId_bitwidth+1 : DU_PortId_bitwidth+BandSectorId_bitwidth+CCId_bitwidth));
    
    % ruPortId
    ruPortId = bin2dec(eAxCId(DU_PortId_bitwidth+BandSectorId_bitwidth+CCId_bitwidth+1 : end)); 
    
    % Find subframeId/ slotId/ symbolId
    subframe_slot_symbol_Id = hex2dec(ethData(49+mVLANTagLen : 52+mVLANTagLen));
    subframe_slot_symbol_Id_bin = dec2bin(subframe_slot_symbol_Id,16);
    subframeId = bin2dec(subframe_slot_symbol_Id_bin(1:4));
    slotId = bin2dec(subframe_slot_symbol_Id_bin(5:10));
    symbolId = bin2dec(subframe_slot_symbol_Id_bin(11:16));

    % Find sectionId/startPrb/ numPrb
    section_rb_symInc_startPrb_numPrb = hex2dec(ethData(53+mVLANTagLen : 60+mVLANTagLen));
    section_rb_symInc_startPrb_numPrb_bin = dec2bin(section_rb_symInc_startPrb_numPrb,32);
    sectionId = bin2dec(section_rb_symInc_startPrb_numPrb_bin(1:12));
    startPrb = bin2dec(section_rb_symInc_startPrb_numPrb_bin(15:24));
    numPrb = bin2dec(section_rb_symInc_startPrb_numPrb_bin(25:32));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % step1: skip those ruPort, CC and Band which is not need to do perofrmance analysis 
    if ruPortId ~= param.ruPortId || ccId ~= param.carrierComponentId || bandSectorId ~= param.bandSectorId || du_PortId ~= param.duPortId
       continue;
    end
    if strcmp(param.mChannelType,'PRACH_F0') || strcmp(param.mChannelType,'PRACH_B4')
       if sectionId ~= param.prachSectionId
          continue;          
       end 
    end
    % step2: skip the ethframe frame which has the same subframeId/slotId/symbolId/sectionId
    %---------------------------------------------------------------------------------------
    if strcmp(param.mChannelType,'PUSCH')
        if startPrb == 0 && numPrb == param.rbNumInEvenFrame
            sectionId = 0;
            if numPrb == 0
               numPrb = param.maxRBNum; 
            end
        elseif startPrb == param.rbNumInEvenFrame && numPrb == param.rbNumInOddFrame
            sectionId = 1;
        else
            error('The startPrb and numPrb is not meet expectations@!');
        end
        if param.reGridFlag(subframeId+1,slotId+1,symbolId+1,sectionId+1,bandSectorId+1,ruPortId+1,ccId+1) == 1       
            continue;
        end
        param.reGridFlag(subframeId+1,slotId+1,symbolId+1,sectionId+1,bandSectorId+1,ruPortId+1,ccId+1) = 1;
    %---------------------------------------------------------------------------------------
    elseif strcmp(param.mChannelType,'PRACH_F0')
       if startPrb == 0 && numPrb == 72
          sectionId = 0; 
       else
          error('The received PRACH F0 startPrb and numPrb is not meet expectations@!'); 
       end
       
        if param.reGridFlag(subframeId+1,slotId+1,symbolId+1,sectionId+1,bandSectorId+1,ruPortId-8+1,ccId+1) == 1   % Default PRACH RU port ID is started from 8
            continue;
        end
        param.reGridFlag(subframeId+1,slotId+1,symbolId+1,sectionId+1,bandSectorId+1,ruPortId-8+1,ccId+1) = 1;
    %---------------------------------------------------------------------------------------
    elseif strcmp(param.mChannelType,'PRACH_B4')
       if startPrb == 0 && numPrb == 12
          sectionId = 0; 
       else
          error('The received PRACH B4 startPrb and numPrb is not meet expectations@!'); 
       end
       
        if param.reGridFlag(subframeId+1,slotId+1,symbolId+1,sectionId+1,bandSectorId+1,ruPortId-8+1,ccId+1) == 1   % Default PRACH RU port ID is started from 8
            continue;
        end
        param.reGridFlag(subframeId+1,slotId+1,symbolId+1,sectionId+1,bandSectorId+1,ruPortId-8+1,ccId+1) = 1;        
    else
        error('Only Support PUSCH and PRACH_F0/B4 analysis at this stage@!');  
    end
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
   % Find IQ data and convert them to complex data
   iqData_complex = rcvIQDataParsingFromBinFile(param,ethData,mVLANTagLen,numPrb);
   
   % Fill IQ data in REGrid matrix 
   symbolNum = (subframeId*slotNum_per_subFrame + slotId)*14 + symbolId + 1;
   if symbolNum > 14*2^param.mu*10
      error('The calculated symbol number exceed the 10ms Frame total symbol numbers@!'); 
   end
   %---------------------------------------------------------------------------------------
   if strcmp(param.mChannelType,'PUSCH')
      reGrid(startPrb*12+1:(startPrb+numPrb)*12,symbolNum,bandSectorId+1,ruPortId+1,ccId+1) = iqData_complex.';
   %---------------------------------------------------------------------------------------
   elseif strcmp(param.mChannelType,'PRACH_F0') || strcmp(param.mChannelType,'PRACH_B4')
      reGrid(startPrb*12+1:(startPrb+numPrb)*12,symbolNum,bandSectorId+1,ruPortId-8+1,ccId+1) = iqData_complex.';  % Default PRACH RU port ID is started from 8
   %---------------------------------------------------------------------------------------
    else
        error('Only Support PUSCH and PRACH_F0/B4 analysis at this stage@!');  
   end
   %---------------------------------------------------------------------------------------
end
param.rcvReGrid = reGrid;

%% Output
symbolInEachSlot = 14;
receivedData = zeros(10,reNum*symbolInEachSlot);
if strcmp(param.mChannelType,'PUSCH')
   ruPortIndex = param.ruPortId+1;
else
   ruPortIndex = param.ruPortId-8+1;   % Default PRACH RU port ID is started from 8
end

for slotIndex = 1:param.slotNum_per_Frame
    receivedData_tmp = zeros(1,reNum*symbolInEachSlot);
    for symbolIndex = (slotIndex - 1) * symbolInEachSlot + 1 : slotIndex * symbolInEachSlot
        symbolIndex_tmp = symbolIndex - ((slotIndex - 1) * symbolInEachSlot);
        receivedData_tmp(1,(symbolIndex_tmp-1)*reNum + 1 : symbolIndex_tmp * reNum) = reGrid(:,symbolIndex,param.bandSectorId+1,ruPortIndex,param.carrierComponentId+1).'; 
    end
    receivedData(slotIndex,:) = receivedData_tmp;  % The receivedData should be 1ms, the format shall be N x length(receivedData);
end
