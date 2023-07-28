function iqData = rcvIQDataDecompression(param,IQData_Hex,numPrb)
%==========================================================================
% Function: Decompress the received IQ data
% Input:
%       param struct
%       IQData_Hex：received ethernet data in Hex
%       numPrb:The number of PRB in the received ethernet data
% Output:
%       iqData: the decompressed iqData
%--------------------------------------------------------------------------

%% Input
iqDataBitWidth = param.iqDataBitWidth;
compParam = param.compParam;

%% Decompression
% Covert the received data to bit
iqData_bin = [];
q = quantizer('fixed',[16 0]);
for iqDataIdx = 1:floor(length(IQData_Hex)/4) 
    iqData_hex = IQData_Hex((iqDataIdx-1)*4+1 : iqDataIdx*4);
    iqData_bin_tmp = hex2bin(q,iqData_hex);
    iqData_bin = [iqData_bin,iqData_bin_tmp];  % The total IQ bit of each Ethernet Frame 
end

if mod(length(IQData_Hex),4) ~=0
    % Special process those data which cannot be divided by 4, the last one byte data
    q = quantizer('fixed',[mod(length(IQData_Hex),4)*4 0]);
    iqData_hex = IQData_Hex(end-mod(length(IQData_Hex),4)+1 : end);
    iqData_bin_tmp = hex2bin(q,iqData_hex);
    iqData_bin = [iqData_bin,iqData_bin_tmp];  % The total IQ bit of each Ethernet Frame 
end

% Loop each PRB
bitNumPerPRB = compParam + 12 * 2 * iqDataBitWidth;
for rbIndex = 1:numPrb
    % Get the bit of each PRB
    iqData_bin_eachPRB = iqData_bin((rbIndex-1)*bitNumPerPRB+1: rbIndex*bitNumPerPRB);
    exponent_bin = iqData_bin_eachPRB(5:8);
    exponent_dec = bin2dec(exponent_bin);
    scaler = 2^exponent_dec;
    iqStartOffset = 8;
    
    % Decompression the IQ data based on calculated exponent_dec
    for reIndex = 1:12
       I_data_bin = iqData_bin_eachPRB((reIndex-1)*iqDataBitWidth*2+1+iqStartOffset : (reIndex-1)*iqDataBitWidth*2+iqDataBitWidth+iqStartOffset);
       Q_data_bin = iqData_bin_eachPRB((reIndex-1)*iqDataBitWidth*2+iqDataBitWidth+1+iqStartOffset : (reIndex-1)*iqDataBitWidth*2+iqDataBitWidth*2+iqStartOffset);
       
       I_data_dec = bin2dec(I_data_bin);
       Q_data_dec = bin2dec(Q_data_bin);
       
       if(I_data_dec > 2^(iqDataBitWidth-1)-1)  % dec data sign is negative       
          I_data = (I_data_dec - 2^iqDataBitWidth)*scaler;
       else
          I_data = I_data_dec * scaler;
       end
       
       if(Q_data_dec > 2^(iqDataBitWidth-1)-1)  % dec data sign is negative       
          Q_data = (Q_data_dec - 2^iqDataBitWidth) * scaler;
       else
          Q_data = Q_data_dec * scaler;
       end
       iqData((rbIndex-1)*24 + (reIndex-1)*2+1) = I_data;   
       iqData((rbIndex-1)*24 + (reIndex-1)*2+2) = Q_data;
    end
end