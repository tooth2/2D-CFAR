clear all
clc;

%% Radar Specifications 
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Frequency of operation = 77GHz
% Max Range = 200m
% Range Resolution = 1 m
% Max Velocity = 100 m/s
%%%%%%%%%%%%%%%%%%%%%%%%%%%
max_range = 200;
range_resolution = 1;
max_velocity = 70;

% speed of light = 3e8
c = 3e8; 
%% User Defined Range and Velocity of target
% *%TODO* :
% define the target's initial position and velocity. Note : Velocity
% remains contant
%  initial range:max value of 200m and velocity: [-70 to + 70 m/s]
target_range = 110;
target_velocity = -20; 
 
%% FMCW Waveform Generation

% *%TODO* :
% Design the FMCW waveform by giving the specs of each of its parameters.
% Calculate the Bandwidth (B), Chirp Time (Tchirp) and Slope (slope) of the FMCW
% chirp using the requirements above.sweep time : 5.5
B = c /(2*range_resolution);
Tchirp= (5.5*2*max_range)/c;
slope = B/Tchirp;
disp(slope);

%Operating carrier frequency of Radar 
fc= 77e9;             %carrier freq
                                                          
%The number of chirps in one sequence. Its ideal to have 2^ value for the ease of running the FFT
%for Doppler Estimation. 
Nd=128;                   % #of doppler cells OR #of sent periods % number of chirps

%The number of samples on each chirp. 
Nr=1024;                  %for length of time OR # of range cells

% Timestamp for running the displacement scenario for every sample on each
% chirp
t=linspace(0,Nd*Tchirp,Nr*Nd); %total time for samples

%Creating the vectors for Tx, Rx and Mix based on the total samples input.
Tx=zeros(1,length(t)); %transmitted signal
Rx=zeros(1,length(t)); %received signal
Mix = zeros(1,length(t)); %beat signal

%Similar vectors for range_covered and time delay.
r_t=zeros(1,length(t));
td=zeros(1,length(t));


%% Signal generation and Moving Target simulation
% Running the radar scenario over the time. 

for i=1:length(t)         
    
    % *%TODO* :
    %For each time stamp update the Range of the Target for constant velocity. 
    r_t(i) = target_range+ target_velocity*t(i);
    td(i) = 2*r_t(i)/c;
    % *%TODO* :
    %For each time sample we need update the transmitted and
    %received signal. 
    Tx(i) = cos(2*pi*(fc*t(i) + (slope*t(i)^2)/2));
    Rx(i) = cos(2*pi*(fc*(t(i)-td(i)) + (slope*(t(i)-td(i))^2)/2));
    
    % *%TODO* :
    %Now by mixing the Transmit and Receive generate the beat signal
    %This is done by element wise matrix multiplication of Transmit and
    %Receiver Signal
    Mix(i) = Tx(i).*Rx(i);
    
end

%% RANGE MEASUREMENT

 % *%TODO* :
%reshape the vector into Nr*Nd array. Nr and Nd here would also define the size of
%Range and Doppler FFT respectively.
sig = reshape(Mix, [Nr, Nd]);
 % *%TODO* :
%run the FFT on the beat signal along the range bins dimension (Nr) and
sig_fft1 = fft(sig, Nr); 
%normalize.
%sig_fft1 = sig_fft1 ./ max(sig_fft1); % Normalize
sig_fft1 = sig_fft1 ./ Nr;
 % *%TODO* :
% Take the absolute value of FFT output
sig_fft1 = abs(sig_fft1);
 % *%TODO* :
% Output of FFT is double sided signal, but we are interested in only one side of the spectrum.
% Hence we throw out half of the samples.
sig_fft1 = sig_fft1(1:(Nr/2));

%plotting the range
figure('Name','Range from First FFT')

 % *%TODO* :
 % plot FFT output 
plot(sig_fft1, "LineWidth",2);
grid on;
axis ([0 200 0 0.5]);
xlabel('range');
ylabel('FFT output');
title('1D FFT');



%% RANGE DOPPLER RESPONSE
% The 2D FFT implementation is already provided here. This will run a 2DFFT
% on the mixed signal (beat signal) output and generate a range doppler
% map.You will implement CFAR on the generated RDM


% Range Doppler Map Generation.

