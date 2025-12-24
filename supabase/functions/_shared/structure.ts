import { Candle } from "./marketData.ts";

export interface Pivot {
    type: "high" | "low";
    price: number;
    t: number;
}

export interface Level {
    type: "support" | "resistance";
    price: number;
    distance_percent: number;
    touches: number;
}

export interface Structure {
    state: "uptrend" | "downtrend" | "range" | "mixed";
    recent_pivots: Pivot[];
}

// 1. Find Pivots (High/Low)
// A pivot high is higher than N bars left and N bars right.
// A pivot low is lower than N bars left and N bars right.
function findPivots(candles: Candle[], left: number = 5, right: number = 5): Pivot[] {
    const pivots: Pivot[] = [];

    for (let i = left; i < candles.length - right; i++) {
        const current = candles[i];

        // Check High
        let isHigh = true;
        for (let j = 1; j <= left; j++) if (candles[i - j].h > current.h) isHigh = false;
        for (let j = 1; j <= right; j++) if (candles[i + j].h > current.h) isHigh = false;

        if (isHigh) {
            pivots.push({ type: "high", price: current.h, t: current.t });
        }

        // Check Low
        let isLow = true;
        for (let j = 1; j <= left; j++) if (candles[i - j].l < current.l) isLow = false;
        for (let j = 1; j <= right; j++) if (candles[i + j].l < current.l) isLow = false;

        if (isLow) {
            pivots.push({ type: "low", price: current.l, t: current.t });
        }
    }

    return pivots;
}

// 2. Cluster Pivots into Levels
function clusterLevels(pivots: Pivot[], currentPrice: number, thresholdPercent: number = 0.5): Level[] {
    const clusters: { priceSum: number; count: number; prices: number[] }[] = [];

    // Sort pivots by price
    const sortedPivots = [...pivots].sort((a, b) => a.price - b.price);

    for (const p of sortedPivots) {
        let added = false;
        for (const c of clusters) {
            const avgPrice = c.priceSum / c.count;
            const diffPercent = (Math.abs(p.price - avgPrice) / avgPrice) * 100;

            if (diffPercent <= thresholdPercent) {
                c.priceSum += p.price;
                c.count++;
                c.prices.push(p.price);
                added = true;
                break;
            }
        }
        if (!added) {
            clusters.push({ priceSum: p.price, count: 1, prices: [p.price] });
        }
    }

    // Convert clusters to levels
    let levels: Level[] = clusters.map(c => {
        const price = c.priceSum / c.count;
        const type = price < currentPrice ? "support" : "resistance";
        const distance_percent = ((price - currentPrice) / currentPrice) * 100;
        return {
            type,
            price,
            distance_percent,
            touches: c.count
        };
    });

    // Filter weak levels (e.g., only 1 touch? maybe keep for now if recent)
    // Sort by touches (desc) then recency (implicit in pivot order? not really)
    // Let's sort by proximity to current price
    levels.sort((a, b) => Math.abs(a.distance_percent) - Math.abs(b.distance_percent));

    // Take top 5 closest
    levels = levels.slice(0, 5);

    return levels;
}

// 3. Determine Structure State
function determineStructureState(pivots: Pivot[]): "uptrend" | "downtrend" | "range" | "mixed" {
    if (pivots.length < 4) return "mixed";

    // Get last 4 pivots
    const recent = pivots.slice(-4);

    // Check for HH/HL (Uptrend)
    // Highs increasing, Lows increasing
    const highs = recent.filter(p => p.type === "high");
    const lows = recent.filter(p => p.type === "low");

    if (highs.length >= 2 && lows.length >= 2) {
        const hh = highs[highs.length - 1].price > highs[highs.length - 2].price;
        const hl = lows[lows.length - 1].price > lows[lows.length - 2].price;
        if (hh && hl) return "uptrend";

        const lh = highs[highs.length - 1].price < highs[highs.length - 2].price;
        const ll = lows[lows.length - 1].price < lows[lows.length - 2].price;
        if (lh && ll) return "downtrend";
    }

    return "mixed"; // or range
}

export function computeStructureAndLevels(candles: Candle[]): { structure: Structure; levels: Level[] } {
    const currentPrice = candles[candles.length - 1].c;

    // 1. Find Pivots
    const pivots = findPivots(candles, 5, 5); // 5 bars left/right

    // 2. Cluster Levels
    // Threshold: 0.5% for crypto, maybe less for FX? 
    // Let's use a dynamic threshold based on ATR if we had it, or fixed 0.5% for MVP.
    const levels = clusterLevels(pivots, currentPrice, 0.5);

    // 3. Structure
    const state = determineStructureState(pivots);

    return {
        structure: {
            state,
            recent_pivots: pivots.slice(-5) // Last 5
        },
        levels
    };
}
