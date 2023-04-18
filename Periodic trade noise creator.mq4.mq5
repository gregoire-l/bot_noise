//+------------------------------------------------------------------+
//|                                 Periodic trade noise creator.mq4 |
//|                                          Copyright 2023 Gregoire |
//|                                                                  |
//+------------------------------------------------------------------+
#property strict
//--- input parameters
input int      interval_min=240;
input int      interval_max=300;
input int      duration=1;
input double    stop_loss=0.1;
input double    lot_size=0.1;
input datetime        time_min = "8:00";
input datetime        time_max = "8:00";

#define ST_WAITING 0
#define ST_TIMEOUT -1
#define ST_ORDERED 1

int   interval_diff;
int   state;
int   ticket;

//+------------------------------------------------------------------+
//| TODO:
//| Random time interval

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   interval_diff = interval_max - interval_min;
   datetime now = TimeCurrent();

   state = ST_WAITING;
   ticket = 0;
   MathSrand(GetTickCount());
//--- create timer with random
   setNormalTimer();

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setNormalTimer()
  {
   int time = interval_min + MathRand()%interval_diff;
   Print("Waiting ",time," before putting smallest order");
   state = ST_WAITING;
   EventSetTimer(time);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void timerNormal()
  {
   double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   Print("Minimum Stop Level=",minstoplevel," points");
   double price=Ask;
//--- calculated SL and TP prices must be normalized
   double stoploss=NormalizeDouble(Bid-minstoplevel*Point,Digits);
   double takeprofit=NormalizeDouble(Bid+minstoplevel*Point,Digits);
//--- place market order to buy 1 lot
   //ticket = OrderSend(Symbol(),OP_BUY,lot_size,price,3,stoploss,takeprofit,"",0,0);
   if(ticket<0)
     {
      Print("OrderSend failed with error #",GetLastError());
      Alert("OrderSend failed with error #",GetLastError());
      setNormalTimer();

     }
   else
     {
      Print("OrderSend placed successfully");
      Print("Waiting ", duration, "min before closing trade");
      state = ST_ORDERED;
      EventSetTimer(duration);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void timerOrder()
  {
   if(ticket <= 0)
      return;
   double price = Ask;
   ticket = OrderClose(ticket, lot_size, price, 3);
   if(ticket < 0)
     {
      Print("Error closing ticket");
      Alert("Error closing trade, please review");
     }
   setNormalTimer();

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---//--- get minimum stop level
   EventKillTimer();
   if(state == ST_ORDERED)
      timerOrder();
   else
      if(state == ST_WAITING)
         timerNormal();
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
