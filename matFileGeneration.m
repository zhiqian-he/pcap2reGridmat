function ResourceGridBWP = matFileGeneration(param)

%% pcap file convert to test master bin file
ethFrameOut_10ms = pcap2bin(param);

%% Write data to bin file
testMasterFile_str = ethFrameOut_10ms;
dec_strSymbol = zeros(1,length(testMasterFile_str)/4);
for loopIndex = 1:length(testMasterFile_str)/4  % In testMasterFile_str, 4 string symbol indicate 16bit = 2byte   
    strSymbol = testMasterFile_str((loopIndex-1)*4 + 1:loopIndex*4);
    dec_strSymbol(loopIndex) = hex2dec(strSymbol);
end
disp(['*********************************************************************************']);
disp(['Note: The original pcap file suffix has been changed from .pcap to .bin']);
disp(['The output test master bin file is: ',param.binfile_name]);
fileID = fopen(param.binfile_name,'wb');
fwrite(fileID, swapbytes(uint16(dec_strSymbol)), 'uint16'); 
fclose(fileID);

%% Load Uplink Received Data
[param,receivedData] = loadReceivedData(param);

%% Loop all the received subframe data
uplinkSlotIndex = param.uplinkSlotIndex;
for slotIndex = 1:length(uplinkSlotIndex)
    %% PUSCH Channel Analysis
    [normalizedData,pwr_dBfs,pwr_dBm] = receivedDataPwrNormalization(param,receivedData(uplinkSlotIndex(slotIndex),:));
    param.normalizedData(:,:,slotIndex) = normalizedData;
    param.pwr_dBfs(:,slotIndex) = pwr_dBfs;
    param.pwr_dBm(:,slotIndex) = pwr_dBm;
end

%% Save Data
ResourceGridBWP = [];
[x,y,slotNum] = size(normalizedData);
for index = 1:slotNum
   ResourceGridBWP = [ResourceGridBWP,normalizedData(:,:,index)];
end