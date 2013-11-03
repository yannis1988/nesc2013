#ifndef RECE_H
#define RECE_H

enum {
  AM_BLINKTORADIO = 6,
  DATA = 4,
  //TIMER_PERIOD_MILLI = 1000
};

typedef nx_struct ReceMsg {
  //nx_uint16_t nodeid;
  nx_int16_t dataX;
  nx_int16_t dataY;
  nx_int16_t dataZ;
  nx_int16_t dataA;
  nx_int16_t dataB;
  nx_int16_t dataC;
} ReceMsg;

#endif
