function p = LocalPhaseUnwrap(p)
%==========================================================================
% Function: Unwraps column vector of phase values.
%--------------------------------------------------------------------------
%% Substitude Method
for index = 1:length(p)-1
    dp_corr(index) = p(index+1) - p(index);
    
    cycle = round(abs(dp_corr(index))/(2*pi));  

    if dp_corr(index) < 0
       dp_corr(index) = dp_corr(index) + cycle*2*pi; 
    elseif dp_corr(index) > 0
       dp_corr(index) = dp_corr(index) - cycle*2*pi;
    else
       dp_corr(index) = dp_corr(index);
    end       
    p(index+1) = p(index) + dp_corr(index);
end