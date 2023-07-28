function param = ruULGainInit(param)
%==========================================================================
% Function: Initialize RU UL Gain based on ORAN Spec
% Input:
%       param struct
% Output:
%       Initialized param struct
%--------------------------------------------------------------------------
%% Inuput Param
if strcmp(param.mChannelType,'PUSCH')
   if strcmp(param.mRAT,'LTE')
      switch param.mTransmissionBandWidth
          case 3
              param.ulGain = 39.09;
          case 5
              param.ulGain = 36.89;
          case 10
              param.ulGain = 33.88;
          case 15
              param.ulGain = 32.12;
          case  20
              param.ulGain = 30.87;
          otherwise
              error('Can not support such LTE mTransmissionBandWidth so far@!');
      end   
   elseif strcmp(param.mRAT,'NR')
      if param.mSubCarrierSpacing == 15
         switch param.mTransmissionBandWidth
           case 5
               param.ulGain = 36.89;
           case 10
               param.ulGain = 33.71;
           case 15
               param.ulGain = 31.90;
           case  20
               param.ulGain = 30.63;
           case  25
               param.ulGain = 29.63;               
           case  30
               param.ulGain = 28.83;              
           case  40
               param.ulGain = 27.53;                
           case  50
               param.ulGain = 26.56;                        
           otherwise
               error('Can not support such NR mTransmissionBandWidth so far@!');
         end          
      elseif param.mSubCarrierSpacing == 30
         switch param.mTransmissionBandWidth
           case 5
               param.ulGain = 40.46;
           case 10
               param.ulGain = 37.07;
           case 15
               param.ulGain = 35.08;
           case  20
               param.ulGain = 33.80;
           case  25
               param.ulGain = 32.74;               
           case  30
               param.ulGain = 31.95;              
           case  40
               param.ulGain = 30.62;                
           case  50
               param.ulGain = 29.63;
           case  60
               param.ulGain = 28.78;                 
           case  70
              param.ulGain = 28.11;               
           case  80
              param.ulGain = 27.51;               
           case  90
              param.ulGain = 26.98; 
           case  100
             param.ulGain = 26.51;     
           otherwise
             error('Can not support such NR mTransmissionBandWidth so far@!');
         end              
      else   %% SCS 60Khz
         switch param.mTransmissionBandWidth
           case 10
               param.ulGain = 40.46;
           case 15
               param.ulGain = 38.32;
           case  20
               param.ulGain = 37.07;
           case  25
               param.ulGain = 35.96;
           case  30
               param.ulGain = 35.08;              
           case  40
               param.ulGain = 33.80;
           case  50
               param.ulGain = 32.74;
           case  60
               param.ulGain = 31.9;                 
           case  70
              param.ulGain = 31.19;               
           case  80
              param.ulGain = 30.58;               
           case  90
              param.ulGain = 30.05; 
           case  100
             param.ulGain = 29.57;     
           otherwise
             error('Can not support such NR mTransmissionBandWidth so far@!');
         end          
      end
   else
      error('Wrong RAT Type Setting@!'); 
   end  
elseif strcmp(param.mChannelType,'PRACH_F0')
    param.ulGain = 32.43;
elseif strcmp(param.mChannelType,'PRACH_B4')
    param.ulGain = 40.23;
else
    error('Only Support PUSCH and PRACH_F0 analysis at this stage@!');
end
