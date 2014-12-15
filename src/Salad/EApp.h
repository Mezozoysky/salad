#ifndef __SALAD_EAPP_H__
#define __SALAD_EAPP_H__

#include <Arduino.h>
#include <Wire.h>

namespace salad
{
  
class EApp
{
private:
	EApp();

public:
	virtual ~EApp();

	static void setup();
	static void iterateLoop();

	static void onReceiveWireHandler(int byteCount);
	static void onRequestWireHandler();

private:
  void iterate();
  
private:
	static EApp* mApp;

  int number;
  int state;

  int cmd[5];
  int index;
  int flag;
  int i;
  byte val,b[9],float_array[4];
  int aRead;
  byte accFlag,clkFlag;
  int8_t accv[3];

  int pin;
  int j;

};

} //namespace salad

#endif //__SALAD_EAPP_H__
