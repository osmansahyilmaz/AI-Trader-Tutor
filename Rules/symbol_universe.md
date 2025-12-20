# symbol_universe.md — MVP tradable universe (Top 30 per asset class)

**Owner:** Osman Şah  
**Pack version:** v5.3  
**Date:** 2025-12-20

This file defines the ONLY symbols allowed in the MVP.  
The Flutter UI must populate the picker from `symbol_universe.json`.  
Backend must reject symbols outside the universe.

## Crypto (Binance Spot, USDT quoted) — 30 symbols
Format: `BTCUSDT`  
Provider: Binance Spot klines (public)

BTCUSDT, ETHUSDT, BNBUSDT, SOLUSDT, XRPUSDT, ADAUSDT, DOGEUSDT, TRXUSDT, LINKUSDT, LTCUSDT, AVAXUSDT, SHIBUSDT, DOTUSDT, UNIUSDT, TONUSDT, MATICUSDT, ATOMUSDT, FILUSDT, ARBUSDT, APTUSDT, NEARUSDT, ETCUSDT, OPUSDT, INJUSDT, IMXUSDT, GRTUSDT, RNDRUSDT, RUNEUSDT, SANDUSDT, AAVEUSDT

## FX (Twelve Data) — 30 pairs
Format: `EUR/USD`  
Provider: Twelve Data time series (API key stored server-side)

EUR/USD, USD/JPY, GBP/USD, USD/CHF, AUD/USD, USD/CAD, NZD/USD, EUR/JPY, GBP/JPY, EUR/GBP, EUR/CHF, EUR/AUD, EUR/CAD, AUD/JPY, CAD/JPY, CHF/JPY, GBP/AUD, GBP/CAD, AUD/CAD, AUD/NZD, NZD/JPY, EUR/NZD, GBP/CHF, CAD/CHF, AUD/CHF, USD/SEK, USD/NOK, USD/MXN, USD/TRY, EUR/TRY

## Rules
- Do not add/remove symbols without updating BOTH:
  - `symbol_universe.json`
  - `symbol_universe.md`
- Any change must be logged in `decision_log.md`.
