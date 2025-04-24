//+------------------------------------------------------------------+
//|                  CM_Williams_Vix_Fix - Market Top and Bottom.mq4 |
//|                                   Copyright © 2024, Maynard Paye |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2024, Maynard Paye"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Lime    // Market Bottom signal
#property indicator_color2 Gray   // Market Bottom no signal
#property indicator_color3 Red   // Market Top signal
#property indicator_color4 Gray   // Market Top no signal

extern int pd = 22;
extern int bbl = 20;
extern double mult = 2.0;
extern int lb = 50;
extern double ph = 0.85;


double BottomSignal[];
double BottomGray[];

double TopSignal[];
double TopGray[];

int init()
{
     IndicatorShortName("William Vix-Fix");
     IndicatorDigits(Digits);

     SetIndexBuffer(0, BottomSignal);
     SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 2, clrLimeGreen);

     SetIndexBuffer(1, BottomGray);
     SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, 2, clrGray);
 
     SetIndexBuffer(2, TopSignal);
     SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_SOLID, 2, clrRed);

     SetIndexBuffer(3, TopGray);
     SetIndexStyle(3, DRAW_HISTOGRAM, STYLE_SOLID, 2, clrGray);

     

     return (0);
}

int deinit()
{
   return (0);
}

/*

int start()
{
     static datetime lastTime = 0;
     
     // Only proceed on new candle
    if (Time[0] == lastTime)
        return 0;
        
     lastTime = Time[0];
     
     
     if (Bars <= pd)
          return (0);
     int ExtCountedBars = IndicatorCounted();
     if (ExtCountedBars < 0)
          return (-1);
     int limit = Bars - 2;
     if (ExtCountedBars > 2)
          limit = Bars - ExtCountedBars - 1;
          
     int pos;     
     double Max; 
     double wvf;
     double sDev;   
     double midLine;
     double lowerBand;
     double upperBand;
     double rangeHigh;
     double rangeLow; 
     pos = limit;

    
     double wvfHolder[];
     GetWVf(wvfHolder, pos);
     
     double wvf1Holder[];
     //GetWVf(wvfHolder, pos)
     
     // pos = 0 is the latest bar
     while (pos >= 0)
     {
         // wvf
         Max = Close[iHighest(NULL, 0, MODE_CLOSE, pd, pos)];
         wvf = 100 * (Max - Low[pos]) / Max;
         
         // midline
         midLine = SimpleMA(wvfHolder, pos, bbl);
         
         // sDev
         sDev = mult * CalculateStd(wvfHolder, pos, bbl, midLine);
         
         lowerBand = midLine - sDev;        
         upperBand = midLine + sDev;  
              
         rangeHigh = ph * GetWvfHighest(wvfHolder, pos, lb);
         
         bool cmsLongCondition = wvf >= upperBand || wvf >= rangeHigh;
           
         if (cmsLongCondition)
         {
            BottomSignal[pos] = -wvf;
            BottomGray[pos] = EMPTY_VALUE;
         }
         else
         {
            BottomGray[pos] = -wvf;          
         }
         
         
         // wvf1
         //Max = Close[iLowest(NULL, 0, MODE_CLOSE, pd, pos)];
         //wvf1 = 100 * (Max - High[pos]) / Max;
         
         
         
         
   
         pos--;
     }
     
     
     return (0);
}

*/


