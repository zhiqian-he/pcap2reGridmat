function [param,receivedDataGrid] = phaseCompensation(param,receivedDataGrid)
%==========================================================================
% Function: OFDM Phase Compensation
% Input:
%       param struct
% Output:
%       param struct
%--------------------------------------------------------------------------

%% Input Parameters
ResourceGridBWP = receivedDataGrid;
mSubCarrierSpacing = param.mSubCarrierSpacing * 1000; % unit:Hz
iFFTPoints = param.iFFTPoints;                        % FFT Point
freqOffset = -7.5/10^3;                                % unit，Mhz
Tc = 1/(mSubCarrierSpacing*iFFTPoints);
Ts = 1/(15000*2048);
numerology = param.mu;                                % 1-->30khz SCS ; 0-->15khz; 2-->60Khz
max_symbols_per_subframe = param.slotNum_per_subFrame * 14;

%% Calculate Time of CP for each OFDM Symbol
k = Ts/Tc;  
N_u = 2048*k/2^numerology;

for l = 1:max_symbols_per_subframe
   if mod(l,7*2^numerology) == 1
       N_cp_u(l) = 144*k/2^numerology + 16*k;
   else
       N_cp_u(l) = 144*k/2^numerology;
   end
   
   if l == 1
      t_start_u(l) = 0;
   else
      t_start_u(l) = t_start_u(l-1) + (N_u + N_cp_u(l-1))*Tc;
   end
   t_cp_u(l) = t_start_u(l)+N_cp_u(l)*Tc;
end

%% Phase Compensation value calculation
for index = 1:max_symbols_per_subframe
    Compensation_value(index) = exp(-1j*2*pi*freqOffset*1000000*t_cp_u(index));
end

%% Phase Compensation
receivedDataGrid = zeros(param.reNum,14);
for subFrameNum = 1:10
    for index = 1 : 14
        receivedDataGrid(:,index) = ResourceGridBWP(:,index) * Compensation_value(index);
    end
end
