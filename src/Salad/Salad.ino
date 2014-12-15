#include <Wire.h> //this include is necessary to avoid strange bahaviour (in fact Wire.h include is only needed in EApp.h)
#include "EApp.h"

void setup() 
{
  salad::EApp::setup();
}

void loop()
{
  salad::EApp::iterateLoop();
}
