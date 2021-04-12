//Run motor at constant speed and measure rpm

#include <Servo.h>
Servo myMotor;

volatile byte pulses;       //  VOLATILE DATA TYPE TO STORE REVOLUTIONS
unsigned long int rpm;  //  DEFINE RPM AND MAXIMUM RPM
int led = 0,RPMlen , prevRPM;  //  INTEGERS TO STORE LED VALUE AND CURRENT RPM AND PREVIOUS RPM
   
 void setup()
 {
     Serial.begin(9600);   // GET VALUES USING SERIAL MONITOR
     attachInterrupt(0, RPMCount, RISING);     //  ADD A HIGH PRIORITY ACTION ( AN INTERRUPT)  WHEN THE SENSOR GOES FROM LOW TO HIGH
     pulses = 0;      //  START ALL THE VARIABLES FROM 0     
     rpm = 0;

     myMotor.attach(7,1000,2000); //Motor on pin 7

     myMotor.write(0);            
     delay(10000);//miliseconds


    myMotor.write(10);

 }

int fs = 5; ////  Sample frequency in Hz  //////////////////
int n = 3; ////number of tape on motor///// (ie pulses per rotation)

 void loop(){

  rpm=getSpeed(1000000/fs); //decreasing the sample frequency improves resolution but reduces sample rate
  Serial.print("t");Serial.print(millis());
  Serial.print("r");Serial.println(rpm);

//  if (micros()>20E+6){//Turn off motor after 10 sec(time starts at 10 sec)
//    myMotor.write(0);
//    Serial.println("Finished");
//    while(true);
// }
 }
 
 void RPMCount()              // EVERYTIME WHEN THE SENSOR GOES FROM LOW TO HIGH , THIS FUNCTION WILL BE INVOKED 
 {
   pulses++;                  // INCREASE REVOLUTIONS
   
 }


 double getSpeed(long int us){
  //input duration of sample in microsec
  unsigned long int t0=0, initialPulses=0, delta_pulses=0, delta_t;
  double rpm=0; 
  initialPulses=pulses;   // Set initial pulse count
  t0=micros();            // Set initial time, in us
  while(micros()-t0<us){} // Allow sampling time (us) to elapse
  delta_pulses=pulses-initialPulses;  // Pulse increase during sample period
  delta_t=us;             // Duration of the sample, in microseconds(passed as argument)

 // Serial.print("\t");Serial.println(delta_pulses); Serial.print("\t");Serial.println(1E+6/double(delta_t)*double(delta_pulses));  
  rpm=1E+6/double(delta_t)*double(delta_pulses)/n* 60.0;    // w=d(theta)/dt, convert to r.p.m. 
  return(rpm);
}


//////////////////////////////////////////////////////////////  END OF THE PROGRAM  ///////////////////////////////////////////////////////////////////////
