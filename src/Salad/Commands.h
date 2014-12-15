#ifndef __SALAD_COMMANDS_H__
#define __SALAD_COMMANDS_H__

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

} //namespace salad

#endif //__SALAD_COMMANDS_H__
