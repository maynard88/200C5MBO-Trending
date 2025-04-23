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

     //SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID , 2, clrGray);
     //SetIndexBuffer(0, VIXFIX);
     
     
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

int start()
{
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
         
         //VIXFIX[pos] = - wvf;
         
         if (cmsLongCondition)
         {
            BottomSignal[pos] = -wvf;
            BottomGray[pos] = EMPTY_VALUE;
         }
         else
         {
            BottomGray[pos] = -wvf;          
         }
   
         pos--;
     }
     
     
     return (0);
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
      wvf = 100 * (Max - Low[pos]) / Max;
      output[pos] = wvf;
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
