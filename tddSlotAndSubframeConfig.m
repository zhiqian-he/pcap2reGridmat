function param = tddSlotAndSubframeConfig(param)
%==========================================================================
% Function: Generate the Slot and Subframe struct based on TDD Configuration  
% Input:
%       param struct
% Output:
%       param.uplinkSubframeIndex
%       param.slotConfiguration
%--------------------------------------------------------------------------
%==========================================================================
% Function: Generate the Slot and Subframe struct based on TDD Configuration  
% Input:
%       param struct
% Output:
%       param.uplinkSubframeIndex
%       param.slotConfiguration
%--------------------------------------------------------------------------
%% 3GPP Param
slotConfiguration = [];

for dlslotIndex = 1:param.nrofDownlinkSlots 
    slotConfiguration = [slotConfiguration,'D'];
end
if ~strcmp(param.mDuplexMode,'FDD')
    slotConfiguration = [slotConfiguration,'S'];
end
for ulslotIndex = 1:param.nrofUplinkSlots 
    slotConfiguration = [slotConfiguration,'U'];
end

if param.transmissionPeriod == 5
   slotConfiguration = [slotConfiguration,slotConfiguration];
elseif param.transmissionPeriod == 2.5
   slotConfiguration = [slotConfiguration,slotConfiguration,slotConfiguration,slotConfiguration];
elseif param.transmissionPeriod == 10 && (strcmp(param.mDuplexMode,'LTE_3GPP_TDD') || strcmp(param.mDuplexMode,'FDD'))
    slotConfiguration = [slotConfiguration,'DDDDD'];    
else
    error('Cannot support such TDD configurations at so far@!');
end
param.slotConfiguration = slotConfiguration;

% Special Slot
specialSlotConfiguration = [];
for dlsymIndex = 1:param.nrofDownlinkSymbols 
    specialSlotConfiguration = [specialSlotConfiguration,'d'];   %% Downlink symbol 
end

for blksymIndex = 1:(14 - param.nrofDownlinkSymbols - param.nrofUplinkSymbols)
    specialSlotConfiguration = [specialSlotConfiguration,'b'];   %% Blank symbol 
end

for dlsymIndex = 1:param.nrofUplinkSymbols 
    specialSlotConfiguration = [specialSlotConfiguration,'u'];  %% Uplink Symbol
end
param.specialSlotConfiguration = specialSlotConfiguration;

%% Uplink SlotIndex
param.subFrameNum = 10;
%---------------------------------------------------------------------------------------
if strcmp(param.mChannelType,'PUSCH')
    if ~strcmp(param.mDuplexMode,'FDD')
        uplinkSlotIndex = [];
        for slotIndex = 1:length(slotConfiguration)
            if strcmp(slotConfiguration(slotIndex),'U')
               uplinkSlotIndex = [uplinkSlotIndex,slotIndex];
            end
        end
        param.uplinkSlotIndex = uplinkSlotIndex;
    else
        param.uplinkSlotIndex = 1:1:param.subFrameNum * 2^param.mu;
    end
%---------------------------------------------------------------------------------------
elseif strcmp(param.mChannelType,'PRACH_F0') || strcmp(param.mChannelType,'PRACH_B4')
    if ~strcmp(param.mDuplexMode,'FDD')
        for slotIndex = 1:length(slotConfiguration)
            if strcmp(slotConfiguration(slotIndex),'U')
               param.uplinkSlotIndex = slotIndex;
               break;
            end
        end
    else
       if param.mu == 0
          param.uplinkSlotIndex = param.prachSubFrameId + 1; % the lowest index start from 1
       elseif param.mu == 1
          param.uplinkSlotIndex = 2 * param.prachSubFrameId + 1;
       else
          param.uplinkSlotIndex = 4 * param.prachSubFrameId + 1;
       end
    end
%---------------------------------------------------------------------------------------
else
    error('Only Support PUSCH and PRACH_F0/B4 analysis at this stage@!');  
end
