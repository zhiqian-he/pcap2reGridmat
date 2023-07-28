function [Output, ModLen] = comModulation(param,Input) 
%==========================================================================

%--------------------------------------------------------------------------
% Input
mModType = param.mModType;
SourceLen = length(Input) ;

BPSKTable = [1+1i -1-1j] / sqrt(2) ;
QPSKTable = [1+1j  1-1j -1+1j -1-1j] / sqrt(2) ; 
QAM16Table = [1+1*1j  1+3*1j  3+1*1j  3+3*1j  1-1*1j  1-3*1j  3-1*1j  3-3*1j ...
             -1+1*1j -1+3*1j -3+1*1j -3+3*1j -1-1*1j -1-3*1j -3-1*1j -3-3*1j] / sqrt(10) ;
QAM64Table = [3+3*1j  3+1*1j  1+3*1j  1+1*1j  3+5*1j  3+7*1j  1+5*1j  1+7*1j...
              5+3*1j  5+1*1j  7+3*1j  7+1*1j  5+5*1j  5+7*1j  7+5*1j  7+7*1j...
              3-3*1j  3-1*1j  1-3*1j  1-1*1j  3-5*1j  3-7*1j  1-5*1j  1-7*1j...
              5-3*1j  5-1*1j  7-3*1j  7-1*1j  5-5*1j  5-7*1j  7-5*1j  7-7*1j...
             -3+3*1j -3+1*1j -1+3*1j -1+1*1j -3+5*1j -3+7*1j -1+5*1j -1+7*1j...
             -5+3*1j -5+1*1j -7+3*1j -7+1*1j -5+5*1j -5+7*1j -7+5*1j -7+7*1j...
             -3-3*1j -3-1*1j -1-3*1j -1-1*1j -3-5*1j -3-7*1j -1-5*1j -1-7*1j...
             -5-3*1j -5-1*1j -7-3*1j -7-1*1j -5-5*1j -5-7*1j -7-5*1j -7-7*1j] / sqrt(42) ;
%==========================================================================
% BPSK
if strcmp(mModType,'BPSK')
    %disp('BPSK调制') ;
    mod_len = length(Input) ;
    Output = zeros(1, mod_len) ;
    for ii = 1:SourceLen
        if Input(ii) == 0
            Output(ii) = BPSKTable(1) ;
        elseif Input(ii) == 1
            Output(ii)= BPSKTable(2) ;
        end      
    end
end
%--------------------------------------------------------------------------

%==========================================================================
if strcmp(mModType,'QPSK')
    %disp('QPSK调制') ;
    data = Input ;
    if 1 == mod(SourceLen, 2)   % 判定输入数据比特数是否是2的倍数
        data(end +1) = 0 ;  
    end
    mod_len = length(data) ;
    Output = zeros(1, mod_len / 2) ;
    jj = 1 ;
    for ii = 1: 2: mod_len
        temp =  data([ii, ii + 1]) ;  
        tempstr =  num2str(temp) ;
        tempdec =  bin2dec(tempstr) ;
        Output(jj) = QPSKTable(tempdec + 1) ;
        jj = jj + 1 ; 
    end    
end
%--------------------------------------------------------------------------

%==========================================================================
if strcmp(mModType,'16QAM')
    %disp('16QAM调制') ;
    fil_len = mod(SourceLen , 4) ;
    data = Input ;
    data(end + 4 - fil_len) = 0 ;      
    mod_len = length(data) ;    
    Output = zeros(1, mod_len / 4) ;
    
    for ii =1:mod_len / 4
        temp = data([4*ii-3, 4*ii-2, 4*ii-1, 4*ii]) ;
        tempstr =  num2str(temp);
        tempdec =  bin2dec(tempstr);
        Output(ii) = QAM16Table(tempdec + 1) ;		  
    end
end
%--------------------------------------------------------------------------

%==========================================================================
if strcmp(mModType,'64QAM')
    fil_len = mod(SourceLen , 6) ; 
    data = Input ;
    %data(end + 6 - fil_len) = 0 ;
    mod_len = length(data) ;    
    Output = zeros(1, mod_len / 6) ;
    for ii =1:mod_len / 6
       temp = data([6*ii-5,6*ii-4,6*ii-3, 6*ii-2, 6*ii-1, 6*ii]);
       tempstr =  num2str(temp);
       tempdec = bin2dec(tempstr) ;
       Output(ii) = QAM64Table(tempdec + 1);
   end  
end 
ModLen = length(Output) ;
%--------------------------------------------------------------------------