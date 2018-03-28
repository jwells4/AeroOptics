% Generate a pulse to send to the stepper motor controller.
clear
clc
close all
% Create the pulse function
MM2MOVE = 70;
NUM_REVS = MM2MOVE*1.5625;
RESOLUTION = 1024;
MULTIPLIER = 4*NUM_REVS;
WAVE_FREQ = 2;
PULSE_FREQ = 2*WAVE_FREQ;
DUTY_CYCLE = 50;
PULSE_VOLTAGE = 10;
TIME_CONSTANT = 1024;

PULSE_TIME = linspace(0,2*pi,RESOLUTION*MULTIPLIER);
PULSE = PULSE_VOLTAGE*(0.5*(square(1600*NUM_REVS*PULSE_TIME,DUTY_CYCLE)+1));
STEP_DIRECTION = 10*ones(1,length(PULSE_TIME));
STEP_DIRECTION(end) = 0;
PULSE(end) = 0;


plot(PULSE_TIME,PULSE)
hold on
plot(PULSE_TIME,STEP_DIRECTION)
axis([0 Inf 0 12])


% Output the signal to the cDAQ
STEP_CONTROL = daq.createSession('ni');
addAnalogOutputChannel(STEP_CONTROL,'cDAQ2Mod5',0,'Voltage');
addAnalogOutputChannel(STEP_CONTROL,'cDAQ2Mod5',1,'Voltage');
STEP_CONTROL.Rate = 8000;
STEP_CONTROL.IsContinuous = false;
queueOutputData(STEP_CONTROL,[STEP_DIRECTION' PULSE']);
STEP_CONTROL.startForeground;
