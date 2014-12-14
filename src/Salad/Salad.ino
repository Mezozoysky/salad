#include <Wire.h>
#include "SaladApi.h"


using namespace salad;

#define SLAVE_ADDRESS 0x04
int number = 0;
int state = 0;

int cmd[5];
int index=0;
int flag=0;
int i;
byte val=0,b[9],float_array[4];
int aRead=0;
byte accFlag=0,clkFlag=0;
int8_t accv[3];

void setup() 
{
    Serial.begin(115200);         // start serial for output
    Wire.begin(SLAVE_ADDRESS);

    Wire.onReceive(receiveData);
    Wire.onRequest(sendData);

    Salad app;
    Serial.print("App::mI: ");
    Serial.print(app.getI());
    Serial.print("\n");
    Serial.println("Ready!");
}

int pin;
int j;
void loop()
{
  long dur,RangeCm;
  if(index==4 && flag==0)
  {
    flag=1;
    //Digital Read
    if(cmd[0]==1)
      val=digitalRead(cmd[1]);
      
    //Digital Write
    if(cmd[0]==2)
      digitalWrite(cmd[1],cmd[2]);
      
    //Analog Read
     if(cmd[0]==3)
     {
      aRead=analogRead(cmd[1]);
      b[1]=aRead/256;
      b[2]=aRead%256;
     }
      
    //Set up Analog Write
    if(cmd[0]==4)
      analogWrite(cmd[1],cmd[2]);
        
    //Set up pinMode
    if(cmd[0]==5)
      pinMode(cmd[1],cmd[2]);
    
    //Ultrasonic Read
    if(cmd[0]==7)   
    {
      pin=cmd[1];
      pinMode(pin, OUTPUT);
      digitalWrite(pin, LOW);
      delayMicroseconds(2);
      digitalWrite(pin, HIGH);
      delayMicroseconds(5);
      digitalWrite(pin,LOW);
      pinMode(pin,INPUT);
      dur = pulseIn(pin,HIGH);
      RangeCm = dur/29/2;
      b[1]=RangeCm/256;
      b[2]=RangeCm%256;
    }
    if ( cmd[0] == 50 )
    {
      val = Config::slaveAddress();
    }
  }
}

void receiveData(int byteCount)
{
    while(Wire.available()) 
    {
      if(Wire.available()==4)
      { 
        flag=0;
        index=0;
      }
        cmd[index++] = Wire.read();
    }
}

// callback for sending data
void sendData()
{
  if(cmd[0]==1 || cmd[0] == 50)
    Wire.write(val);
  if(cmd[0]==3 ||cmd[0]==7)
    Wire.write(b, 3);
  if(cmd[0]==20)
    Wire.write(b, 4);
  if(cmd[0]==30||cmd[0]==40)
    Wire.write(b, 9);
}