% The output of the 2D FFT is an image that has reponse in the range and
% doppler FFT bins. So, it is important to convert the axis from bin sizes
% to range and doppler based on their Max values.

Mix=reshape(Mix,[Nr,Nd]);

% 2D FFT using the FFT size for both dimensions.
sig_fft2 = fft2(Mix,Nr,Nd);


% Taking just one side of signal from Range dimension.
sig_fft2 = sig_fft2(1:Nr/2,1:Nd);
sig_fft2 = fftshift(sig_fft2);
RDM = abs(sig_fft2);
RDM = 10*log10(RDM) ;

%use the surf function to plot the output of 2DFFT and to show axis in both
%dimensions
%plot(sig_fft2, "LineWidth",2);
doppler_axis = linspace(-100,100,Nd);
range_axis = linspace(-200,200,Nr/2)*((Nr/2)/400);
figure,surf(doppler_axis,range_axis,RDM);
xlabel('doppler');
ylabel('range');
zlabel('RDM');
title('2D FFT');


%% CFAR implementation

%Slide Window through the complete Range Doppler Map

% *%TODO* :
%Select the number of Training Cells in both the dimensions.
Tr = 8;
Td = 4;
% *%TODO* :
%Select the number of Guard Cells in both dimensions around the Cell under 
%test (CUT) for accurate estimation
Gr = 4; 
Gd = 2;
% *%TODO* :
% offset the threshold by SNR value in dB 
offset = 1.4
% *%TODO* :
%Create a vector to store noise_level for each iteration on training cells
noise_level = zeros(1,1);


% *%TODO* :
%design a loop such that it slides the CUT across range doppler map by
%giving margins at the edges for Training and Guard Cells.
%For every iteration sum the signal level within all the training
%cells. To sum convert the value from logarithmic to linear using db2pow
%function. Average the summed values for all of the training
%cells used. After averaging convert it back to logarithimic using pow2db.
%Further add the offset to it to determine the threshold. Next, compare the
%signal under CUT with this threshold. If the CUT level > threshold assign
%it a value of 1, else equate it to 0.

   % Use RDM[x,y] as the matrix from the output of 2D FFT for implementing
   % CFAR

RDM = RDM/max(max(RDM));
 
for i = Tr+Gr+1 : Nr/2-(Gr+Tr) % over range
    for j = Td+Gd+1 : Nd-(Gd+Td) % over doppler
        noise_level = zeros(1,1);
        for p = i-(Tr+Gr): i+ (Tr+Gr)
            for q = j-(Td+Gd): j+(Td+Gd)
                if (abs(i-p)> Gr ||abs(j-q)>Gd)
                    % convert value from log to linear using db2pow
                    noise_level = noise_level+ db2pow(RDM(p,q));
                end
            end

        end
        %after averaging, convert it back to logarithmic using pow2db
        threshold = pow2db(noise_level/(2*(Td+Gd+1)*2*(Tr+Gr+1)-(Gr*Gd)-1));
        % add offset to the noise determine the threshold.
        threshold = threshold + offset;
        
        % compare the signal under CUT against this threshold
        % If the CUT level > threshold assign 1, else equate to 0
        CUT= RDM(i,j);
        if (CUT<threshold)
            RDM(i,j)=0;
        else 
            RDM(i,j)= 1; % max_T
            disp(i);
            disp(j);
        end
        %if (RDM(i+d_margin/2, j+r_margin/2) > sig_threshold)
        %    sig_CFAR(i+d_margin/2, j+r_margin/2) = 1;
        %else sig_CFAR(i+d_margin/2, j+r_margin/2) = 0;
        %end

        
    end
end
% *%TODO* :
% The process above will generate a thresholded block, which is smaller 
%than the Range Doppler Map as the CUT cannot be located at the edges of
%matrix. Hence,few cells will not be thresholded. To keep the map size same
% set those values to 0. 

RDM(RDM~=0 & RDM~=1) = 0;
%RDM(union(1:(Tr+Gr),end-(Tr+Gr-1):end),:) = 0;  % Rows
%RDM(:,union(1:(Td+Gd),end-(Td+Gd-1):end)) = 0;  % Columns


% *%TODO* :
%display the CFAR output using the Surf function like we did for Range
%Doppler Response output.
figure('Name', 'CFAR')
surf(doppler_axis,range_axis,RDM);
colorbar;
title('offset 1.4');
