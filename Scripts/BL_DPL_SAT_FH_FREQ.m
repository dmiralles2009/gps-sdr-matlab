% =========================================================================
%> @file      BL_DPL_SAT_FH_FREQ.m
%> @brief     Baseline implementation with doppler correction and 1000 Hz
%of accuracy. The doppler correction is performed in the frequency domain
%by a circcularshift. Structure for detection is
%doppler->sat->buckets.
%> @details   
%>              1. GPS PRN Correlator Detector (parallel code phase search) 
%>              2. Doppler search step: 1000 Hz.
%>
%> @date      Apr 27, 2014
%> @pre       Former File Name: baseline_stand_alone_5b.m
%> @bug       Code Phase delay may be different by 1 unit.
%> @bug       Confirm that the SNR is properly calculated in the code.
%> @note      Data doppler correction performed inside the loop process.
%> @author    Damian Miralles. dmiralles2009@gmail.com
%> @author	  Marvi Teixeira.  mteixeira@ieee.org
%> @author	  Jennifer Sandoval
%> @author    Manuel Ortiz
%> @copyright Copyright ©2014.  Damian Miralles, Marvi Teixeira, Jennifer Sandoval, Manuel Ortiz. All Rights Reserved.\n 
%>The authors grant permission to use, reproduce, modify, and distribute this software and its documentation for education, academic research and within non-commercial, non-profit endeavors as long as this copyright notice is included in each of the mentioned instances. No fee or signed licensing agreement is required provided that the copyright notice developed in this and in the following  paragraph is included in all reproductions, alterations, and distributions of the software or its  documentation. Contact the authors regarding any commercial licensing needs.\n 
%>THIS EXPERIMENTAL SOFTWARE AND RELATED DOCUMENTATION ARE PROVIDED “AS IS” AND NO, EXPLICIT OR IMPLICT, CLAIMS REGARDING THEIR ACCURACY OR SUITABILITY ARE MADE. USERS ARE RESPONSIBLE FOR SOFTWARE VALIDATION REGARDING THEIR PARTICULAR APPLICATION. NO UPDATES WILL BE OFFERED. VERY LIMITED SUPPORT COULD BE PROVIDED, BUT NOT GUARANTEED, ON A CASE BY CASE BASIS, DEPENDING ON THE AVAILABLE TIME RESOURCES AT THE TIME OF THE REQUEST.  
%>(dmiralles2009@gmail.com,  cc: mteixeir@ieee.org )
%>
% =========================================================================


clear all
clc

%==========================================================================
% >RAW DATA 1 Settings (I y Q) (Present 01 03 07 19 20 22 24 28 31)
% ><a href="linkURL">link text</a> 
% >satellites=[01 03 07 19 20 22 24 28 31];
% >fs=12000000;
% >ts=1/fs;
% > fi=3563000;

% %RAW DATA 1 Settings (I y Q) (Present 01 03 07 19 20 22 24 28 31)
% satellites=[01 03 07 19 20 22 24 28 31];
% fs=12000000;
% ts=1/fs;
% fi=3563000;
%==========================================================================

%==========================================================================
% > @attention RAW DATA 2 Settings  (solo I, hay que modificar codigo para correr y subir la otra gps file)
% > @<a href="linkURL">link Link to acces file</a> 
% > @var satellites=[01 21 29 30 31];
% > @brief Set of PRN satellites are on the data sample
% > @var fs=5456000;
% > @brief Sampling frequency if the file
% > @var ts=1/fs;
% > @var fi=4092000;

% %RAW DATA 2 Settings  (solo I, hay que modificar codigo para correr y subir la otra gps file)
% satellites=[01 21 29 30 31];
% fs=5456000;
% ts=1/fs;
% fi=4092000;
%==========================================================================

%==========================================================================
% > RAW DATA 3 Settings (I y Q) Akos-Book (21 is present according to book, 19 is not)
% > <a href="linkURL">link text</a> 
% > satellites=[01 02 03 04 05 06 07 19 21 22 23 24 25 26 27 28 29 30 31]; %(detected: ?3, 6,  21, 22, 26, 29,) 
% > fs=38192000;
% > ts=1/fs;
% > fi=9548000;

% %RAW DATA 3 Settings (I y Q) Akos-Book (21 is present according to book, 19 is not)
 %(detected: ?3, 6,  21, 22, 26, 29,) 
satellites=[3 4 6 9 15 18 21 22 26];
fs=38192000;
ts=1/fs;
fi=9548000;
%==========================================================================

%==========================================================================
% > RAW DATA 4 Settings (I y Q) Akos-Book ( 2nd data set)
% > <a href="linkURL">link text</a> 
% > satellites=[01 02 03 04 05 06 07 17 19 21 22 23 24 25 26 27 28 29 30 31]; %(detected: 19,...)
% > fs=16367600;
% > ts=1/fs;
% > fi=4130400;

% %RAW DATA 4 Settings (I y Q) Akos-Book ( 2nd data set)
% satellites=[01 02 03 04 05 06 07 17 19 21 22 23 24 25 26 27 28 29 30 31]; %(detected: 19,...)
% fs=16367600;
% ts=1/fs;
% fi=4130400;
%==========================================================================

