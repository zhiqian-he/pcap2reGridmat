function [deModulationOutput] = deModulation(param,receivedData)
%==========================================================================
% Function: Implemented the received data demodulation
% Input:
%       param struct
%       receivedData
% Output:
%       deModulatedData
%--------------------------------------------------------------------------
%% Input
mModType = param.mModType;
startRbNum = param.startRbNum;
dmrsSymbolIndex = param.dmrsSymbolIndex;
rbNum = param.rbNum;

%% Modulation Table
BPSKTable = [1+1j -1-1j] / sqrt(2) ;
BPSK = [0 1] ;

QPSKTable = [1+1j  1-1j -1+1j -1-1j] / sqrt(2) ;
QPSK = [0 0; 0 1; 1 0; 1 1] ;
 
QAM16Table = [1+1*1j  1+3*1j  3+1*1j  3+3*1j  1-1*1j  1-3*1j  3-1*1j  3-3*1j ...
             -1+1*1j -1+3*1j -3+1*1j -3+3*1j -1-1*1j -1-3*1j -3-1*1j -3-3*1j] / sqrt(10) ;
QAM16 = [0 0 0 0; 0 0 0 1; 0 0 1 0; 0 0 1 1; 0 1 0 0; 0 1 0 1; 0 1 1 0; 0 1 1 1;
         1 0 0 0; 1 0 0 1; 1 0 1 0; 1 0 1 1; 1 1 0 0; 1 1 0 1; 1 1 1 0; 1 1 1 1] ;

QAM64Table = [3+3*1j  3+1*1j  1+3*1j  1+1*1j  3+5*1j  3+7*1j  1+5*1j  1+7*1j...
              5+3*1j  5+1*1j  7+3*1j  7+1*1j  5+5*1j  5+7*1j  7+5*1j  7+7*1j...
              3-3*1j  3-1*1j  1-3*1j  1-1*1j  3-5*1j  3-7*1j  1-5*1j  1-7*1j...
              5-3*1j  5-1*1j  7-3*1j  7-1*1j  5-5*1j  5-7*1j  7-5*1j  7-7*1j...
             -3+3*1j -3+1*1j -1+3*1j -1+1*1j -3+5*1j -3+7*1j -1+5*1j -1+7*1j...
             -5+3*1j -5+1*1j -7+3*1j -7+1*1j -5+5*1j -5+7*1j -7+5*1j -7+7*1j...
             -3-3*1j -3-1*1j -1-3*1j -1-1*1j -3-5*1j -3-7*1j -1-5*1j -1-7*1j...
             -5-3*1j -5-1*1j -7-3*1j -7-1*1j -5-5*1j -5-7*1j -7-5*1j -7-7*1j] / sqrt(42) ;
QAM64 = [0 0 0 0 0 0; 0 0 0 0 0 1; 0 0 0 0 1 0; 0 0 0 0 1 1; 0 0 0 1 0 0; 0 0 0 1 0 1; 0 0 0 1 1 0; 0 0 0 1 1 1; 
         0 0 1 0 0 0; 0 0 1 0 0 1; 0 0 1 0 1 0; 0 0 1 0 1 1; 0 0 1 1 0 0; 0 0 1 1 0 1; 0 0 1 1 1 0; 0 0 1 1 1 1; 
         0 1 0 0 0 0; 0 1 0 0 0 1; 0 1 0 0 1 0; 0 1 0 0 1 1; 0 1 0 1 0 0; 0 1 0 1 0 1; 0 1 0 1 1 0; 0 1 0 1 1 1; 
         0 1 1 0 0 0; 0 1 1 0 0 1; 0 1 1 0 1 0; 0 1 1 0 1 1; 0 1 1 1 0 0; 0 1 1 1 0 1; 0 1 1 1 1 0; 0 1 1 1 1 1; 
         1 0 0 0 0 0; 1 0 0 0 0 1; 1 0 0 0 1 0; 1 0 0 0 1 1; 1 0 0 1 0 0; 1 0 0 1 0 1; 1 0 0 1 1 0; 1 0 0 1 1 1; 
         1 0 1 0 0 0; 1 0 1 0 0 1; 1 0 1 0 1 0; 1 0 1 0 1 1; 1 0 1 1 0 0; 1 0 1 1 0 1; 1 0 1 1 1 0; 1 0 1 1 1 1; 
         1 1 0 0 0 0; 1 1 0 0 0 1; 1 1 0 0 1 0; 1 1 0 0 1 1; 1 1 0 1 0 0; 1 1 0 1 0 1; 1 1 0 1 1 0; 1 1 0 1 1 1;
         1 1 1 0 0 0; 1 1 1 0 0 1; 1 1 1 0 1 0; 1 1 1 0 1 1; 1 1 1 1 0 0; 1 1 1 1 0 1; 1 1 1 1 1 0; 1 1 1 1 1 1 ];   

%% Demodulation
deModulationOutput = [];

for symbolIndex = 1:14
    if (symbolIndex == dmrsSymbolIndex(1)) || (symbolIndex == dmrsSymbolIndex(2))
        continue;  % DMRS is not modulated
    end
    InputData = receivedData(((startRbNum - 1) * 12 + 1) : ((startRbNum + rbNum - 1) * 12),symbolIndex);
    DataLen = length(InputData);
     
    switch  mModType
        case 'BPSK' 
            for ii = 1:DataLen
                Distance = abs(InputData(ii) * [1 1] - BPSKTable).^2 ;
                [minScale position_min] = min(Distance) ;
                Output(ii) = BPSK(position_min) ;
            end
        case 'QPSK' 
            for ii = 1:DataLen
                Distance = abs(InputData(ii) * [1 1 1 1] - QPSKTable).^2 ;
                [minScale position_min] = min(Distance) ;                       
                Output(2*(ii - 1) + 1:2*(ii - 1) + 2) = QPSK(position_min, :) ;
            end
        case '16QAM'
            for ii = 1:DataLen
                Distance = abs(InputData(ii) * ones(1, 16) - QAM16Table).^2 ;
                [minScale position_min] = min(Distance) ;
                Output(4*(ii - 1) + 1:4*(ii - 1) + 4) = QAM16(position_min,:);
            end
        case '64QAM'
            for ii = 1:DataLen
                Distance = abs(InputData(ii) * ones(1, 64) - QAM64Table).^2 ;
                [minScale position_min] = min(Distance) ;
                Output(6*(ii - 1) + 1:6*(ii - 1) + 6) = QAM64(position_min,:);
            end
        otherwise
            error('Wrong Modulation Type!')
    end
    deModulationOutput = [deModulationOutput, Output];  
end 