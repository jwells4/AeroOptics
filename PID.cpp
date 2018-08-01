//==============================================================================
// PID controller
// Author: Jonathan Wells
// Version: 1.0
//
//==============================================================================


// working variables
double Input, Output, Setpoint;
double errSum, lastErr;
double ITerm, lastInput;
double outMin, outMax;
double kp, ki, kd;
int sampleTime = 5;     // Time in milliseconds - CHANGE THIS LATER TO INHERIT FROM THE MAIN PROGRAM
bool inAuto = false;

void Compute()
{
  if (inAuto){
    /*Compute all the working error variables*/
    double error = (Setpoint - Input);
    ITerm += (ki * error);
    if (ITerm > outMax)
      ITerm = outMax;
    else if (ITerm < outMin)
      ITerm = outMin;
    double dInput = (Input - lastInput);

    /*Compute PID Output*/
    Output = kp * error + ITerm - kd * dInput;
    if (Output > outMax)
      Output = outMax;
    else if (Output < outMin)
      Output = outMin;

    /*Remember some variables for next time*/
    lastInput = Input;
  }
}

void SetTunings(double Kp, double Ki, double Kd)
{
  double sampleTimeInSeconds = ((double)sampleTime)/1000;

  kp = Kp;
  ki = Ki * sampleTimeInSeconds;
  kd = Kd / sampleTimeInSeconds;
}

void SetOutputLimits(double Min, double Max)
{
  outMin = Min;
  outMax = Max;
}

void setOnOff(bool &mode)
{
  bool newMode = mode;
  if (newMode && !inAuto)
    Initialize();
  inAuto = newMode;
}

void Initialize()
{
  lastInput = Input;
  ITerm = Output;
  if (ITerm > outMax)
    ITerm = outMax;
  else if (ITerm < outMin)
    ITerm = outMin;
}
