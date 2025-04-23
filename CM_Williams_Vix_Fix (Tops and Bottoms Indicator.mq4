//@version=5
// This is a modification of CM_Williams_Vix_Fix indicator to include both market tops and bottoms with multi-timeframe support. All credits go to the original author.
// Original script https://www.tradingview.com/script/og7JPrRA-CM-Williams-Vix-Fix-Finds-Market-Bottoms/
indicator("CM_Williams_Vix_Fix - Market Top and Bottom", overlay=false, timeframe="", timeframe_gaps=true)
pd = input(22, title="LookBack Period Standard Deviation High")
bbl = input(20, title="Bollinger Band Length")
mult = input.float(2.0, minval=1, maxval=5, title="Bollinger Band Standard Devaition Up")
lb = input(50  , title="Look Back Period Percentile High")
ph = input(.85, title="Percentile - 0.90=90%, 0.95=95%, 0.99=99%")

// Original code to find bottom
wvf = ((ta.highest(close, pd)-low)/(ta.highest(close, pd)))*100

sDev = mult * ta.stdev(wvf, bbl)
midLine = ta.sma(wvf, bbl)
lowerBand = midLine - sDev
upperBand = midLine + sDev

rangeHigh = (ta.highest(wvf, lb)) * ph


// Code to find top
wvf1 = ((ta.lowest(close, pd)-high)/(ta.lowest(close, pd)))*100

sDev1 = mult * ta.stdev(wvf1, bbl)
midLine1 = ta.sma(wvf1, bbl)
lowerBand1 = midLine1 - sDev1
upperBand1 = midLine1 + sDev1

rangeLow1 = (ta.lowest(wvf1, lb)) * ph

col = wvf >= upperBand or wvf >= rangeHigh ? color.red : color.gray
col1 = wvf1 <= lowerBand1 or wvf1 <= rangeLow1 ? color.lime: color.gray

// Alerts added
topAlert = (col[0] == color.lime) and (col[1] == color.gray)
bottomAlert = (col[0] == color.red) and (col[1] == color.gray)

alertcondition(topAlert, "Top", "Top reached")
alertcondition(bottomAlert, "Bottom", "Bottom reached")

hline(0, "Zero Line", color=color.new(#787B86, 50))
plot(-1 * wvf, title="Market Bottom", style=plot.style_columns, linewidth = 4, color=col)
plot(-1 * wvf1, title="Market Top", style=plot.style_columns, linewidth = 4, color=col1)