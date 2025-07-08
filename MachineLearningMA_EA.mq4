//+------------------------------------------------------------------+
//|                                    Machine Learning MA Strategy EA |
//|                                                           LuxAlgo  |
//|                                                                   |
//+------------------------------------------------------------------+
#property copyright "LuxAlgo"
#property link      ""
#property version   "1.00"
#property strict

//--- Input Parameters
extern int    Window = 100;           // Window size
extern int    Forecast = 3;           // Forecast period
extern double Sigma = 0.01;           // Sigma parameter
extern double Multiplier = 2.0;       // Multiplicative Factor
extern double LotSize = 0.1;          // Lot size for trading

//--- Global Variables
double K_row[];
double mean;
double out;
double mae;
double upper, lower;
int os = 0;
bool inLong = false;
bool inShort = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Initialize arrays
   ArrayResize(K_row, Window + Forecast);
   
   // Calculate kernel matrix on initialization
   CalculateKernelMatrix();
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Close all positions
   CloseAllPositions();
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Check if we have enough bars
   if(Bars < Window + Forecast) return;
   
   // Calculate moving average
   CalculateMA();
   
   // Calculate signals
   CalculateSignals();
   
   // Execute strategy
   ExecuteStrategy();
}

//+------------------------------------------------------------------+
//| Calculate RBF kernel value                                       |
//+------------------------------------------------------------------+
double RBF(double x1, double x2, double l)
{
   return MathExp(-MathPow(x1 - x2, 2) / (2.0 * MathPow(l, 2)));
}

//+------------------------------------------------------------------+
//| Calculate kernel matrix                                          |
//+------------------------------------------------------------------+
void CalculateKernelMatrix()
{
   // This is a simplified version - in practice you'd need a full matrix implementation
   // For now, we'll use a simplified approach
   
   // Initialize K_row with some default values
   for(int i = 0; i < Window + Forecast; i++)
   {
      K_row[i] = 1.0 / (Window + Forecast);
   }
}

//+------------------------------------------------------------------+
//| Calculate moving average and prediction                          |
//+------------------------------------------------------------------+
void CalculateMA()
{
   // Calculate simple moving average
   mean = 0;
   for(int i = 0; i < Window; i++)
   {
      mean += Close[i];
   }
   mean /= Window;
   
   // Calculate prediction using kernel
   double dotprod = 0.0;
   for(int i = 0; i < Window; i++)
   {
      dotprod += K_row[i] * (Close[Window - 1 - i] - mean);
   }
   out = dotprod + mean;
   
   // Calculate MAE
   double sum_mae = 0;
   for(int i = 0; i < Window; i++)
   {
      sum_mae += MathAbs(Close[i] - out);
   }
   mae = (sum_mae / Window) * Multiplier;
   
   // Calculate bands
   upper = out + mae;
   lower = out - mae;
}

//+------------------------------------------------------------------+
//| Calculate trading signals                                        |
//+------------------------------------------------------------------+
void CalculateSignals()
{
   static double prev_out = 0;
   
   // Calculate signal
   if(Close[0] > upper && out > prev_out)
   {
      os = 1;
   }
   else if(Close[0] < lower && out < prev_out)
   {
      os = 0;
   }
   
   prev_out = out;
}

//+------------------------------------------------------------------+
//| Execute trading strategy                                         |
//+------------------------------------------------------------------+
void ExecuteStrategy()
{
   static int prev_os = -1;
   
   // Check for signal change
   if(os != prev_os)
   {
      if(os == 1)  // Long signal
      {
         CloseAllPositions();
         OpenPosition(OP_BUY);
      }
      else if(os == 0)  // Short signal
      {
         CloseAllPositions();
         OpenPosition(OP_SELL);
      }
   }
   
   prev_os = os;
}

//+------------------------------------------------------------------+
//| Open a new position                                              |
//+------------------------------------------------------------------+
void OpenPosition(int type)
{
   double price = (type == OP_BUY) ? Ask : Bid;
   int ticket = OrderSend(Symbol(), type, LotSize, price, 3, 0, 0, "ML MA Strategy", 0, 0, clrNONE);
   
   if(ticket > 0)
   {
      Print("Position opened: ", (type == OP_BUY ? "BUY" : "SELL"), " Ticket: ", ticket);
   }
   else
   {
      Print("Error opening position: ", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| Close all open positions                                         |
//+------------------------------------------------------------------+
void CloseAllPositions()
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == 0)
         {
            double price = (OrderType() == OP_BUY) ? Bid : Ask;
            bool result = OrderClose(OrderTicket(), OrderLots(), price, 3, clrRed);
            
            if(result)
            {
               Print("Position closed: Ticket: ", OrderTicket());
            }
            else
            {
               Print("Error closing position: ", GetLastError());
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Custom functions for matrix operations (simplified)              |
//+------------------------------------------------------------------+
// Note: This is a simplified implementation. For production use,
// you would need a proper matrix library or implement full matrix operations.

//+------------------------------------------------------------------+
//| Draw bands on chart                                              |
//+------------------------------------------------------------------+
void DrawBands()
{
   string upper_name = "Upper_Band_" + Symbol();
   string lower_name = "Lower_Band_" + Symbol();
   string ma_name = "MA_Line_" + Symbol();
   
   // Draw upper band
   ObjectCreate(upper_name, OBJ_TREND, 0, Time[Window], upper, Time[0], upper);
   ObjectSet(upper_name, OBJPROP_COLOR, clrBlue);
   ObjectSet(upper_name, OBJPROP_WIDTH, 1);
   ObjectSet(upper_name, OBJPROP_RAY_RIGHT, true);
   
   // Draw lower band
   ObjectCreate(lower_name, OBJ_TREND, 0, Time[Window], lower, Time[0], lower);
   ObjectSet(lower_name, OBJPROP_COLOR, clrRed);
   ObjectSet(lower_name, OBJPROP_WIDTH, 1);
   ObjectSet(lower_name, OBJPROP_RAY_RIGHT, true);
   
   // Draw MA line
   ObjectCreate(ma_name, OBJ_TREND, 0, Time[Window], out, Time[0], out);
   ObjectSet(ma_name, OBJPROP_COLOR, clrGreen);
   ObjectSet(ma_name, OBJPROP_WIDTH, 2);
   ObjectSet(ma_name, OBJPROP_RAY_RIGHT, true);
} 