
#ifndef UART1_MSG_H
#define UART1_MSG_H

enum {
   AM_RADIO_COUNT_MSG = 0x93,
   Default_Interval = 512, //采样周期
   //Default_Interval = 4000,
   Nreading = 10,
   SYNC_DATA_SUM = 3,
   MAX_NODATA_TIME = 30
};
typedef nx_struct radio_count_msg {
  nx_uint16_t interval;
  nx_uint16_t version;
  nx_uint16_t moteid;
  nx_uint16_t counter;
  nx_uint8_t reading[Nreading];
} radio_uart0_msg_t;

#endif
