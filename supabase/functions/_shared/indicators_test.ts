import { assertEquals } from "https://deno.land/std@0.168.0/testing/asserts.ts";
import { calculateEMA, calculateRSI, calculateATR, computeIndicators } from "./indicators.ts";
import { Candle } from "./marketData.ts";

// Helper to generate candles
function generateCandles(count: number, startPrice: number, trend: number): Candle[] {
    const candles: Candle[] = [];
    let price = startPrice;
    for (let i = 0; i < count; i++) {
        price += trend; // Simple linear trend
        candles.push({
            t: i * 60,
            o: price,
            h: price + 1,
            l: price - 1,
            c: price,
            v: 100,
        });
    }
    return candles;
}

Deno.test("EMA Calculation", () => {
    const candles = generateCandles(10, 10, 1); // 10, 11, ..., 19
    // Period 5
    // SMA(0-4) = (10+11+12+13+14)/5 = 12
    // EMA(5) = 15 * (2/6) + 12 * (4/6) = 5 + 8 = 13
    const emas = calculateEMA(candles, 5);
    assertEquals(emas.length, 6); // 10 - 5 + 1
    assertEquals(emas[0], 12);
    assertEquals(emas[1], 13);
});

Deno.test("RSI Calculation", () => {
    // Create a sequence of gains
    const candles: Candle[] = [];
    let price = 100;
    candles.push({ t: 0, o: price, h: price, l: price, c: price, v: 0 });

    // 14 gains of 1
    for (let i = 1; i <= 14; i++) {
        price += 1;
        candles.push({ t: i, o: price, h: price, l: price, c: price, v: 0 });
    }

    // AvgGain = 1, AvgLoss = 0 -> RS = inf -> RSI = 100
    const rsis = calculateRSI(candles, 14);
    assertEquals(rsis[0], 100);
});

Deno.test("Trend State Detection", () => {
    // Bullish: EMA20 > EMA50 > EMA200
    // We need > 200 candles
    const candles = generateCandles(250, 100, 1); // Strong uptrend

    const indicators = computeIndicators(candles);
    assertEquals(indicators.trend_state, "bullish");

    // Check values exist
    assertEquals(typeof indicators.ema.ema20, "number");
    assertEquals(typeof indicators.ema.ema50, "number");
    assertEquals(typeof indicators.ema.ema200, "number");
});

Deno.test("Insufficient Data", () => {
    const candles = generateCandles(100, 100, 1);
    try {
        computeIndicators(candles);
        throw new Error("Should have thrown");
    } catch (e) {
        assertEquals(e.message, "Insufficient data for indicators (need 200+)");
    }
});
