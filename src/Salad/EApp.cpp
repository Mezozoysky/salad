#include "EApp.h"
#include "Commands.h"
#include "Config.h"


namespace salad
{
  byte EApp::currCmdData[CMD_DATA_MAX_LEN]; //cmd data buffer
  int EApp::currCmdDataLen; //cmd data (not buffer!) length
  bool EApp::isNewCmd; //true means we have new cmd received 
  
  byte EApp::errorCode[ 2 ]; //buffer for error codes

  DHT EApp::dht; //dht sensor

  int EApp::analogTmp; //storage for temporary analog values 


  void EApp::setup()
  {
    currCmdDataLen = 0;
    isNewCmd = false;

    errorCode[ 0 ] = 0;
    errorCode[ 1 ] = 0;

    analogTmp = 0;

    Serial.begin( 115200 ); // start serial for output

    Wire.begin( Config::slaveAddress );

    Wire.onReceive( EApp::onReceive );
    Wire.onRequest( EApp::onRequest );

    Serial.println( "Salad is ready!" );
  }

  void EApp::iterateLoop()
  {
    if ( isNewCmd && currCmdDataLen > 0 )
    {
      isNewCmd = false;
      switch ( currCmdData[ 0 ] )
      {
        case ( CMD_NOP ):
          currCmdDataLen = 1;
          return;
        break;

        case ( CMD_LAST_ERROR ):
          processLastError();
        break;

        case ( CMD_DIGITAL_READ ):
          processDigitalRead();
        break;

        case ( CMD_DIGITAL_WRITE ):
          processDigitalWrite();
        break;

        case ( CMD_ANALOG_READ ):
          processAnalogRead();
        break;

        case ( CMD_ANALOG_WRITE ):
          processAnalogWrite();
        break;

        case ( CMD_PIN_MODE ):
          processPinMode();
        break;

        case ( CMD_RANGER_READ ):
          processRangerRead();
        break;

        case ( CMD_READ_TH ):
          processReadTH();
        break;

        default:
          processUnknownCmd();
        break;
      }
    }
    //delay( Config::loopDelayMiliseconds );
  }

  void EApp::onReceive( int byteCount )
  {
    if ( Wire.available() ) //excrescent test?
    {
      isNewCmd = true;
      currCmdDataLen = 0;
      while ( Wire.available() )
      {
        currCmdData[ currCmdDataLen++ ] = Wire.read();
      }
      ++currCmdDataLen;
    }
  }
  

  void EApp::onRequest()
  {
    if ( !isNewCmd && currCmdDataLen > 0 )
    {
      Wire.write( currCmdData, currCmdDataLen );
    }
  }

  void EApp::processLastError()
  {
    currCmdData[ 1 ] = errorCode[ 0 ];
    currCmdData[ 2 ] = errorCode[ 1 ];
    currCmdDataLen = 3;
  }

  void EApp::processDigitalRead()
  {
    if ( currCmdDataLen < 2 )
    {
      errorCode[ 0 ] = 2; //few arguments for command
      errorCode[ 1 ] = currCmdData[ 0 ]; //command number
      currCmdData[ 0 ] = CMD_NOP;
      currCmdDataLen = 1;
      return;
    }

    //process command and form the response
    currCmdData[ 1 ] = digitalRead( /*pin*/currCmdData[ 1 ] );
    currCmdDataLen = 2;
  }

  void EApp::processDigitalWrite()
  {
    if ( currCmdDataLen < 3 )
    {
      errorCode[ 0 ] = 2; //few arguments for command
      errorCode[ 1 ] = currCmdData[ 0 ]; //command number
      currCmdData[ 0 ] = CMD_NOP;
      currCmdDataLen = 1;
      return;
    }

    //process command and form the response
    digitalWrite( /*pin*/currCmdData[ 1 ], /*value*/currCmdData[ 2 ] );
    currCmdDataLen = 1; //cmd number as response
  }

  void EApp::processAnalogRead()
  {
    if ( currCmdDataLen < 2 )
    {
      errorCode[ 0 ] = 2; //few args
      errorCode[ 1 ] = currCmdData[ 0 ]; //command number
      currCmdData[ 0 ] = CMD_NOP;
      currCmdDataLen = 1;
      return;
    }

    //process
    analogTmp = analogRead( /*pin*/currCmdData[ 1 ] );
    currCmdData[ 1 ] = analogTmp / 256;
    currCmdData[ 2 ] = analogTmp % 256;
    currCmdDataLen = 3;
  }

  void EApp::processAnalogWrite()
  {
    if ( currCmdDataLen < 3 )
    {
      errorCode[ 0 ] = 2; //few args
      errorCode[ 1 ] = currCmdData[ 0 ];
      currCmdData[ 0 ] = CMD_NOP;
      currCmdDataLen = 1;
      return;
    }

    //process
    analogWrite( /*pin*/currCmdData[ 1 ], /*value*/currCmdData[ 2 ] );
    currCmdDataLen = 1; //cmd number as response
  }

  void EApp::processPinMode()
  {
    if ( currCmdDataLen < 3 )
    {
      errorCode[ 0 ] = 2; //few arguments for command
      errorCode[ 1 ] = currCmdData[ 0 ]; //command id
      currCmdData[ 0 ] = CMD_NOP;
      currCmdDataLen = 1;
      return;
    }

    //process command and form the response
    pinMode( /*pin*/currCmdData[ 1 ], /*mode*/currCmdData[ 2 ] );
    currCmdDataLen = 1; //cmd number as response
  }

  void EApp::processRangerRead()
  {
    if ( currCmdDataLen < 2 )
    {
      errorCode[ 0 ] = 2; //few args
      errorCode[ 1 ] = currCmdData[ 0 ];
      currCmdData[ 0 ] = CMD_NOP;
      currCmdDataLen = 1;
      return;
    }

    //process
    pinMode( currCmdData[ 1 ], OUTPUT );
    digitalWrite( currCmdData[ 1 ], LOW );
    delayMicroseconds( 2 );
    digitalWrite( currCmdData[ 1 ], HIGH );
    delayMicroseconds( 5 );
    digitalWrite( currCmdData[ 1 ], LOW );
    pinMode( currCmdData[ 1 ], INPUT );

    long rangeCm = pulseIn( currCmdData[ 1 ], HIGH ) / 29 / 2;

    currCmdData[ 1 ] = rangeCm / 256;
    currCmdData[ 2 ] = rangeCm % 256;
    currCmdDataLen = 3;

    // 5 290 - 5 212
  }

  void EApp::processReadTH()
  {
    if ( currCmdDataLen < 1 )
    {
      errorCode[ 0 ] = 2; //few args for cmd
      errorCode[ 1 ] = currCmdData[ 0 ];
      currCmdData[ 0 ] = CMD_NOP;
      currCmdDataLen = 1;
      return;
    }

    dht.begin( currCmdData[ 1 ], Config::thSensorType );

    float v = dht.readTemperature();

    byte* b = (byte*)&v;
    for ( int i = 0; i < 4; ++i )
    {
      currCmdData[ i + 1 ] = b[ i ];
    }

    v = dht.readHumidity();

    b = (byte*)&v;
    for ( int i = 0; i < 4; ++i )
    {
      currCmdData[ i + 5 ] = b[ i ];
    }

    currCmdDataLen = 9;
  }

  void EApp::processUnknownCmd()
  {
    errorCode[ 0 ] = 1; //unknow command error
    errorCode[ 1 ] = currCmdData[ 0 ]; //command id
    currCmdData[ 0 ] = CMD_NOP;
    currCmdDataLen = 1;
  }

} //namespace salad
