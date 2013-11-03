//#include "printf.h"

configuration UART1AppC {}
implementation {
  components MainC, UART1C as App, LedsC, HplMsp430GeneralIOC;  
  //components HplMsp430Usart0C;  
  components new TimerMilliC();
  components new AMSenderC(AM_BLINKTORADIO);

  App.Boot -> MainC.Boot;  
  App.Leds -> LedsC;   
  //App.Usart->HplMsp430Usart0C;
  //App.Interrupts->HplMsp430Usart0C;
  App.Timer -> TimerMilliC;
  components ActiveMessageC;
  
  //components new AMSenderC(AM_RADIO_COUNT_MSG);
  
  //App.AMSend -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.Packet -> AMSenderC;



  //new added
  components new Msp430Uart1C() as uart1; 
  uart1.Msp430UartConfigure -> App.Msp430UartConfigure;
  App.Resource -> uart1; 
  App.UartStream->uart1;

  App.AMSend -> AMSenderC;

}


