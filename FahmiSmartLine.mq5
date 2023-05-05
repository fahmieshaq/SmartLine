//+------------------------------------------------------------------+
//|                                                  MySmartLine.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

// Developed by Fahmi Eshaq May 5, 2023

double lastClosePrice = 0.0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   // Shows up on your chart at top left corner
   ChartSetString(ChartID(), CHART_COMMENT, "Fahmi's SmartLine Indicator");
//---
   return(INIT_SUCCEEDED);
  }
  
  //+------------------------------------------------------------------+
//| A handler of the Deinit event                                    |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  // Clearing comments may take few seconds to clear up depending on the processing time.
   ChartSetString(ChartID(), CHART_COMMENT, "");
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
//---
   string objName = "";

   for(int i = ObjectsTotal(0)-1; i >= 0; i--)
     {
      objName = "";
      objName = ObjectName(0, i);


      //======================== Checking Trend Line ================================
      if(ObjectGetInteger(0, objName, OBJPROP_TYPE) == OBJ_TREND)
        {
         if(currentCandleTouchedTrendLine(objName))
           {
            Alert(Symbol() + " | Touched Trend Line: " + objName);
           }
        }

      //======================== Checking Horizontal Line ==========================
      if(ObjectGetInteger(0, objName, OBJPROP_TYPE) == OBJ_HLINE)
        {
         if(currentCandleTouchedHorizontalLine(objName))
           {
            Alert(Symbol() + " | Touched Horizontal Line: " + objName);
           }
        }

      //======================== Checking Rectangle ================================
      if(ObjectGetInteger(0,objName,OBJPROP_TYPE)== OBJ_RECTANGLE)
        {
         if(currentCandleTouchedRectangular(objName))
           {
            Alert(Symbol() + " | Touched Rectangular Border: " + objName);
           }
        }
     }

   lastClosePrice = iClose(Symbol(), PERIOD_CURRENT, 0);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Custom Functions                                                 |
//+------------------------------------------------------------------+
// Catch horizontal line
bool currentCandleTouchedHorizontalLine(string objName)
  {
   if(ObjectFind(0,objName)!=-1)
     {
      double horizPrice = ObjectGetDouble(ChartID(),objName,OBJPROP_PRICE);
      double currentPrice = iClose(Symbol(), PERIOD_CURRENT, 0);

      if(lastClosePrice > 0 && horizPrice > 0)
        {
         bool isCandleCrossedHlDownward = (currentPrice < horizPrice)
                                          && (lastClosePrice >= horizPrice);
         bool isCandleCrossedHlUpward = (currentPrice > horizPrice)
                                        && (lastClosePrice <= horizPrice);

         if(isCandleCrossedHlDownward || isCandleCrossedHlUpward)
            return true;
        }
     }

   return false;
  }

// Catch trend line
bool currentCandleTouchedTrendLine(string objName)
  {
   if(ObjectFind(0,objName)!=-1)
     {
      double trendlinePrice = ObjectGetValueByTime(ChartID(), objName, iTime(Symbol(), PERIOD_CURRENT, 0));
      datetime trendLineTime = (datetime)ObjectGetInteger(ChartID(),objName,OBJPROP_TIME,1);
      double currentPrice = iClose(Symbol(), PERIOD_CURRENT, 0);
      
      // First, sometimes the trendline value gives 0 in return specially when we just place EA on the chart. So it start giving alert unnecessarily. So Added A check for that if the trendline value is 0 dont move forward
      // Second, once the candle passe the last point of trendline. The point in extreme right. If the current time have passed that time. We wont give alert as well
      if(lastClosePrice > 0 && TimeCurrent() <= trendLineTime && trendlinePrice > 0)
        {
         bool isCandleCrossedTrendlineDownward = (currentPrice < trendlinePrice)
                                                 && (lastClosePrice >= trendlinePrice);
         bool isCandleCrossedTrendlineUpward = (currentPrice > trendlinePrice)
                                               && (lastClosePrice <= trendlinePrice);


         if(isCandleCrossedTrendlineDownward || isCandleCrossedTrendlineUpward)
            return true;
        }
     }

   return false;
  }

// Catch candles that touch rectangle borders
bool currentCandleTouchedRectangular(string objName)
  {
   if(ObjectFind(0,objName)!=-1)
     {
      double rectTopRectPrice = ObjectGetDouble(ChartID(),objName,OBJPROP_PRICE, 1);
      double rectBottomRectPrice = ObjectGetDouble(ChartID(),objName,OBJPROP_PRICE, 3);
      if(lastClosePrice > 0 && rectTopRectPrice > 0 && rectBottomRectPrice > 0)
        {
         bool isCandleCrossedSmartLineDownwardTopRectPrice = (iClose(Symbol(), PERIOD_CURRENT, 0) < rectTopRectPrice)
               && (lastClosePrice >= rectTopRectPrice);
         bool isCandleCrossedSmartLineUpwardTopRectPrice = (iClose(Symbol(), PERIOD_CURRENT, 0) > rectTopRectPrice)
               && (lastClosePrice <= rectTopRectPrice);

         bool isCandleCrossedSmartLineDownwardBottomRectPrice = (iClose(Symbol(), PERIOD_CURRENT, 0) < rectBottomRectPrice)
               && (lastClosePrice >= rectBottomRectPrice);
         bool isCandleCrossedSmartLineUpwardBottomRectPrice = (iClose(Symbol(), PERIOD_CURRENT, 0) > rectBottomRectPrice)
               && (lastClosePrice <= rectBottomRectPrice);

         bool isTouchedRectBorder = isCandleCrossedSmartLineDownwardTopRectPrice || isCandleCrossedSmartLineUpwardTopRectPrice
                                    || isCandleCrossedSmartLineDownwardBottomRectPrice || isCandleCrossedSmartLineUpwardBottomRectPrice;
         bool currentPriceWithinRect = iClose(Symbol(), PERIOD_CURRENT, 0) < rectTopRectPrice && iClose(Symbol(), PERIOD_CURRENT, 0) > rectBottomRectPrice;

         if(currentPriceWithinRect)
            return false;

         if(isTouchedRectBorder)
            return true;
        }
     }

   return false;
  }

//+------------------------------------------------------------------+
