#include "EApp.h"
#include "Commands.h"
#include "Config.h"


namespace salad
{
  
  EApp* EApp::mApp;

  EApp::EApp()
  : number(0)
  , state(0)
  , index(0)
  , flag(0)
  , val(byte(0))
  , aRead(0)
  , accFlag(0)
  , clkFlag(0)
  
  {
    //do nothing
  }

  EApp::~EApp()
  {
    //do nothing
  }

  void EApp::setup()
  {
    mApp = new EApp();

    Serial.begin(115200); // start serial for output
    Wire.begin(salad::Config::slaveAddress);

    Wire.onReceive(EApp::onReceiveWireHandler);
    Wire.onRequest(EApp::onRequestWireHandler);

    Serial.println("Salad is ready!");
  }

  void EApp::iterateLoop()
  {
    mApp->iterate();
  }

  void EApp::iterate()
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
        val = Config::slaveAddress;
      }
    }
  }
  
  void EApp::onReceiveWireHandler(int byteCount)
  {
    while(Wire.available()) 
    {
      if(Wire.available()==4)
      { 
        mApp->flag=0;
        mApp->index=0;
      }
      mApp->cmd[mApp->index++] = Wire.read();
    }
  }

  void EApp::onRequestWireHandler()
  {
    if(mApp->cmd[0]==1 || mApp->cmd[0] == 50)
    {
      Wire.write(mApp->val);
    }
    if(mApp->cmd[0]==3 ||mApp->cmd[0]==7)
    {
      Wire.write(mApp->b, 3);
    }
    if(mApp->cmd[0]==20)
    {
      Wire.write(mApp->b, 4);
    }
    if(mApp->cmd[0]==30||mApp->cmd[0]==40)
    {
      Wire.write(mApp->b, 9);
    }
  }

} //namespace salad