int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   
   int limit = rates_total - prev_calculated;
   if (limit > rates_total - 1)
      limit = rates_total - 1;
   if (limit < 0)
      return 0;
      
   int startBar = prev_calculated > 1 ? prev_calculated - 1 : 0;
   
   double Max; 
   double Lw;
   double wvf;
   double wvf1;
   double sDev;
    double sDev1;   
   double midLine;
   double midLine1;
   double lowerBand;
   double lowerBand1;
   double upperBand;
   double upperBand1;
   double rangeHigh;
   double rangeLow1; 
   
   
   static datetime lastTime = 0;
     
     // Only proceed on new candle
   if (Time[0] == lastTime)
        return 0;
        
   lastTime = Time[0];  
   
   
   
   double wvfHolder[];
   GetWVf(wvfHolder, limit);
   
   double wvfHolder1[];
   GetWVf1(wvfHolder1, limit);
   
   // pos = 0 is the latest bar
   for (int pos = limit; pos >= 0; pos--)
   {
      // wvf
      Max = Close[iHighest(NULL, 0, MODE_CLOSE, pd, pos)];
      wvf = (Max - Low[pos]) / Max * 100;
      
      // midline
      midLine = SimpleMA(wvfHolder, pos, bbl);
      
      // sDev
      sDev = mult * CalculateStd(wvfHolder, pos, bbl, midLine);
      
      lowerBand = midLine - sDev;        
      upperBand = midLine + sDev;  
           
      rangeHigh = ph * GetWvfHighest(wvfHolder, pos, lb);
      
      bool cmsLongCondition = wvf >= upperBand || wvf >= rangeHigh;
        
      if (cmsLongCondition)
      {
         BottomSignal[pos] = -wvf;
         BottomGray[pos] = EMPTY_VALUE;
      }
      else
      {
         BottomGray[pos] = -wvf;          
      }
      
      //---------------------------------------------//
      
      // wvf1
      Lw = Close[iLowest(NULL, 0, MODE_CLOSE, pd, pos)];
      wvf1 = (Lw - High[pos]) / Lw * 100;
      
      // midline1
      midLine1 = SimpleMA(wvfHolder1, pos, bbl);
      
      // sDev1
      sDev1 = mult * CalculateStd(wvfHolder1, pos, bbl, midLine);
      
      lowerBand1 = midLine1 - sDev1;        
      upperBand1 = midLine1 + sDev1; 
      
      rangeLow1 = ph * GetWvf1Lowest(wvfHolder1, pos, lb);
      
      bool cmsShortCondition = wvf1 <= lowerBand1 || wvf1 <= rangeLow1;
        
      if (cmsShortCondition)
      {
         TopSignal[pos] = -wvf1;
         TopGray[pos] = EMPTY_VALUE;
      }
      else
      {
         TopGray[pos] = -wvf1;          
      }
      
   }
   
   return (rates_total);
}


//+------------------------------------------------------------------+
// Original code to find bottom : wvf                                |
//+------------------------------------------------------------------+
void GetWVf(double &output[], int pos)
{
   ArrayResize(output, pos); 
   double Max, wvf;

   while (pos >= 0)
   {
      Max = Close[iHighest(NULL, 0, MODE_CLOSE, pd, pos)];
      wvf =  (Max - Low[pos]) / Max * 100;
      output[pos] = wvf;
      pos--;
   }
}


//+------------------------------------------------------------------+
// Original code to find top : wvf1                                  |
//+------------------------------------------------------------------+
void GetWVf1(double &output[], int pos)
{
   ArrayResize(output, pos); 
   double Lw, wvf1;

   while (pos >= 0)
   {
      Lw = Close[iLowest(NULL, 0, MODE_CLOSE, pd, pos)];
      wvf1 =  (Lw - High[pos]) / Lw * 100;
      output[pos] = wvf1;
      pos--;
   }
}


//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
double SimpleMA(double src[], int pos, int length)
{
   double sum = 0;
   for (int i = 0; i < length; i++)
   {
      sum += src[pos + i];
   }
   return sum / length;
}

//+------------------------------------------------------------------+
//| Calculate Standard Deviation                                     |
//+------------------------------------------------------------------+
double CalculateStd(double src[], int pos, int length, double avg)
{

   double sum = 0;
   double sumSquaredDiffs = 0;

   // Summation (Xi - X)^2
   for (int j = 0; j < length; j++) {
      double diff = src[pos + j] - avg;
      sumSquaredDiffs += diff * diff;
   }
   
   return MathSqrt(sumSquaredDiffs / length);
   
}


//+------------------------------------------------------------------+
// Get wvf Highest given lenght bars back                                |
//+------------------------------------------------------------------+
double GetWvfHighest(double src[], int pos, int length)
{
   double highest = 0;
   for (int i = 0; i < length; i++)
   {
      if (src[pos + i] > highest)
         highest = src[pos + i];      
   }
   return highest;
}

//+------------------------------------------------------------------+
// Get wvf1 Lowest given lenght bars back                                |
//+------------------------------------------------------------------+
double GetWvf1Lowest(double src[], int pos, int length)
{
   double lowest = src[pos];
   for (int i = 0; i < length; i++)
   {
      if (src[pos + i] < lowest)
         lowest = src[pos + i];      
   }
   return lowest;
}

