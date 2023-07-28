function [param,packetStartIndex,posInpacketStartIndex] = findFrameStartIndex(param,originalData)
%==========================================================================
% Function: Find the 10ms Frame Start index in the received data
% Input:
%       param struct
%       originalData: The received bin data
% Output:
%       packetStartIndex: The total packetStartIndex in the received data
%       posInpacketStartIndex: The 10ms Frame start index in packetStartIndex
%--------------------------------------------------------------------------
frameStartIndex = 0;
posInpacketStartIndex = 0;

%% Find all test master header index
packetStartIndex = [];
for index = 1: length(originalData) - 11  % 11 equal to length of 'ABBCCDDEEFF'
    if strcmp(originalData(index),'A')
        if strcmp(originalData(index+1:index+11),'ABBCCDDEEFF')
           packetStartIndex = [packetStartIndex,index];
        end
    end
end

%% Find the frameStartIndex
for byteIndIndex = 1: length(packetStartIndex)
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
        frameStartIndex = 0;
        posInpacketStartIndex = 0;
        break;
    end
    
    frameStartIndex = packetStartIndex(byteIndIndex); 
    posInpacketStartIndex = byteIndIndex;
   
    if frameStartIndex ~=0
       break; 
    end  
end

if frameStartIndex == 0 || posInpacketStartIndex == 0
    disp('Cannot find valid Frame Indicator in the received data!');
    posInpacketStartIndex = length(packetStartIndex);
end
