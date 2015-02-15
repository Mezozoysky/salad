#include "DHT11.h"
#include "Commands.h"

namespace salad
{

byte DHT11::pin;

//returns result cmd data length
byte DHT11::readTH( byte* cmdData, byte* errorCode )
{
  pin = cmdData[ 1 ]; //argument

  byte res;

  pinMode( pin, OUTPUT );
  digitalWrite( pin, HIGH );

  delayMicroseconds( 40 ); // extra?

  //prepare sensor for reading
  digitalWrite( pin, LOW );
  delay( 23 );
  digitalWrite( pin, HIGH );

  delayMicroseconds( 40 );

  pinMode( pin, INPUT );
  delayMicroseconds( 40 );

  res = digitalRead( pin );

  if ( res )
  {
    errorCode[ 0 ] = 3; //dht11 read start error
    errorCode[ 1 ] = 1; //subcode 1
    cmdData[ 0 ] = CMD_NOP;
    return 1; // cmd data length
  }

  delayMicroseconds( 80 );

  res = digitalRead( pin );

  if ( !res )
  {
    errorCode[ 0 ] = 3; //dht11 read start error
    errorCode[ 1 ] = 2; //subcode 2
    cmdData[ 0 ] = CMD_NOP;
    return 1; // cmd data length
  }

  delayMicroseconds( 80 );

  for ( byte i = 0; i < 5; ++i )
  {
    if ( !readByte( cmdData + i + 1 ) )
    {
      errorCode[ 0 ] = 4; //dht11 read timeout error
      errorCode[ 1 ] = 0; //no subcode
      cmdData[ 0 ] = CMD_NOP;
      // restore pin OUTPUT state here?
      return 1; // cmd data length
    }
  }
  // and restore pin OUTPUT state here?

  byte checksum = cmdData[ 1 ] + cmdData[ 2 ] + cmdData[ 3 ] + cmdData[ 4 ];
  if ( checksum != cmdData[ 5 ] )
  {
    errorCode[ 0 ] = 5; //dht11 checksum error
    errorCode[ 1 ] = 0; //no subcode
    cmdData[ 0 ] = CMD_NOP;
    return 1; // cmd data length
  }

  //if we're here means we have correct data and have no errors
  //let's form the shortened response
  //bytes pointed by cmdData by index:
  // 0 - Cmd number
  // 1 - Humidity integer part
  // 2 - Humidity fraction part
  // 3 - Temperature integer part
  // 4 - Temperature fraction part

  //we need integer parts only
  cmdData[ 2 ] = cmdData[ 3 ];
  return 3; // result cmd data length
}

bool DHT11::readByte( byte* b )
{
  unsigned long loops;
  unsigned long maxLoops = microsecondsToClockCycles( 100 ) / 16;

  *b = 0;
  for ( byte i = 0; i < 8; --i )
  {
    loops = 0;
    while ( digitalRead( pin ) == LOW )
    {
      if ( ++loops == maxLoops )
      {
        return false;
      }
    }

    delayMicroseconds( 45 );

    if ( digitalRead( pin ) == HIGH )
    {
      *b |= 1 << i;
    }

    loops = 0;
    while ( digitalRead( pin) == HIGH )
    {
      if ( ++loops = maxLoops )
      {
        return false;
      }
    }
  }

  //byte is ready
  return true;
}

} // namspace salad
