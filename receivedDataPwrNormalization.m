function [normalizedDataMatrix,pwr_dBfs,pwr_dBm] = receivedDataPwrNormalization(param,receivedData)
%==========================================================================
% Function: Implemented the received data power normalization
% Input:
%       param struct
%       receivedData
% Output:
%       normalizedData,the matrix dimension is reNum*symbolNum
%       pwr_dBfs,the received power in dbfs
%       pwr_dBm,the received power in dBm
%--------------------------------------------------------------------------
%% Input
pwrStatisticalSamples = param.pwrStatisticalSamples;
ulGain = param.ulGain;
rbNum = param.rbNum;
maxRBNum = param.maxRBNum;
reNum = param.reNum;

%% Calculate the received average power
if length(receivedData) < pwrStatisticalSamples
    error('The pwrStatisticalSamples must be smaller than length of receivedData!');
end

I_data = real(receivedData(1,1:pwrStatisticalSamples));
Q_data = imag(receivedData(1,1:pwrStatisticalSamples));
meanPower = mean(I_data.^2 + Q_data.^2);
% if  meanPower == 0
%     error('The receivedData Power is Zero, please check that!');
% end
pwr_dBfs = 10*log10(1/(2^30));
pwr_dBm = pwr_dBfs - ulGain;

%% IQ data amplitude normalization
normalizedAmp = sqrt(meanPower) * sqrt(maxRBNum/rbNum);  % considering the situation that rbNum is not equal to maxRBNum
I_Amp = real(receivedData);
Q_Amp = imag(receivedData);
normalizedData = I_Amp + 1j*Q_Amp;
normalizedDataMatrix = reshape(normalizedData,[reNum,14]);