%==========================================================================
% > RAW DATA 5 Settings (I y Q) Akos-Book (21 is present according to book, 19 is not)
% > <a href="linkURL">link text</a> 
% > satellites=[22 3 19 14 18 11 32 6]; %(sorted from strongest to weakest
% > fs=16367600;
% > ts=1/fs;
% > fi=4130400;

% % %RAW DATA 5 
% satellites=[22 3 19 14 18 11 32 6]; %(sorted from strongest to weakest
% fs=16367600;
% ts=1/fs;
% fi=4130400;
%==========================================================================

%> @fn G=CACODE(SV,FS)
%> @author    Dan Boschen
%> @date      15 Apr 2007
%> @brief     Generates C/A Codes for selected PRNs, up to 37 codes.
%> G is a matrix with 1023*FS columns with a row for each PRN desired.
%> SV is a vector c

g=cacode(satellites, fs/1023000); 
n=length(g(1,:));
p= round(sqrt(log(n)/log(2)));
k = 5;                                     % number of buckets
maxallowedbymemory= n*p*k;

% SELECT DATA FILE TO READ

% % the data 1: compact.bin should be compactdataq_etc_etc...
% [fid, message] = fopen('compact.bin', 'r', 'b');
% data = fread(fid,maxallowedbymemory, 'ubit1')';
% fclose(fid);

% Data 2, with I component only
%[fid, message] = fopen('gps.samples.1bit.I.fs5456.if4092.bin', 'r', 'b');
%
% 
% Data 3, from Borre-Akos book
[fid, message] = fopen('GPSdata-DiscreteComponents-fs38_192-if9_55.bin', 'r', 'b');
data = fread(fid,maxallowedbymemory, 'bit8')';
fclose(fid);

% % Data 4, from Borre-Akos book (2nd data set)
% [fid, message] = fopen('GPS_and_GIOVE_A-NN-fs16_3676-if4_1304.bin', 'r', 'b');
% data = fread(fid,maxallowedbymemory, 'bit8')';
% fclose(fid);

% % Data 5, 
% [fid, message] = fopen('gioveAandB_short.bin', 'r', 'b');
% data = fread(fid,maxallowedbymemory, 'bit8')';
% fclose(fid);


thresholdbaseline=10;


nn=0:length(data)-1;
ficarrierQ=((cos(2*pi*fi*nn*ts)));
ficarrierI=((sin(2*pi*fi*nn*ts)));

% ******* I and Q using XOR of 1s and 0s *******
ficarrierI2=ficarrierI>0; % positives go to 1 negatives go to 0
ficarrierQ2=ficarrierQ>0;  % positives go to 1 negatives go to 0
data=data>0;
datafiI=xor(data,ficarrierI2); % xor data  with sin to obtain I
datafiQ=xor(data,ficarrierQ2); % xor data  with cos to obtain Q
wholesignal=(2*datafiI-1)+1i*(2*datafiQ-1);


whole_set(length(satellites),6) = 0;
corr4(n) = 0;
x(n) = 0;
conjfftpulses(length(satellites),n) = 0;
signalshift(k,n) = 0;

pulses = g;                  %obtain prn pulse code given the PRN number
pulses = pulses*2-1;          %change 0 by -1.

%Perform pulse manipulation outside main loop. Here memory usage is
%increased but execution time is reduced.
for prncounter=1:1:length(satellites)
    fftpulse = fft(pulses(prncounter,:));
    conjfftpulses(prncounter,:) = conj(fftpulse);
end

tic
%DOPPLER SHIFT SEARCH
range = 0:n-1;
for frequencydopplershift=-10:1:10
    for ii=1:k
        signal = wholesignal((ii-1)*n+1:ii*n);
        signalfreq = fft(signal);
        signalshift(ii,:) = circshift(signalfreq,[0,frequencydopplershift]);
        
    end
    
    stop = 0;

    for prncounter=1:1:length(satellites)
        
        corr4=zeros(1,n); % correlation result preallocation
        SNRmethod4=0; % SNR method 4 init
        x=zeros(1,n); %acumulation bucket
        stop = 0;

        for ii=1:k %floor(length(wholesignal)/n) % divides signal into buckets of length n

            
            corr4 = ifft(conjfftpulses(prncounter,:).*signalshift(ii,:));%uses FFT to conv (or correlate)with each length-n bucket
            x=abs(corr4).^2+(x);            %accumulates with previous correlation
            [size,delaysamples4]=max((x));  % find the maximum size and position in accumulated correlations
          
            %SIGNAL TO NOISE RATIO Calculation (signal: peak power    noise: noise floor power)
            xx=x; % auxiliary variable in order to keep the accumulator as it is
            xx(delaysamples4)=0; %takes peak out of correlation result
            %noisefloorpwr=var(corr); %calculate noise variance %power of noise in output bucket
            %noisefloorpwr=var(detrend(corr)); %power of noise in output bucket
            noisefloorpwr=mean((xx));  %power of noise bed in output bucket (peak not included)
            SNRmethod4=size/noisefloorpwr;  % SNR calculation for this method
          
            if stop == 0 && SNRmethod4>thresholdbaseline  % threshold comparison
                stop = 1;
                detected_doppler_shift_a=(frequencydopplershift); %Doppler shift calculated based on doppler from break
                deviation_from_IF_a=fi+detected_doppler_shift_a*1000;
                detected_code_phase_a=delaysamples4;
                buckets_used_baseline_a=ii;
                if SNRmethod4 > whole_set(prncounter,2)
                    whole_set(prncounter,:) = [satellites(prncounter),round(SNRmethod4),deviation_from_IF_a,detected_doppler_shift_a,detected_code_phase_a,ii];
                end
                
            end

        end
    end

end
operation_time = toc
