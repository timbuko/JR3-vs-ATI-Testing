void setup() {
  // put your setup code here, to run once:
  pinMode(A0,OUTPUT); //Output voltage
  pinMode(A1,INPUT);  //Read voltage
  pinMode(A2,OUTPUT); // GND
  Serial.begin(9600);

  digitalWrite(A0,HIGH);
  digitalWrite(A2,LOW);
}

long int x;
void loop() {
  // put your main code here, to run repeatedly:
  x = analogRead(A1);
  x=map(x,0,1023,0,1023);
  Serial.print(digitalRead(A1));
  Serial.print("\t");
  Serial.println(x);
  
}