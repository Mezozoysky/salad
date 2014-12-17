#ifndef __SALAD_EAPP_H__
#define __SALAD_EAPP_H__

#include <Arduino.h>
#include <Wire.h>

namespace salad
{

#define CMD_DATA_MAX_LEN 16
  
class EApp
{
public:

  static void setup();
  static void iterateLoop();

  static void onReceive(int byteCount);
  static void onRequest();

private:

  static void processLastError();
  static void processDigitalRead();
  static void processDigitalWrite();
  static void processAnalogRead();
  static void processAnalogWrite();
  static void processPinMode();

  static void processRangerRead();

  static void processUnknownCmd(); //stub for error handling only, does not actual command processing;

  static byte currCmd;
  static byte currCmdData[CMD_DATA_MAX_LEN];
  static int currCmdDataLen;

  static byte errorCode[2];

  static int analogTmp;
};

} //namespace salad

#endif //__SALAD_EAPP_H__
