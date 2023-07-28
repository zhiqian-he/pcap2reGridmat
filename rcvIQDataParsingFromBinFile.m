function iqData_complex = rcvIQDataParsingFromBinFile(param,ethData,mVLANTagLen,numPrb)
%==========================================================================
% Function: Parsing the origianl complex signal from received Bin file
% Input:
%       param struct
%       ethData：received ethernet data including header and IQ data
%       mVLANTagLen: VLAN Tag Length
%       numPrb:The number of PRB in the received ethernet data
% Output:
%       iqData in each ethernet frame with complex format
%--------------------------------------------------------------------------
%% Input
udCompMeth = param.udCompMeth;
% udCompHdLen = param.udCompHdLen;

%% IQ data parsing
% IQData_Hex = ethData(61+mVLANTagLen+udCompHdLen : end);
IQData_Hex = ethData(61+mVLANTagLen : end);

if strcmp(udCompMeth,'NoCompression')
    iqData = zeros(1,length(IQData_Hex)/4);
    for iqDataIdx = 1:length(IQData_Hex)/4 
       iqData_hex = IQData_Hex((iqDataIdx-1)*4+1 : iqDataIdx*4);
       iqData_dec = hex2dec(iqData_hex);
       if(iqData_dec > 2^15-1)         % dec data sign is negative
          iqData(iqDataIdx) = iqData_dec - 2^16;
       else 
          iqData(iqDataIdx) = iqData_dec;  
       end
    end
elseif strcmp(udCompMeth,'BFP')
    iqData = rcvIQDataDecompression(param,IQData_Hex,numPrb);
else
    error('No such Compression Mehthod or the Compression Method is not supported so far@!');
end

%% Output
iqData_complex = zeros(1,length(iqData)/2);
for len = 1:length(iqData)/2 
   iqData_complex(len) = iqData((len-1)*2 + 1) + 1j * iqData(len*2);
end