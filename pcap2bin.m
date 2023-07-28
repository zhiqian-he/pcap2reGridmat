function ethFrameOut_10ms = pcap2bin(param)

%% Load pcap file
% Get pcap files in the current folder
files = dir(param.pcapfile_name);
% Loop through each file 
for id = 1:length(files)
    % Get the file name 
    [~, f,ext] = fileparts(files(id).name);
    % change the extension
    rename = strcat(f,'.bin') ; 
    movefile(files(id).name, rename); 
end
fileID = fopen(rename,'r');

while ~feof(fileID)
      data_Dec = fread(fileID);
end
fclose(fileID);
data_Hex = dec2hex(data_Dec);
data_Hex = data_Hex';          
originalData = data_Hex(:)';

%% Test Master File Format
if strcmp(param.ethernetSpeed,'10G')
    param.testMasterFileLen = 1562500 * 16;  % Totally 10ms data, row num = 1562500, each row contain 64bit = 8 bytes.
    param.guardClock = 16;
    testMasterFile = load('testMasterFile_str_10G.mat');
elseif strcmp(param.ethernetSpeed,'25G')
    param.testMasterFileLen = 3906250 * 16;
    param.guardClock = 32;
    testMasterFile = load('testMasterFile_str_25G.mat');
else
    error('Invalid Parameter for ethernetSpeed!');
end

%% Find Each Ethernet Frame Start Index
newstrDmac = erase(param.mDestinationMacAddr,":");
newstrRmac = erase(param.mSourcenMacAddr,":");
macStrcat = [newstrDmac,newstrRmac];

packetStartIndex = [];
firstChar = newstrDmac(1);
for index = 1: length(originalData) - 23    % 23 equal to length of (macStrcat)-1
    if strcmp(originalData(index),firstChar)
        if strcmp(originalData(index+1:index+23),macStrcat(2:end))
           packetStartIndex = [packetStartIndex,index];
        end
    end
end

%% Extract Ethernet Frame and Generate Test Master Frame
ethFrameOut_10ms = testMasterFile.testMasterFile_str;    % 10ms test master file initialization;
start_offset = 0;                                        % The start index to write eth frame data   
for byteIndIndex = 1: length(packetStartIndex)
    % Find first useful Ethernet Frame
    ethData = originalData(packetStartIndex(byteIndIndex):end);
    
    % VLAN Tag Length
    if strcmp(param.mVLANTag,'True')
       mVLANTagLen = 8;     
    else
       mVLANTagLen = 0;  
    end

    % Find eCPRI Message type
    messageType = ethData(24+mVLANTagLen+1 : 28+mVLANTagLen);
    if ~strcmp(messageType,'AEFE')   % 0xAEFE indicate eCPRI message
        disp('The packet are NOT ecpri message@!');
        break;
    end    
    
    % Find Ethernet Frame Type 
    messageType = ethData(30+mVLANTagLen+1 : 32+mVLANTagLen);
    
    if strcmp(messageType,'00')  % 0x00 indicate the U-Plane message
       ethFrameType = 'U_Plane';
    elseif strcmp(messageType,'02')  % 0x02 indicate the C-Plane message
       ethFrameType = 'C_Plane';
    else
        error('Unknow messageType@!');
    end
    
    % Paysize
    payloadSizeHex = ethData(32+mVLANTagLen+1 : 36+mVLANTagLen);
    payloadSizeDec = hex2dec(payloadSizeHex);
    
    ethFrameData = ethData(36+mVLANTagLen+1 : 36+mVLANTagLen+payloadSizeDec*2);

    % eAxC ID
    eAxCID = ethData(36+mVLANTagLen+1 : 40+mVLANTagLen);

    % data direction
    dataDierection_hex = ethData(44+mVLANTagLen+1);
    dataDierection_dec = hex2dec(dataDierection_hex);
    dataDierection_bin = dec2bin(dataDierection_dec,4);
    dataDierection = dataDierection_bin(1);

    %% U-Plane data
     if strcmp(ethFrameType,'U_Plane') && strcmp(eAxCID,param.eAxCID) && strcmp(dataDierection,param.dataDierection)
        % Valid Ethernet Frame Length
        if strcmp(param.mVLANTag,'True')
            mTransPortHdLen = 36;     
        else
            mTransPortHdLen = 28;  
        end
        eCPRICommonHdLen = 8;
        eCPRIpayLoadLen = payloadSizeDec;        
        % Add test master header
        ethFrameLength = mTransPortHdLen + eCPRICommonHdLen + eCPRIpayLoadLen*2;
        totalByte_dec = ethFrameLength/2;
        totalByte_hex = dec2hex(totalByte_dec,4);
        mtestMasterHd = ['AABBCCDDEEFF',totalByte_hex];
        % Generate test master frame
        ethData = originalData(packetStartIndex(byteIndIndex) : packetStartIndex(byteIndIndex)+ethFrameLength-1);
        ethFrameOut = [mtestMasterHd,ethData];
        % Write ethFrameOut_10ms
        if start_offset + length(ethFrameOut) - 1 >= length(ethFrameOut_10ms)
           break; 
        end
        ethFrameOut_10ms(start_offset+1 : (start_offset + length(ethFrameOut))) = ethFrameOut;
        start_offset = start_offset + length(ethFrameOut);
     end
end
