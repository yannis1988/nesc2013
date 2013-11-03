/**
 *
 * 
 */
#include "UART1MSG.h"
#include "Rece.h"
//#include "printf.h"
module UART1C 
{
  provides
  {
    interface Msp430UartConfigure; 
  }

  uses 
  {
    interface Leds;
    interface Boot;
   
    //interface HplMsp430Usart as Usart;
    //interface HplMsp430UsartInterrupts as Interrupts;
    interface Timer<TMilli> as Timer; 

    interface AMSend;
    interface SplitControl as AMControl;
    interface Packet;


	//new added
    interface Resource;
    interface UartStream;

    //interface AMSend;
    //interface SplitControl as AMControl;
  }
}


implementation 
{
  message_t packet;
  //radio_uart0_msg_t * uart_msg;
  ReceMsg * rece;
  uint8_t recdata[10]; //接收数据存储
  uint8_t nreading = 0; //接收计数
  uint16_t counter = 0;//包计数
  uint8_t i = 0;
  uint8_t j = 0;
  uint8_t k = 0;
  //uint8_t isAMStart = 0;
  uint8_t isBufFull = 0;

  uint8_t isUartDataOk = 0;
  uint8_t rcvSyncDataSum = 0;//receive 0x20, 0x70, 0x70, 0x6D, 0x0D, 0x0A
  uint8_t SyncData[SYNC_DATA_SUM] = {0x6D, 0x0D, 0x0A};  //sync data  
  //uint8_t SyncData[SYNC_DATA_SUM] = {0x70, 0x70, 0x6D, 0x0D, 0x0A};  //sync data
  //uint8_t SyncData[SYNC_DATA_SUM] = {0x0D, 0x0A};  //sync data
 
  uint16_t noDataTime = 0;

  uint8_t flag = 0;
  uint8_t recX[4];
  uint8_t recY[4];
  uint8_t recZ[4];
  uint8_t recA[3];
  uint8_t recB[3];
  uint8_t recC[3];

  bool busy = FALSE;
  uint8_t flagX;
  uint8_t flagY;
  uint8_t flagZ;
  uint8_t flagA;
  uint8_t flagB;
  uint8_t flagC;
  //int8_t acc[3];
  int16_t data_x = 0;
  int16_t data_y = 0;
  int16_t data_z = 0;
  int16_t data_A = 0;
  int16_t data_B = 0;
  int16_t data_C = 0;

  task void sendTask();
  /*void GetX();
  void GetY();
  void GetZ();
*/
  //串口初始化配置
  msp430_uart_union_config_t config1 = {
    {utxe : 1, 
     urxe : 1, 
     ubr : UBR_1MHZ_38400, //Baud rate (use enum msp430_uart_rate_t for predefined rates)  //38400
     umctl : UMCTL_1MHZ_38400, //Modulation (use enum msp430_uart_rate_t for predefined rates)
     ssel : 0x02,        //Clock source (00=UCLKI; 01=ACLK; 10=SMCLK; 11=SMCLK)
     pena : 0,           //Parity enable (0=disabled; 1=enabled)
     pev : 0,            //Parity select (0=odd; 1=even)
     spb : 0,            //Stop bits (0=one stop bit; 1=two stop bits)
     clen : 1,           //Character length (0=7-bit data; 1=8-bit data)
     listen : 0,         //Listen enable (0=disabled; 1=enabled, feed tx back to receiver)
     mm : 0,             //Multiprocessor mode (0=idle-line protocol; 1=address-bit protocol)
     ckpl : 0,            //Clock polarity (0=normal; 1=inverted)
     urxse : 0,           //Receive start-edge detection (0=disabled; 1=enabled)
     urxeie : 0,          //Erroneous-character receive (0=rejected; 1=recieved and URXIFGx set)
     urxwie : 0,          //Wake-up interrupt-enable (0=all characters set URXIFGx; 1=only address sets URXIFGx)     
     utxe : 0,            // 1:enable tx module
     urxe : 1             // 1:enable rx module
    }
  };
   

  void reboot()
  {
     WDTCTL = 0;
     while(1);
  }


  event void Boot.booted() 
  {       
       call  Leds.led0On(); 
	   //new added
       call AMControl.start();
       call Resource.request();
  }  


  event void AMControl.startDone(error_t err) 
  {

    if (err == SUCCESS) 
    {     
	   //comment this line when not use timer      
       //call Timer.startPeriodic(Default_Interval);
       //call Timer.startPeriodic(1000);	
    }
    else 
    {
        //call AMControl.start();
    }
  }

  event void Resource.granted()
  {

  }

   event void Timer.fired() 
   { 

   }

   async event void UartStream.sendDone( uint8_t* buf, uint16_t len, error_t errors )
   {

   }

   async event void UartStream.receiveDone(uint8_t* buff, uint16_t lenn, error_t errorr)
   {
   
   }

   async command msp430_uart_union_config_t* Msp430UartConfigure.getConfig()
   {
         return &config1;
   }
   
   void GetX(){
    uint16_t data0;
    data0 = (recX[0]-48)*1000+(recX[1]-48)*100+(recX[2]-48)*10+(recX[3]-48);
    if (flagX == 0){
    data_x = data0;
    }else if (flagX == 1){
    data_x = -data0;
    }
    }
    void GetY(){
    uint16_t data1;
    data1 = (recY[0]-48)*1000+(recY[1]-48)*100+(recY[2]-48)*10+(recY[3]-48);
    if (flagY == 0){
    data_y = data1;
    }else if (flagY == 1){
    data_y = -data1;
    }
    }
    void GetZ(){
    uint16_t data2;
    data2 = (recZ[0]-48)*1000+(recZ[1]-48)*100+(recZ[2]-48)*10+(recZ[3]-48);
    if (flagZ == 0){
    data_z = data2;
    }else if(flagZ == 1){
    data_z = -data2;
    }
    }
    void GetA(){
    uint16_t data3;
    data3 = (recA[0]-48)*100+(recA[1]-48)*10+(recA[2]-48);
    if (flagA == 0){
    data_A = data3;
    }else if (flagA == 1){
    data_A = -data3;
    }
    }
    void GetB(){
    uint16_t data4;
    data4 = (recB[0]-48)*100+(recB[1]-48)*10+(recB[2]-48);
    if (flagB == 0){
    data_B = data4;
    }else if (flagB == 1){
    data_B = -data4;
    }
    }
    void GetC(){
    uint16_t data5;
    data5 = (recC[0]-48)*100+(recC[1]-48)*10+(recC[2]-48);
    if (flagC == 0){
    data_C = data5;
    }else if (flagC == 1){
    data_C = -data5;
    }
    }
   //中断接收事件
   async event void UartStream.receivedByte( uint8_t data )
   {

        call Leds.led1Toggle();  
	
        if (flag == 1){
         if (data == '+'){
	 flagX = 0;
	 return;
	 }else if(data == '-'){
	 flagX = 1;
	 return;
	 }else if (data == 'B'){
	   //j = 0;
           GetX();
	   flag = 2;
	   return;
	 }else{
          if(j<4){
	  if (data == '.'){
	  return;
	  }
            recX[j] = data;           	    
	    j++;	    
	  }else{
	  j = 0;
	  return;
	  }
	  }		
	}else if (flag == 2){
          if (data == '+'){
	  flagY = 0;
	  return;
	  }else if (data == '-'){
	  flagY = 1;
	  return;
	  }else if (data == 'C'){
	  //j = 0;
	  GetY();
	  flag = 3;
	  return;
	  }else{	  
	  if(j<4){	    
	   if (data == '.'){
	   return;
	   }
            recY[j] = data;           	    
	    j++;
	    
	  }else{
	  j = 0;
	  return;
	  }
          }
	}else if(flag == 3){
	if (data == '+'){
	flagZ = 0;
	return;
	}else if (data == '-'){
	flagZ = 1;
	return;
	}else if (data == 'X'){
        //j = 0;
	GetZ();
	flag = 4;
	return;
        //post sendTask();
	}else{
	if(j<4){	    
	    if (data == '.'){
	    return;
	    }
            recZ[j] = data;           	    
	    j++;	    
	}else{	
	j = 0;
	return;
	}
	}	
	}else if (flag == 4){
          if (data == '+'){
	  flagA = 0;
	  return;
	  }else if (data == '-'){
	  flagA = 1;
	  return;
	  }else if (data == 'Y'){
	  j = 0;
	  GetA();
	  flag = 5;
	  return;
	  }else{
	  if(j<3){
	  recA[j] = data;
	  j++;	  
	  }
	  }
	  }else if (flag == 5){ 
          if (data == '+'){
	  flagB = 0;
	  return;
	  }else if (data == '-'){
	  flagB = 1;
	  return;
	  }else if (data == 'Z'){
	  j = 0;
	  GetB();
	  flag = 6;
	  return;
	  }else{
	  if (j<3){
	  recB[j] = data;
	  j++;
	  
	  }
	  }
	  }else if (flag == 6){
	  if (data == '+'){
	  flagC = 0;
	  return;
	  }else if (data == '-'){
	  flagC = 1;
	  return;
	  }else if (data == '\n'){
	  j = 0;
	  GetC();
	  flag = 0;
	  post sendTask();
	  }else{
	  if (j<3){
	  recC[j] = data;
	  j++;
	  
	  }
	  }
	  }

	if (data == 'A'){
           flag = 1;	   	   
	}else{
	return;
	}
	/*if (data == 88){
         //  call Leds.led2Toggle();
         rece = (ReceMsg*)call Packet.getPayload(&packet, sizeof(ReceMsg));
	if (rece == NULL){
            return;
	}
        rece->data = data;
	if (!busy){
	if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(ReceMsg)) == SUCCESS){
           busy = TRUE;
	}
	}
	}else{
         //call Leds.led2Toggle();
	}*/
   }
    
task void sendTask()
{
   //uint8_t data;
   rece = (ReceMsg*)call Packet.getPayload(&packet, sizeof(ReceMsg));
	if (rece == NULL){
            return;
	}

    rece->dataX = data_x;
    rece->dataY = data_y;
    rece->dataZ = data_z;
    rece->dataA = data_A;
    rece->dataB = data_B;
    rece->dataC = data_C;
    if (!busy){
	if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(ReceMsg)) == SUCCESS){
           busy = TRUE;
	}
	} 
}

   event void AMSend.sendDone(message_t* msg, error_t error)
   {   
      //call Leds.led2Toggle();  
      if (&packet == msg){
      busy = FALSE;
      }
   }  


  event void AMControl.stopDone(error_t err) 
  { 

  }

}




