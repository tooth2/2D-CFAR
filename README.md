# 2D CFAR 
2D FFT, Doppler effect and CFAR implementation with matlab

## FMCW Waveform Design
FMCW waveform specification
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Frequency of operation = 77GHz
% Max Range = 200m
% Range Resolution = 1 m
% Max Velocity = 100 m/s
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  the target's initial position and velocity. Note : Velocity remains contant initial range:max value of 200m and velocity: [-70 to + 70 m/s]
* target_range = 100;
* target_velocity = 35;

* Bandwidth (B)
* chirp time (Tchirp) 
* speed of light = 3.0e+8
Max Range and Range Resolution will be considered here for waveform design.

The sweep bandwidth can be determined according to the range resolution and the sweep slope is calculated using both sweep bandwidth and sweep time.

> Bandwidth (B) = SpeedOfLight/(2∗rangeResolution)

The sweep time can be computed based on the time needed for the signal to travel the unambiguous maximum range. In general, for an FMCW radar system, the sweep time should be at least 5 to 6 times the round trip time. This example uses a factor of 5.5.

> chirp time (Tchirp) =5.5⋅2⋅R_max/SpeedOfLight

Giving the slope of the chirp signal
> slope of the chirp  = Bandwidth(B)/T_chirp
> slope = 2.0455e+13 % result

## 1D FFT (1st order FFT)
Implement the Range FFT on the Beat or **Mixed Signal** and plot the result.
generate a peak at the correct range, i.e the initial position of target assigned with an error margin of +/- 10 meters.
**Mixed Signal**: The beat signal can be calculated by multiplying the Transmit signal with Receive signal. This process in turn works as frequency subtraction. It is implemented by element by element multiplication of transmit and receive signal matrices.

![Result](1DFFT.png)

## 2D FFT (2nd order FFT)

![Result2](2DFFT.png)

## Simulation Loop 
Simulate Target movement and calculate the beat or mixed signal for every timestamp
A beat signal should be generated such that once range FFT implemented, it gives the correct range i.e the initial position of target assigned with an error margin of +/- 10 meters.

## Implementation steps for the 2D CFAR process
Implement the 2D CFAR process on the output of 2D FFT operation, i.e the Range Doppler Map.
The 2D CFAR processing should be able to suppress the noise and separate
the target signal

## Selection of Training, Guard cells and offset.

## suppress the non-thresholded cells at the edges.
2D CFAR suppress the noise and separate the target signal
