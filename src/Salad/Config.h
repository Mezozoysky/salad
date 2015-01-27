#ifndef __SALAD_CONFIG_H__
#define __SALAD_CONFIG_H__

#include <DHT.h>

namespace salad
{

struct Config
{
  static const int slaveAddress = 0x04;
  static const int loopDelayMiliseconds = 50;
  static const int thSensorType = DHT22;
};

}

#endif //__SALAD_SALAD_CONFIG_H__

