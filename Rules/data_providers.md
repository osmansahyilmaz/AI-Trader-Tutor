# data_providers.md — Provider adapters & candle normalization

**Owner:** Osman Şah  
**Pack version:** v5.3  
**Date:** 2025-12-20

This doc defines how to fetch and normalize OHLC(V) candles.

## Candle normalization contract (required)
All providers must normalize into:

```json
{ "t": 1730000000, "o": 1.0, "h": 1.0, "l": 1.0, "c": 1.0, "v": 123.0 }
```

- `t`: unix seconds (open time)
- `o,h,l,c`: numbers
- `v`: number or null (FX may be null)

Candles must be sorted ascending by `t`.  
Reject if timestamps are not strictly increasing.

## Provider: binance_spot (crypto)
- Binance Spot klines (public).
- Timeframe -> interval: 1m, 5m, 15m, 1h, 4h, 1d
- Fetch at least 250 candles (recommended 300–500) for stable EMA200.

Notes:
- Volume exists; parse as number.
- Handle 429 / 5xx by returning 503 (no provider fallback in MVP).

## Provider: twelvedata_fx (fx)
- Twelve Data time series.
- Requires `TWELVEDATA_API_KEY` stored as Edge Function secret.
- Volume may not exist: set `v = null`.

Notes:
- Convert timestamps to unix seconds.
- Use UTC timestamps on server.

## Caching rules (optional but recommended)
DB cache table: `ohlcv_cache(symbol,timeframe)`
TTL:
- 1m: 30s
- 5m/15m: 60s
- 1h/4h: 5m
- 1d: 30m

If cache is fresh, reuse it.
Never mutate candles; determinism depends on stable inputs.
