function [txData] = freqDataCovertToTime(param)
%==========================================================================
% Function: plot the received data spectrum
% Input:
%       param struct
%       reGrid: the received data RE Grid
% Output:
%       txData
%--------------------------------------------------------------------------
%% Input
reGrid = param.rcvReGrid;

%% IFFT Preperation
oriData_ifft = zeros(param.iFFTPoints,14*2^param.mu*10);
oriData_ifft(1:param.reNum/2,:) = reGrid(param.reNum/2+1:end,1:14*2^param.mu*10,param.bandSectorId+1,param.ruPortId+1,param.carrierComponentId+1);
oriData_ifft(param.iFFTPoints-param.reNum/2 + 1:param.iFFTPoints,:) = reGrid(1:param.reNum/2,1:14*2^param.mu*10,param.bandSectorId+1,param.ruPortId+1,param.carrierComponentId+1);

%% CP Length Calculation
Ts = 1/(15000*2048);
Tc = 1/(param.mSubCarrierSpacing*1000*param.iFFTPoints);
k = Ts/Tc;
CP_long = 144*k*2^(-param.mu)+16*k; 
CP_short = 144*k*2^(-param.mu);

%% IFFT and Add CP
txData=[];
total_CP_Len = 0;
for symbolIndex = 1:param.symbolNum
    txData_temp = [];
    ifft_data = ifft(oriData_ifft(:,symbolIndex));
    if mod(symbolIndex,7*2^param.mu) == 1
       txData_temp =  [ifft_data(param.iFFTPoints - CP_long + 1:end);ifft_data];
       total_CP_Len = total_CP_Len + CP_long;
    else
       txData_temp =  [ifft_data(param.iFFTPoints - CP_short + 1:end);ifft_data];
       total_CP_Len = total_CP_Len + CP_short;
    end
    txData = [txData; txData_temp];  
end
