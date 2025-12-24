export interface Candle {
    t: number; // unix seconds
    o: number;
    h: number;
    l: number;
    c: number;
    v: number | null;
}

export async function fetchCandles(
    symbol: string,
    timeframe: string,
    assetClass: "crypto" | "fx"
): Promise<Candle[]> {
    if (assetClass === "crypto") {
        return fetchBinanceCandles(symbol, timeframe);
    } else if (assetClass === "fx") {
        return fetchTwelveDataCandles(symbol, timeframe);
    } else {
        throw new Error(`Unsupported asset class: ${assetClass}`);
    }
}

async function fetchBinanceCandles(
    symbol: string,
    timeframe: string
): Promise<Candle[]> {
    // Binance interval mapping
    // 1m, 5m, 15m, 1h, 4h, 1d are standard
    const interval = timeframe;
    const limit = 300; // Need enough for EMA200

    const baseUrl = Deno.env.get("BINANCE_BASE_URL") || "https://api.binance.com";
    const url = `${baseUrl}/api/v3/klines?symbol=${symbol}&interval=${interval}&limit=${limit}`;
    console.log(`Fetching Binance: ${url}`);

    const res = await fetch(url);
    if (!res.ok) {
        throw new Error(`Binance API error: ${res.status} ${res.statusText}`);
    }

    const data = await res.json();

    // Binance format: [ [t, o, h, l, c, v, ...], ... ]
    // t is ms
    const candles: Candle[] = data.map((d: any[]) => ({
        t: Math.floor(d[0] / 1000),
        o: parseFloat(d[1]),
        h: parseFloat(d[2]),
        l: parseFloat(d[3]),
        c: parseFloat(d[4]),
        v: parseFloat(d[5]),
    }));

    // Sort ascending by t (Binance usually returns sorted, but safety first)
    candles.sort((a, b) => a.t - b.t);

    return candles;
}

async function fetchTwelveDataCandles(
    symbol: string,
    timeframe: string
): Promise<Candle[]> {
    const apiKey = Deno.env.get("TWELVEDATA_API_KEY");
    if (!apiKey) {
        throw new Error("TWELVEDATA_API_KEY not configured");
    }

    // Twelve Data interval mapping
    // 1min, 5min, 15min, 1h, 4h, 1day
    let interval = timeframe;
    if (timeframe === '1m') interval = '1min';
    if (timeframe === '5m') interval = '5min';
    if (timeframe === '15m') interval = '15min';
    if (timeframe === '1d') interval = '1day';

    const outputsize = 300;
    const baseUrl = Deno.env.get("TWELVEDATA_BASE_URL") || "https://api.twelvedata.com";
    const url = `${baseUrl}/time_series?symbol=${symbol}&interval=${interval}&apikey=${apiKey}&outputsize=${outputsize}&format=JSON`;
    console.log(`Fetching TwelveData: ${url.replace(apiKey, "***")}`);

    const res = await fetch(url);
    if (!res.ok) {
        throw new Error(`TwelveData API error: ${res.status} ${res.statusText}`);
    }

    const data = await res.json();

    if (data.status === "error") {
        throw new Error(`TwelveData error: ${data.message}`);
    }

    if (!data.values || !Array.isArray(data.values)) {
        throw new Error("TwelveData: Invalid response format");
    }

    // Twelve Data returns descending order usually
    const rawValues: any[] = data.values;

    const candles: Candle[] = rawValues.map((d: any) => ({
        t: parseInt(d.timestamp) || Math.floor(new Date(d.datetime).getTime() / 1000),
        o: parseFloat(d.open),
        h: parseFloat(d.high),
        l: parseFloat(d.low),
        c: parseFloat(d.close),
        v: d.volume ? parseFloat(d.volume) : null,
    }));

    // Sort ascending
    candles.sort((a, b) => a.t - b.t);

    return candles;
}
