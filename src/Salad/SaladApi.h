#ifndef __SALAD_SALAD_H__
#define __SALAD_SALAD_H__

#include "SaladConfig.h"

namespace salad
{

enum Commands
{
  NOP = 0,
  DIGITAL_READ,
  DIGITAL_WRITE,
  ANALOG_READ,
  ANALOG_WRITE,
  MODE,
  RANGER,
  COMMANDS_COUNS
};

class Salad
{
  public:
    Salad();    
    virtual ~Salad();
    
    virtual const int getI() const;
    virtual void setI(const int i);
  
  private:
    int mI;
};

}

#endif //__SALAD_SALAD_H__

