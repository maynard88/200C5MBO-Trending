//+------------------------------------------------------------------+
//|                                              William VIX-FIX.mq4 |
//|                                    Copyright © 2013, Marketcalls |
//|                                        http://www.marketcalls.in |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Marketcalls"
#property link "http://www.marketcalls.in"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red

extern int pd = 22;
extern int bbl = 20;
extern double mult = 2.0;
extern int lb = 50;
extern double ph = 0.85;


double VIXFIX[];
double VIXFIXSTD[];

int init()
{
     IndicatorShortName("William Vix-Fix");
     IndicatorDigits(Digits);

     SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID , 2, clrGray);
     SetIndexBuffer(0, VIXFIX);
     
     SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID , 2, clrRed);
     SetIndexBuffer(1, VIXFIXSTD);

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

     
      /*
     if (wvfSize > 0 ) 
     {
        for (int i = ArraySize(wvf) - 1; i >= 0; i--)
        {
            VIXFIX[i] = -1 * wvf[i];
        }
     }
     */
     
     
     // pos = 0 is the latest bar
     while (pos >= 0)
     {
         // wvf
         Max = Close[iHighest(NULL, 0, MODE_CLOSE, pd, pos)];
         wvf = 100 * (Max - Low[pos]) / Max;

         // midline
         midLine = SimpleMA(wvfHolder, pos, bbl);
         
         
         // Compute standard deviation manually using Pine-style logic
         //double avg = SimpleMA(pos, bbl);
         //sDev = mult * GetManualStdev(pos, bbl, avg, mult);

         //sDev = mult * iStdDev(NULL, 0, bbl, 0, MODE_SMA, wvf, pos);
         
          //midLine = iMA(NULL, 0, bbl, 0, MODE_SMA, wvf, pos);    
          //lowerBand = midLine - sDev;
          //upperBand = midLine + sDev;
          //rangeHigh = iMA(NULL, 0, lb, 0, MODE_SMA, wvf, pos) * ph;


          // Correct up to here //





          VIXFIXSTD[pos] = sDev;
          
          VIXFIX[pos] = midLine;
   
          pos--;
     }
     
     
     return (0);
}


//+------------------------------------------------------------------+
// Original code to find bottom : wvf
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

