//+------------------------------------------------------------------+
//|                                                   VixFixMTF.mq4  |
//|             Conversion of CM_Williams_Vix_Fix (Tops and Bottoms) |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Red      // Bottoms
#property indicator_color2 Lime     // Tops
#property indicator_color3 Gray     // Bottom - No Signal
#property indicator_color4 Gray     // Top - No Signal
#property strict

//--- Inputs
input int pd = 22;                // LookBack Period Standard Deviation High
input int bbl = 20;               // Bollinger Band Length
input double mult = 2.0;          // Bollinger Band Std Deviation Up
input int lb = 50;                // Look Back Period Percentile High
input double ph = 0.85;           // Percentile Multiplier

//--- Buffers
double BottomBuffer[];
double TopBuffer[];
double BottomColorBuffer[];
double TopColorBuffer[];

//--- Variables
double wvf[], wvf1[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorBuffers(6);
   SetIndexBuffer(0, BottomBuffer);
   SetIndexBuffer(1, TopBuffer);
   SetIndexBuffer(2, BottomColorBuffer);
   SetIndexBuffer(3, TopColorBuffer);
   SetIndexBuffer(4, wvf);
   SetIndexBuffer(5, wvf1);

   SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 2);
   SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, 2);
   SetIndexStyle(2, DRAW_NONE);
   SetIndexStyle(3, DRAW_NONE);

   IndicatorShortName("VixFix MTF - Tops and Bottoms");

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
   if(limit > rates_total - pd - lb)
      limit = rates_total - pd - lb;

   for(int i = limit - 1; i >= 0; i--)
     {
      // Calculate WVF for Bottom
      double highestClose = iHigh(NULL, 0, iHighest(NULL, 0, MODE_CLOSE, pd, i));
      if (highestClose != 0)
         wvf[i] = (highestClose - low[i]) / highestClose * 100.0;
      else
         wvf[i] = 0;

      // Calculate WVF1 for Top
      double lowestClose = iLow(NULL, 0, iLowest(NULL, 0, MODE_CLOSE, pd, i));
      if (lowestClose != 0)
         wvf1[i] = (lowestClose - high[i]) / lowestClose * 100.0;
      else
         wvf1[i] = 0;
     }

   // Calculate Bands and Plot
   for(int i = limit - 1; i >= 0; i--)
     {
      // --- Bottom Logic
      double midLine = iMAOnArray(wvf, 0, bbl, 0, MODE_SMA, i);
      double stdDev = mult * iStdDevOnArray(wvf, 0, bbl, 0, MODE_SMA, i);
      double upperBand = midLine + stdDev;
      double rangeHigh = ArrayMaximum(wvf, lb, i) * ph;

      if(wvf[i] >= upperBand || wvf[i] >= rangeHigh)
        {
         BottomBuffer[i] = -wvf[i];
         BottomColorBuffer[i] = 1; // Alert marker
         if(BottomColorBuffer[i+1] == 0)
            Alert("Bottom detected at ", TimeToString(Time[i]));
        }
      else
        {
         BottomBuffer[i] = -wvf[i];
         BottomColorBuffer[i] = 0;
        }

      // --- Top Logic
      double midLine1 = iMAOnArray(wvf1, 0, bbl, 0, MODE_SMA, i);
      double stdDev1 = mult * iStdDevOnArray(wvf1, 0, bbl, 0, MODE_SMA, i);
      double lowerBand1 = midLine1 - stdDev1;
      double rangeLow1 = ArrayMinimum(wvf1, lb, i) * ph;

      if(wvf1[i] <= lowerBand1 || wvf1[i] <= rangeLow1)
        {
         TopBuffer[i] = -wvf1[i];
         TopColorBuffer[i] = 1; // Alert marker
         if(TopColorBuffer[i+1] == 0)
            Alert("Top detected at ", TimeToString(Time[i]));
        }
      else
        {
         TopBuffer[i] = -wvf1[i];
         TopColorBuffer[i] = 0;
        }
     }

   return(rates_total);
  }

//+------------------------------------------------------------------+
