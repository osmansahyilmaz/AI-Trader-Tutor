import { Candle } from "./marketData.ts";

export interface Indicators {
    ema: {
        ema20: number;
        ema50: number;
        ema200: number;
    };
    trend_state: "bullish" | "bearish" | "sideways";
    rsi: {
        value: number;
        state: "oversold" | "neutral" | "overbought";
    };
    atr: {
        value: number;
        percent: number;
    };
}

// --- EMA ---
export function calculateEMA(candles: Candle[], period: number): number[] {
    if (candles.length < period) return [];

    const k = 2 / (period + 1);
    const emas: number[] = [];

    // Initial SMA
    let sum = 0;
    for (let i = 0; i < period; i++) {
        sum += candles[i].c;
    }
    let prevEma = sum / period;
    emas.push(prevEma); // This corresponds to index `period - 1`

    // Calculate subsequent EMAs
    for (let i = period; i < candles.length; i++) {
        const price = candles[i].c;
        const ema = price * k + prevEma * (1 - k);
        emas.push(ema);
        prevEma = ema;
    }

    return emas;
}

// --- RSI (Wilder's) ---
export function calculateRSI(candles: Candle[], period: number = 14): number[] {
    if (candles.length < period + 1) return [];

    let gains = 0;
    let losses = 0;

    // Initial average gain/loss
    for (let i = 1; i <= period; i++) {
        const change = candles[i].c - candles[i - 1].c;
        if (change > 0) gains += change;
        else losses -= change;
    }

    let avgGain = gains / period;
    let avgLoss = losses / period;

    const rsis: number[] = [];

    // First RSI
    let rs = avgLoss === 0 ? 100 : avgGain / avgLoss;
    let rsi = 100 - 100 / (1 + rs);
    rsis.push(rsi); // Corresponds to index `period`

    // Subsequent RSIs
    for (let i = period + 1; i < candles.length; i++) {
        const change = candles[i].c - candles[i - 1].c;
        let gain = change > 0 ? change : 0;
        let loss = change < 0 ? -change : 0;

        avgGain = (avgGain * (period - 1) + gain) / period;
        avgLoss = (avgLoss * (period - 1) + loss) / period;

        rs = avgLoss === 0 ? 100 : avgGain / avgLoss;
        rsi = 100 - 100 / (1 + rs);
        rsis.push(rsi);
    }

    return rsis;
}

// --- ATR (Wilder's) ---
export function calculateATR(candles: Candle[], period: number = 14): number[] {
    if (candles.length < period + 1) return [];

    const trs: number[] = [];
    // Calculate TR for all candles starting from index 1
    for (let i = 1; i < candles.length; i++) {
        const high = candles[i].h;
        const low = candles[i].l;
        const prevClose = candles[i - 1].c;

        const tr = Math.max(
            high - low,
            Math.abs(high - prevClose),
            Math.abs(low - prevClose)
        );
        trs.push(tr);
    }

    // Initial ATR (SMA of first 'period' TRs)
    let sum = 0;
    for (let i = 0; i < period; i++) {
        sum += trs[i];
    }
    let prevAtr = sum / period;

    const atrs: number[] = [];
    atrs.push(prevAtr); // Corresponds to index `period`

    // Subsequent ATRs (Wilder's Smoothing)
    for (let i = period; i < trs.length; i++) {
        const currentTr = trs[i];
        const atr = (prevAtr * (period - 1) + currentTr) / period;
        atrs.push(atr);
        prevAtr = atr;
    }

    return atrs;
}

// --- Engine ---
export function computeIndicators(candles: Candle[]): Indicators {
    if (candles.length < 200) {
        throw new Error("Insufficient data for indicators (need 200+)");
    }

    const ema20s = calculateEMA(candles, 20);
    const ema50s = calculateEMA(candles, 50);
    const ema200s = calculateEMA(candles, 200);
    const rsis = calculateRSI(candles, 14);
    const atrs = calculateATR(candles, 14);

    const lastEma20 = ema20s[ema20s.length - 1];
    const lastEma50 = ema50s[ema50s.length - 1];
    const lastEma200 = ema200s[ema200s.length - 1];
    const lastRsi = rsis[rsis.length - 1];
    const lastAtr = atrs[atrs.length - 1];
    const currentPrice = candles[candles.length - 1].c;

    // Trend State
    let trendState: "bullish" | "bearish" | "sideways" = "sideways";
    if (lastEma20 > lastEma50 && lastEma50 > lastEma200) {
        trendState = "bullish";
    } else if (lastEma20 < lastEma50 && lastEma50 < lastEma200) {
        trendState = "bearish";
    }

    // RSI State
    let rsiState: "oversold" | "neutral" | "overbought" = "neutral";
    if (lastRsi > 70) rsiState = "overbought";
    else if (lastRsi < 30) rsiState = "oversold";

    // ATR Percent
    const atrPercent = (lastAtr / currentPrice) * 100;

    return {
        ema: {
            ema20: lastEma20,
            ema50: lastEma50,
            ema200: lastEma200,
        },
        trend_state: trendState,
        rsi: {
            value: lastRsi,
            state: rsiState,
        },
        atr: {
            value: lastAtr,
            percent: atrPercent,
        },
    };
}
