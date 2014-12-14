#ifndef __SALAD_SALAD_CONFIG_H__
#define __SALAD_SALAD_CONFIG_H__

namespace salad
{

class Config
{
private:
  static int mSlaveAddress;

public:
  static const int slaveAddress()
  {
    return ( mSlaveAddress );
  }

};

}

#endif //__SALAD_SALAD_CONFIG_H__

