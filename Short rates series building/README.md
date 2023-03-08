# Short risk free interest rates building
This code will attempt to build a time series for the US Government short term interest rate as far as it can go.

The result is a csv file called "us_short_term_rates.csv" with date, value (annualized nominal interest rate) and source

1- Actual treasury data 

Download this file https://fred.stlouisfed.org/series/TB3MS  (source = 2)

Download this file https://fred.stlouisfed.org/series/M1329AUSM193NNBR (source = 1)

2- Shiller's yearly data
Download http://www.econ.yale.edu/~shiller/data/chapt26.xls (source = 3)

FRED's data is mostly 3 to 6 months maturity. Shiller's data is 1 year maturity, and it is repeated every month because there is only one value per year.

See links for more data decription.
