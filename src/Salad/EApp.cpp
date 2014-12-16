#include "EApp.h"
#include "Commands.h"
#include "Config.h"


namespace salad
{
  byte EApp::currCmd; //cmd id
  byte EApp::currCmdData[CMD_DATA_MAX_LEN]; //cmd data buffer
  int EApp::currCmdDataLen; //cmd data (not buffer!) length
  int EApp::currCmdDataIndex; //cmd buffer index
  
  byte EApp::errorCode[2]; //buffer for error codes


  void EApp::setup()
  {
    currCmd = 0;
    currCmdDataLen = 0;
    currCmdDataIndex = 0;

    errorCode[0] = 0;
    errorCode[1] = 0;

    Serial.begin(115200); // start serial for output

    Wire.begin(Config::slaveAddress);

    Wire.onReceive(EApp::onReceive);
    Wire.onRequest(EApp::onRequest);

    Serial.println("Salad is ready!");
  }

  void EApp::iterateLoop()
  {
    delay(Config::loopDelayValue);
  }

  void EApp::onReceive(int byteCount)
  {
    if ( Wire.available() )
    {
      currCmd = Wire.read();

      switch ( currCmd )
      {
        case ( CMD_NOP ):
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

        // case ( CMD_ANALOG_READ ):
        //   processAnalogRead();
        // break;

        // case ( CMD_ANALOR_WRITE ):
        //   processAnalogWrite();
        // break;

        case ( CMD_PIN_MODE ):
          processPinMode();
        break;

        default:
          processUnknownCmd();
        break;
      }
    }
  }
  

  void EApp::onRequest()
  {
    if ( currCmdDataLen > 0 )
    {
      currCmdDataIndex = 0;
      while ( currCmdDataIndex < currCmdDataLen )
      {
        Wire.write(currCmdData[currCmdDataIndex]);
        ++currCmdDataIndex;
      }
    }
  }

  void EApp::processLastError()
  {
    currCmdData[ 0 ] = errorCode[ 0 ];
    currCmdData[ 1 ] = errorCode[ 1 ];
    currCmdDataLen = 2;
  }

  void EApp::processDigitalRead()
  {
    if ( Wire.available() < 1 )
    {
      errorCode[ 0 ] = 2; //few arguments for command
      errorCode[ 1 ] = currCmd; //command number
      currCmdDataLen = 0;
      return;
    }
    //read command args
    currCmdData[ 0 ] = Wire.read(); //pin

    //process command and form the response
    currCmdData[ 0 ] = digitalRead( currCmdData[ 0 ] );
    currCmdDataLen = 1;
  }

  void EApp::processDigitalWrite()
  {
    if ( Wire.available() < 2 )
    {
      errorCode[ 0 ] = 2; //few arguments for command
      errorCode[ 1 ] = currCmd; //command id
      currCmdDataLen = 0;
      return;
    }
    //read command args
    currCmdData[ 0 ] = Wire.read(); //pin
    currCmdData[ 1 ] = Wire.read(); //value to write

    //process command and form the response
    digitalWrite( currCmdData[ 0 ], currCmdData[ 1 ] );
    currCmdDataLen = 0;
  }

  void EApp::processPinMode()
  {
    if ( Wire.available() < 2 )
    {
      errorCode[ 0 ] = 2; //few arguments for command
      errorCode[ 1 ] = currCmd; //command id
      currCmdDataLen = 0;
      return;
    }
    //read command args
    currCmdData[ 0 ] = Wire.read(); //pin
    currCmdData[ 1 ] = Wire.read(); //mode

    //process command and form the response
    pinMode( currCmdData[ 0 ], currCmdData[ 1 ] );
    currCmdDataLen = 0;
  }

  void EApp::processUnknownCmd()
  {
    errorCode[ 0 ] = 1; //unknow command error
    errorCode[ 1 ] = currCmd; //command id
    currCmdDataLen = 0;
  }

} //namespace salad
