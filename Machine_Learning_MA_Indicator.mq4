//+------------------------------------------------------------------+
//|                                    Machine Learning MA Indicator.mq4 |
//|                                                           LuxAlgo |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "LuxAlgo"
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 clrBlue
#property indicator_color2 clrRed
#property indicator_color3 clrBlue
#property indicator_color4 clrRed

// Input parameters
extern int    Window = 100;
extern int    Forecast = 0;
extern double Sigma = 0.01;
extern double Multiplier = 2.0;
extern int    Source = PRICE_CLOSE;

// Indicator buffers
double ExtMapBuffer1[];  // Main MA line
double ExtMapBuffer2[];  // Upper band
double ExtMapBuffer3[];  // Lower band
double ExtMapBuffer4[];  // Signal circles

// Global variables
double K_row[];
double prev_out = 0;
int os_state = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   // Indicator buffers mapping
   SetIndexBuffer(0, ExtMapBuffer1);
   SetIndexBuffer(1, ExtMapBuffer2);
   SetIndexBuffer(2, ExtMapBuffer3);
   SetIndexBuffer(3, ExtMapBuffer4);
   
   // Set indicator labels
   SetIndexLabel(0, "Machine Learning MA");
   SetIndexLabel(1, "Upper Band");
   SetIndexLabel(2, "Lower Band");
   SetIndexLabel(3, "Signal");
   
   // Set drawing styles
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1);
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 1);
   SetIndexStyle(3, DRAW_ARROW, STYLE_SOLID, 1);
   
   // Set arrow codes
   SetIndexArrow(3, 159);
   
   // Initialize arrays
   ArrayResize(K_row, Window);
   
   // Calculate kernel matrix on initialization
   CalculateKernelMatrix();
   
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   return(0);
}

//+------------------------------------------------------------------+
//| RBF Kernel function                                              |
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
   // Calculate K_row for the last element (Window + Forecast - 1)
   for(int i = 0; i < Window; i++)
   {
      K_row[i] = RBF(Window + Forecast - 1, i, Window);
   }
}

//+------------------------------------------------------------------+
//| Get source price                                                 |
//+------------------------------------------------------------------+
double GetSourcePrice(int shift)
{
   switch(Source)
   {
      case PRICE_CLOSE: return Close[shift];
      case PRICE_OPEN: return Open[shift];
      case PRICE_HIGH: return High[shift];
      case PRICE_LOW: return Low[shift];
      case PRICE_MEDIAN: return (High[shift] + Low[shift]) / 2;
      case PRICE_TYPICAL: return (High[shift] + Low[shift] + Close[shift]) / 3;
      case PRICE_WEIGHTED: return (High[shift] + Low[shift] + Close[shift] + Close[shift]) / 4;
      default: return Close[shift];
   }
}

//+------------------------------------------------------------------+
//| Calculate Simple Moving Average                                  |
//+------------------------------------------------------------------+
double CalculateSMA(int shift, int period)
{
   double sum = 0;
   for(int i = 0; i < period; i++)
   {
      sum += GetSourcePrice(shift + i);
   }
   return sum / period;
}

//+------------------------------------------------------------------+
//| Calculate Mean Absolute Error                                    |
//+------------------------------------------------------------------+
double CalculateMAE(int shift, int period, double out_value)
{
   double sum = 0;
   for(int i = 0; i < period; i++)
   {
      sum += MathAbs(GetSourcePrice(shift + i) - out_value);
   }
   return (sum / period) * Multiplier;
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int limit = Bars - IndicatorCounted();
   
   // Main calculation loop
   for(int i = limit - 1; i >= 0; i--)
   {
      if(i < Window) continue;
      
      // Calculate mean
      double mean = CalculateSMA(i, Window);
      
      // Calculate dot product for GPR output
      double dotprod = 0;
      for(int j = 0; j < Window; j++)
      {
         dotprod += K_row[j] * (GetSourcePrice(i + Window - 1 - j) - mean);
      }
      
      // Calculate output
      double out = dotprod + mean;
      
      // Calculate MAE and bands
      double mae = CalculateMAE(i, Window, out);
      double upper = out + mae;
      double lower = out - mae;
      
      // Update state based on conditions
      int new_os = os_state;
      if(Close[i] > upper && out > prev_out)
         new_os = 1;
      else if(Close[i] < lower && out < prev_out)
         new_os = 0;
      
      // Plot values
      ExtMapBuffer1[i] = out;
      ExtMapBuffer2[i] = upper;
      ExtMapBuffer3[i] = lower;
      
      // Plot signal circles when state changes
      if(new_os != os_state)
      {
         ExtMapBuffer4[i] = out;
      }
      else
      {
         ExtMapBuffer4[i] = EMPTY_VALUE;
      }
      
      // Update state for next iteration
      os_state = new_os;
      prev_out = out;
   }
   
   return(0);
} 