#ifndef __SALAD_DHT11_H__
#define __SALAD_DHT11_H__

#include <Arduino.h>

namespace salad
{

class DHT11
{
public:

  static byte readTH( byte* cmdData, byte* errorCode );

private:

  static bool readByte( byte* b );

  static byte pin; //current measuring pin

};

} //namespace salad

#endif // __SALAD_DHT11_H__
