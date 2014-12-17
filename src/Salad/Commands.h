#ifndef __SALAD_COMMANDS_H__
#define __SALAD_COMMANDS_H__

namespace salad
{

enum
{
  CMD_NOP = 0,
  CMD_LAST_ERROR = 1,
  CMD_DIGITAL_READ = 2,
  CMD_DIGITAL_WRITE = 3,
  CMD_ANALOG_READ = 4,
  CMD_ANALOG_WRITE = 5,
  CMD_PIN_MODE = 6,
  CMD_RANGER_READ = 101
};

} //namespace salad

#endif //__SALAD_COMMANDS_H__
