#include "Salad.h"
#include "SaladConfig.h"

namespace salad
{

Salad::Salad()
  : mI(8)
{
}

Salad::~Salad()
{
}

const int Salad::getI() const
{
  return mI;
}
void Salad::setI(const int i)
{
  mI = i;
}

}

