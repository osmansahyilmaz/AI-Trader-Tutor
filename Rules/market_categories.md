# market_categories.md — Asset classes, routing, and UI grouping

**Owner:** Osman Şah  
**Pack version:** v5.3  
**Date:** 2025-12-20

## Asset classes (MVP)
### crypto
- Provider: `binance_spot`
- Symbol format: `BTCUSDT`
- Volume: available
- Candles: OHLCV

### fx
- Provider: `twelvedata_fx`
- Symbol format: `EUR/USD`
- Volume: may be unavailable (treat as null)
- Candles: OHLC + optional volume

## Routing rule (MVP)
Backend determines asset class by either:
1) explicit `assetClass` request field (preferred), OR
2) symbol heuristic:
   - contains `/` -> fx
   - endswith `USDT` -> crypto

Backend must validate the symbol is in `symbol_universe.json` universe.

## UI grouping
Home screen:
- Asset class tabs: Crypto | FX
- Symbol picker filtered by asset class
- Timeframe chips shared across both
